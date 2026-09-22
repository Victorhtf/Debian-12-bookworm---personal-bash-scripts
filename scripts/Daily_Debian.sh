#!/bin/bash
#
# Daily_Debian.sh - orquestrador de tarefas diarias.
# Organiza os downloads, faz backup local de arquivos e notifica.
# O backup versionado das configs (GNOME/terminal/cron) e feito pelo cron via
# Backup.sh (independente deste script).

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/Backup_files.sh"

## Organiza a pasta de Downloads em subpastas por tipo ##
organize_downloads() {
  local dir="$DOWNLOADS_DIR"
  if [ ! -d "$dir" ]; then
    print_error "Pasta de downloads nao encontrada: $dir"
    return
  fi
  print_info "Organizando $dir ..."
  mkdir -p "$dir/images" "$dir/media" "$dir/documents" "$dir/scripts" \
           "$dir/compressed" "$dir/other" "$dir/applications"

  find "$dir" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.tif" -o -iname "*.tiff" -o -iname "*.bmp" -o -iname "*.gif" -o -iname "*.eps" -o -iname "*.raw" \) -exec mv {} "$dir/images" \; 2>/dev/null
  find "$dir" -maxdepth 1 -type f \( -iname "*.mp3" -o -iname "*.m4a" -o -iname "*.flac" -o -iname "*.aac" -o -iname "*.ogg" -o -iname "*.wav" -o -iname "*.mp4" -o -iname "*.mov" -o -iname "*.avi" -o -iname "*.mpg" -o -iname "*.mpeg" -o -iname "*.webm" -o -iname "*.mpv" -o -iname "*.mp2" -o -iname "*.wmv" -o -iname "*.mkv" \) -exec mv {} "$dir/media" \; 2>/dev/null
  find "$dir" -maxdepth 1 -type f \( -iname "*.pdf" -o -iname "*.txt" -o -iname "*.docx" -o -iname "*.xlsx" -o -iname "*.xls" -o -iname "*.odt" -o -iname "*.ods" -o -iname "*.pptx" -o -iname "*.csv" \) -exec mv {} "$dir/documents" \; 2>/dev/null
  find "$dir" -maxdepth 1 -type f \( -iname "*.py" -o -iname "*.rb" -o -iname "*.sh" -o -iname "*.bash" -o -iname "*.pl" -o -iname "*.php" -o -iname "*.js" \) -exec mv {} "$dir/scripts" \; 2>/dev/null
  find "$dir" -maxdepth 1 -type f \( -iname "*.rar" -o -iname "*.zip" -o -iname "*.tar.gz" -o -iname "*.tar.xz" -o -iname "*.7z" -o -iname "*.bz2" \) -exec mv {} "$dir/compressed" \; 2>/dev/null
  find "$dir" -maxdepth 1 -type f \( -iname "*.deb" -o -iname "*.exe" -o -iname "*.AppImage" \) -exec mv {} "$dir/applications" \; 2>/dev/null

  print_success "Downloads organizados."
}

## Notificacao de conclusao (best-effort) ##
notify_done() {
  local uid
  uid="$(id -u "$USERNAME")"
  DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
    notify-send "System backup" "Backup finished" 2>/dev/null || true
}

## Main ##
print_info "Tarefas diarias iniciando..."
organize_downloads
backup_debian_folder
backup_wallpapers
notify_done
print_success "Tarefas diarias finalizadas."
