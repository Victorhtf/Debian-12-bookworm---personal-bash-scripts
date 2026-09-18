#!/bin/bash
#
# Backup_gnome_config.sh
# Exporta keybinds, lista de extensoes GNOME e suas configuracoes para a pasta
# assets/ do repositorio. Se houver diferenca, commita (e opcionalmente da push).
#
# Uso:
#   ./Backup_gnome_config.sh            # exporta e commita local se houver diff
#   ./Backup_gnome_config.sh --push     # tambem faz git push
#   ./Backup_gnome_config.sh --no-commit # so exporta, nao mexe no git
#
set -u

## Configuracao central (cores, paths, INIT_SENTINEL) ##
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

## Aliases curtos de log usados neste script ##
info()  { print_info "$1"; }
ok()    { print_success "$1"; }
err()   { print_error "$1"; }

## Descobre a raiz do repositorio a partir da localizacao deste script ##
REPO_ROOT="$(cd "$SCRIPT_DIR" && git rev-parse --show-toplevel 2>/dev/null)"

if [ -z "$REPO_ROOT" ]; then
  # Fallback: assume que o script esta em <repo>/scripts/
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

ASSETS_DIR="$REPO_ROOT/assets"
mkdir -p "$ASSETS_DIR"

KEYBINDS_FILE="$ASSETS_DIR/keybinds.dconf"
EXT_LIST_FILE="$ASSETS_DIR/gnome-extensions.list"
EXT_SETTINGS_FILE="$ASSETS_DIR/gnome-extensions-settings.dconf"

## Sentinela de inicializacao (definida em config.sh como INIT_SENTINEL):
## criada pelo setup ao aplicar as binds do repo. Sem ela, este script NAO
## exporta, para nao sobrescrever o repo com estado vazio. --force ignora.

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
  info "Rode a instalacao (setup_keybinds_dconf) primeiro, ou use --force para forcar."
  exit 0
fi

## 1. Exporta keybinds ##
# Cada 'dconf dump <path>/' gera secoes relativas com cabecalho [/].
# Para juntar tudo num unico arquivo carregavel com 'dconf load /',
# reescrevemos o cabecalho [/] para o caminho absoluto de cada bloco.
export_keybinds() {
  info "Exporting keybinds..."

  local paths=(
    "org/gnome/mutter/keybindings"
    "org/gnome/mutter/wayland/keybindings"
    "org/gnome/shell/keybindings"
    "org/gnome/desktop/wm/keybindings"
    "org/gnome/settings-daemon/plugins/media-keys"
  )

  : > "$KEYBINDS_FILE"
  for p in "${paths[@]}"; do
    local dump
    dump="$(dconf dump "/$p/" 2>/dev/null)"
    [ -z "$dump" ] && continue
    # Reescreve cabecalhos: [/] -> [caminho]; [sub] -> [caminho/sub]
    echo "$dump" | awk -v base="$p" '
      /^\[\/\]$/       { print "[" base "]"; next }
      /^\[.+\]$/       { sub(/^\[/, "[" base "/"); print; next }
      { print }
    ' >> "$KEYBINDS_FILE"
    echo >> "$KEYBINDS_FILE"
  done

  ok "Keybinds exported to $KEYBINDS_FILE"
}

## 2. Exporta lista de extensoes GNOME ##
export_extensions_list() {
  info "Exporting GNOME extensions list..."
  if command -v gnome-extensions &> /dev/null; then
    gnome-extensions list --enabled 2>/dev/null | sort > "$EXT_LIST_FILE"
    ok "Extension list exported to $EXT_LIST_FILE ($(wc -l < "$EXT_LIST_FILE") extensions)"
  else
    err "gnome-extensions CLI not found; skipping extension list."
  fi
}

## 3. Exporta configuracoes das extensoes ##
export_extensions_settings() {
  info "Exporting GNOME extensions settings..."
  if dconf dump /org/gnome/shell/extensions/ > "$EXT_SETTINGS_FILE" 2>/dev/null && [ -s "$EXT_SETTINGS_FILE" ]; then
    ok "Extension settings exported to $EXT_SETTINGS_FILE"
  else
    info "No extension settings found (or dconf empty)."
    rm -f "$EXT_SETTINGS_FILE"
  fi
}

## 4. Commit se houver diferenca ##
commit_if_changed() {
  [ "$DO_COMMIT" -eq 0 ] && { info "--no-commit set, skipping git."; return; }

  cd "$REPO_ROOT" || { err "Cannot cd to repo root."; return; }

  # Verifica se ha mudanca especificamente nos assets exportados
  git add "$ASSETS_DIR" 2>/dev/null

  if git diff --cached --quiet -- "$ASSETS_DIR"; then
    info "No changes in keybinds/extensions. Nothing to commit."
    return
  fi

  info "Changes detected in assets. Committing..."
  local stamp
  stamp="$(date '+%Y-%m-%d %H:%M')"
  git commit -m "backup(gnome): update keybinds/extensions - $stamp" -- "$ASSETS_DIR"
  ok "Committed changes."

  if [ "$DO_PUSH" -eq 1 ]; then
    info "Pushing to remote..."
    if git push; then
      ok "Pushed to remote."
    else
      err "git push failed. Push manually when ready."
    fi
  else
    info "Commit done locally. Run with --push (or 'git push') to publish."
  fi
}

## Main ##
info "GNOME config backup starting (repo: $REPO_ROOT)"
export_keybinds
export_extensions_list
export_extensions_settings
commit_if_changed
ok "Backup finished."
