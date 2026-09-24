#!/bin/bash
#
# Daily_Debian.sh - orquestrador de tarefas diarias.
# Organiza os downloads, faz backup local de arquivos e notifica.
# O backup versionado das configs (GNOME/terminal/cron) e feito pelo cron via
# Backup.sh (independente deste script).

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/Backup_files.sh"

## Notificacao de conclusao (best-effort) ##
notify_done() {
  local uid
  uid="$(id -u "$USERNAME")"
  DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
    notify-send "System backup" "Backup finished" 2>/dev/null || true
}

## Main ##
print_info "Tarefas diarias iniciando..."
"$SCRIPTS_DIR/Organize_auto.sh"
backup_debian_folder
backup_wallpapers
notify_done
print_success "Tarefas diarias finalizadas."
