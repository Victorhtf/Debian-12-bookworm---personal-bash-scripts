#!/bin/bash
#
# Backup.sh - backup unico das configuracoes versionadas no repositorio.
#
# Exporta, num so lugar, para a pasta assets/ do repo:
#   1. Keybinds do GNOME            -> assets/keybinds.dconf
#   2. Lista de extensoes GNOME     -> assets/gnome-extensions.list
#   3. Config das extensoes GNOME   -> assets/gnome-extensions-settings.dconf
#   4. Perfis do GNOME Terminal     -> assets/terminal.dconf
#      (cores, fonte, nome do perfil, keybindings, default; sem depender de
#       nome de perfil fixo - exporta a arvore /org/gnome/terminal/ inteira)
#   5. Crontab do usuario           -> assets/crontab (portavel via __HOME__)
#
# Se algo mudou, commita (e opcionalmente da push). O restore correspondente
# vive no Setup_Debian.sh (setup_keybinds_dconf, setup_terminal_dconf, etc.).
#
# Uso:
#   ./Backup.sh              # exporta tudo e commita local se houver diff
#   ./Backup.sh --push       # tambem faz git push
#   ./Backup.sh --no-commit  # so exporta, nao mexe no git
#   ./Backup.sh --force      # ignora a sentinela de init
#
set -u

## Configuracao central (cores, paths, INIT_SENTINEL) ##
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

## Aliases curtos de log ##
info()  { print_info "$1"; }
ok()    { print_success "$1"; }
err()   { print_error "$1"; }

## Trava anti-root: este backup exporta configs do USUARIO (dconf da sessao,
## ~/.bashrc, crontab do usuario). Rodar como root leria o dconf/HOME do root
## (vazio/errado) e poderia SOBRESCREVER os assets bons com lixo. Recusa. ##
if [ "$(id -u)" -eq 0 ]; then
  err "Nao rode este backup como root/sudo."
  err "Ele exporta as configuracoes do SEU usuario (dconf, ~/.bashrc, crontab)."
  err "Rodar como root capturaria dados vazios/errados e corromperia os assets."
  exit 1
fi

## Raiz do repositorio ##
REPO_ROOT="$(cd "$SCRIPT_DIR" && git rev-parse --show-toplevel 2>/dev/null)"
[ -z "$REPO_ROOT" ] && REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

ASSETS_DIR="$REPO_ROOT/assets"
mkdir -p "$ASSETS_DIR"

KEYBINDS_FILE="$ASSETS_DIR/keybinds.dconf"
EXT_LIST_FILE="$ASSETS_DIR/gnome-extensions.list"
EXT_ENABLED_FILE="$ASSETS_DIR/gnome-extensions-enabled.list"
EXT_SETTINGS_FILE="$ASSETS_DIR/gnome-extensions-settings.dconf"
TERMINAL_FILE="$ASSETS_DIR/terminal.dconf"
CRON_FILE="$ASSETS_DIR/crontab"
GENERAL_FILE="$ASSETS_DIR/gnome-general.dconf"
BASHRC_FILE="$ASSETS_DIR/bashrc"
FLATPAK_LIST_FILE="$ASSETS_DIR/flatpak.list"
KITTY_FILE="$ASSETS_DIR/kitty.conf"
KITTY_DESKTOP_FILE="$ASSETS_DIR/kitty.desktop"
GT_DESKTOP_FILE="$ASSETS_DIR/org.gnome.Terminal.desktop"

## Flags ##
DO_COMMIT=1
DO_PUSH=0
FORCE=0
for arg in "$@"; do
  case "$arg" in
    --push) DO_PUSH=1 ;;
    --no-commit) DO_COMMIT=0 ;;
    --force) FORCE=1 ;;
    *) err "Unknown flag: $arg" ;;
  esac
done

## Trava de seguranca: exige inicializacao previa (a menos que --force) ##
if [ "$FORCE" -eq 0 ] && [ ! -f "$INIT_SENTINEL" ]; then
  err "Sistema ainda nao inicializado (sentinela ausente: $INIT_SENTINEL)."
  info "Rode a instalacao primeiro, ou use --force para forcar."
  exit 0
fi

## Helper: reescreve cabecalhos do 'dconf dump' para caminho absoluto,
## tornando o arquivo carregavel com 'dconf load /'. ##
dump_absolute() {
  local path="$1"                 # ex: /org/gnome/terminal/
  local base="${path#/}"; base="${base%/}"
  local dump; dump="$(dconf dump "$path" 2>/dev/null)"
  [ -z "$dump" ] && return 1
  echo "$dump" | awk -v base="$base" '
    /^\[\/\]$/ { print "[" base "]"; next }
    /^\[.+\]$/ { sub(/^\[/, "[" base "/"); print; next }
    { print }
  '
}

## 1. Keybinds do GNOME ##
export_keybinds() {
  info "Exporting GNOME keybinds..."
  local paths=(
    "/org/gnome/mutter/keybindings/"
    "/org/gnome/mutter/wayland/keybindings/"
    "/org/gnome/shell/keybindings/"
    "/org/gnome/desktop/wm/keybindings/"
    "/org/gnome/settings-daemon/plugins/media-keys/"
  )
  : > "$KEYBINDS_FILE"
  local p
  for p in "${paths[@]}"; do
    dump_absolute "$p" >> "$KEYBINDS_FILE" && echo >> "$KEYBINDS_FILE"
  done
  ok "Keybinds -> $KEYBINDS_FILE"
}

## 2. Lista de extensoes GNOME ##
export_extensions_list() {
  info "Exporting GNOME extensions list..."
  if command -v gnome-extensions &> /dev/null; then
    # Lista TODAS as instaladas (para o setup reinstalar) e as habilitadas
    # (para reativar exatamente o mesmo conjunto). Assim add/remove/enable/disable
    # sao todos versionados.
    gnome-extensions list 2>/dev/null | sort > "$EXT_LIST_FILE"
    gnome-extensions list --enabled 2>/dev/null | sort > "$EXT_ENABLED_FILE"
    ok "Extensions list -> $EXT_LIST_FILE ($(wc -l < "$EXT_LIST_FILE") instaladas, $(wc -l < "$EXT_ENABLED_FILE") habilitadas)"
  else
    err "gnome-extensions CLI not found; skipping extension list."
  fi
}

## 3. Config das extensoes GNOME ##
export_extensions_settings() {
  info "Exporting GNOME extensions settings..."
  if dconf dump /org/gnome/shell/extensions/ > "$EXT_SETTINGS_FILE" 2>/dev/null && [ -s "$EXT_SETTINGS_FILE" ]; then
    ok "Extensions settings -> $EXT_SETTINGS_FILE"
  else
    info "No extension settings found (or dconf empty)."
    rm -f "$EXT_SETTINGS_FILE"
  fi
}

## 4. Perfis do GNOME Terminal ##
export_terminal() {
  info "Exporting GNOME Terminal profiles..."
  if dump_absolute "/org/gnome/terminal/" > "$TERMINAL_FILE"; then
    ok "Terminal profiles -> $TERMINAL_FILE"
    local def
    def="$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'")"
    [ -n "$def" ] && info "Default profile UUID: $def"
  else
    err "No terminal settings found; skipping."
    rm -f "$TERMINAL_FILE"
  fi
}

## 5. Crontab do usuario (agendamentos) ##
export_cron() {
  info "Exporting user crontab..."
  local cur
  cur="$(crontab -l 2>/dev/null)"
  if [ -z "$cur" ]; then
    info "No crontab for user; skipping."
    return
  fi
  # Torna portavel: troca o HOME real pelo placeholder __HOME__
  echo "$cur" | sed "s#${HOME_DIR}#__HOME__#g" > "$CRON_FILE"
  ok "Crontab -> $CRON_FILE"
}

## 6. Configuracoes gerais do GNOME (aparencia, mouse/touchpad, wallpaper, etc.) ##
# Exporta ramos do dconf que nao sao keybinds nem extensoes, com cabecalhos
# absolutos para permitir 'dconf load /'.
export_general() {
  info "Exporting general GNOME settings..."
  local paths=(
    "/org/gnome/desktop/interface/"
    "/org/gnome/desktop/wm/preferences/"
    "/org/gnome/desktop/peripherals/"
    "/org/gnome/desktop/background/"
    "/org/gnome/desktop/screensaver/"
    "/org/gnome/desktop/input-sources/"
    "/org/gnome/mutter/"
  )
  : > "$GENERAL_FILE"
  local p
  for p in "${paths[@]}"; do
    dump_absolute "$p" >> "$GENERAL_FILE" && echo >> "$GENERAL_FILE"
  done
  # Remove arquivo se ficou vazio
  [ -s "$GENERAL_FILE" ] && ok "General settings -> $GENERAL_FILE" || { rm -f "$GENERAL_FILE"; info "No general settings to export."; }
}

## 7. ~/.bashrc do usuario ##
export_bashrc() {
  info "Exporting ~/.bashrc..."
  if [ -f "$HOME_DIR/.bashrc" ]; then
    cp "$HOME_DIR/.bashrc" "$BASHRC_FILE"
    ok "bashrc -> $BASHRC_FILE"
  else
    info "~/.bashrc not found; skipping."
  fi
}

## 8. Lista de flatpaks instalados (apps) ##
export_flatpaks() {
  info "Exporting installed Flatpak apps..."
  if command -v flatpak &> /dev/null; then
    # So os apps (nao runtimes), por application-id, ordenados
    flatpak list --app --columns=application 2>/dev/null | sort > "$FLATPAK_LIST_FILE"
    if [ -s "$FLATPAK_LIST_FILE" ]; then
      ok "Flatpak list -> $FLATPAK_LIST_FILE ($(wc -l < "$FLATPAK_LIST_FILE") apps)"
    else
      rm -f "$FLATPAK_LIST_FILE"
      info "No flatpak apps found."
    fi
  else
    info "flatpak CLI not found; skipping."
  fi
}

## 9. Config do Kitty ##
export_kitty() {
  info "Exporting kitty.conf..."
  if [ -f "$HOME_DIR/.config/kitty/kitty.conf" ]; then
    cp "$HOME_DIR/.config/kitty/kitty.conf" "$KITTY_FILE"
    ok "kitty.conf -> $KITTY_FILE"
  else
    info "~/.config/kitty/kitty.conf not found; skipping."
  fi
}

## 9b. Override do lancador do Kitty (~/.local/share/applications/kitty.desktop) ##
# Sobrescreve o .desktop do sistema para trocar o icone/nome exibido na dock e
# no menu de apps sem tocar no arquivo de /usr/share/applications (que seria
# apagado numa atualizacao do kitty). Portavel: nao contem paths de HOME.
export_kitty_desktop() {
  info "Exporting kitty.desktop override..."
  if [ -f "$HOME_DIR/.local/share/applications/kitty.desktop" ]; then
    cp "$HOME_DIR/.local/share/applications/kitty.desktop" "$KITTY_DESKTOP_FILE"
    ok "kitty.desktop -> $KITTY_DESKTOP_FILE"
  else
    info "~/.local/share/applications/kitty.desktop not found; skipping."
  fi
}

## 9c. Override do launcher do GNOME Terminal (~/.local/share/applications/org.gnome.Terminal.desktop) ##
# Override do usuario com NoDisplay=true para ocultar o gnome-terminal do menu
# de apps/overview, sem remover o pacote nem tocar em /usr/share/applications.
export_gnome_terminal_desktop() {
  info "Exporting org.gnome.Terminal.desktop override..."
  if [ -f "$HOME_DIR/.local/share/applications/org.gnome.Terminal.desktop" ]; then
    cp "$HOME_DIR/.local/share/applications/org.gnome.Terminal.desktop" "$GT_DESKTOP_FILE"
    ok "org.gnome.Terminal.desktop -> $GT_DESKTOP_FILE"
  else
    info "~/.local/share/applications/org.gnome.Terminal.desktop not found; skipping."
  fi
}

## 10. Commit se houver diferenca (qualquer arquivo em assets/) ##
commit_if_changed() {
  [ "$DO_COMMIT" -eq 0 ] && { info "--no-commit set, skipping git."; return; }
  cd "$REPO_ROOT" || { err "Cannot cd to repo root."; return; }

  git add "$ASSETS_DIR" 2>/dev/null

  if git diff --cached --quiet -- "$ASSETS_DIR"; then
    info "No changes in backed-up configs. Nothing to commit."
    return
  fi

  info "Changes detected. Committing..."
  local stamp; stamp="$(date '+%Y-%m-%d %H:%M')"
  git commit -m "backup: update GNOME keybinds/extensions/terminal/cron/general - $stamp" \
    -- "$ASSETS_DIR"
  ok "Committed changes."

  if [ "$DO_PUSH" -eq 1 ]; then
    info "Pushing to remote..."
    git push && ok "Pushed to remote." || err "git push failed. Push manually when ready."
  else
    info "Commit done locally. Run with --push (or 'git push') to publish."
  fi
}

## Main ##
info "Backup starting (repo: $REPO_ROOT)"
export_keybinds
export_extensions_list
export_extensions_settings
export_terminal
export_cron
export_general
export_bashrc
export_flatpaks
export_kitty
export_kitty_desktop
export_gnome_terminal_desktop
commit_if_changed
ok "Backup finished."
