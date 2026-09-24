#!/bin/bash
#
# Organize_auto.sh - organiza pastas em subpastas por tipo, sem interacao.
# Wrapper nao-interativo do Organize_folders.sh, pensado para rodar no cron.
# Organiza Downloads e Desktop (detecta nome real da pasta: pt/en, maiusc/minusc).
#
# Uso:
#   Organize_auto.sh                 # organiza as pastas padrao (downloads + desktop)
#   Organize_auto.sh /caminho/pasta  # organiza uma pasta especifica
#
# NAO altera o Organize_folders.sh original (uso interativo continua valendo).

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config.sh"

## Resolve o nome real de uma pasta testando variacoes (pt/en, maiusc/minusc).
## Recebe a lista de candidatos e ecoa o primeiro que existir.
resolve_dir() {
  local candidate
  for candidate in "$@"; do
    if [ -d "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

## Organiza uma unica pasta em subpastas por tipo. ##
organize_dir() {
  local dir="$1"
  if [ -z "$dir" ] || [ ! -d "$dir" ]; then
    print_error "Pasta nao encontrada, pulando: ${dir:-<vazio>}"
    return
  fi
  print_info "Organizando $dir ..."
  mkdir -p "$dir/images" "$dir/media" "$dir/documents" "$dir/scripts" \
           "$dir/compressed" "$dir/other" "$dir/applications"

  # Imagens
  find "$dir" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.tif" -o -iname "*.tiff" -o -iname "*.bmp" -o -iname "*.gif" -o -iname "*.eps" -o -iname "*.raw" -o -iname "*.webp" -o -iname "*.svg" \) -exec mv -n {} "$dir/images" \; 2>/dev/null
  # Media (audio + video)
  find "$dir" -maxdepth 1 -type f \( -iname "*.mp3" -o -iname "*.m4a" -o -iname "*.flac" -o -iname "*.aac" -o -iname "*.ogg" -o -iname "*.wav" -o -iname "*.mp4" -o -iname "*.mov" -o -iname "*.avi" -o -iname "*.mpg" -o -iname "*.mpeg" -o -iname "*.webm" -o -iname "*.mpv" -o -iname "*.mp2" -o -iname "*.wmv" -o -iname "*.mkv" \) -exec mv -n {} "$dir/media" \; 2>/dev/null
  # Documentos
  find "$dir" -maxdepth 1 -type f \( -iname "*.pdf" -o -iname "*.txt" -o -iname "*.docx" -o -iname "*.doc" -o -iname "*.xlsx" -o -iname "*.xls" -o -iname "*.odt" -o -iname "*.ods" -o -iname "*.pptx" -o -iname "*.ppt" -o -iname "*.csv" \) -exec mv -n {} "$dir/documents" \; 2>/dev/null
  # Scripts
  find "$dir" -maxdepth 1 -type f \( -iname "*.py" -o -iname "*.rb" -o -iname "*.sh" -o -iname "*.bash" -o -iname "*.pl" -o -iname "*.php" -o -iname "*.js" \) -exec mv -n {} "$dir/scripts" \; 2>/dev/null
  # Compactados
  find "$dir" -maxdepth 1 -type f \( -iname "*.rar" -o -iname "*.zip" -o -iname "*.tar.gz" -o -iname "*.tar.xz" -o -iname "*.gz" -o -iname "*.7z" -o -iname "*.bz2" \) -exec mv -n {} "$dir/compressed" \; 2>/dev/null
  # Aplicativos
  find "$dir" -maxdepth 1 -type f \( -iname "*.deb" -o -iname "*.exe" -o -iname "*.AppImage" \) -exec mv -n {} "$dir/applications" \; 2>/dev/null

  print_success "Organizado: $dir"
}

## Main ##
if [ -n "$1" ]; then
  # Modo pasta especifica
  organize_dir "$1"
else
  # Modo padrao: downloads + desktop (detecta nome real)
  DL="$(resolve_dir "$HOME_DIR/downloads" "$HOME_DIR/Downloads" "$HOME_DIR/Transferências" "$HOME_DIR/transferências")"
  DESK="$(resolve_dir "$HOME_DIR/desktop" "$HOME_DIR/Desktop" "$HOME_DIR/Área de Trabalho" "$HOME_DIR/área de trabalho")"

  [ -n "$DL" ]   && organize_dir "$DL"   || print_error "Nenhuma pasta de downloads encontrada."
  [ -n "$DESK" ] && organize_dir "$DESK" || print_error "Nenhuma pasta desktop encontrada."
fi
