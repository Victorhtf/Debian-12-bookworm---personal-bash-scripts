#!/bin/bash
#
# Backup_files.sh - arquivamento local de arquivos (nao versionado).
# Copia a pasta ~/debian e os wallpapers para ~/Backups/<timestamp>/.
# O backup das configuracoes versionadas (binds/extensoes/terminal/cron) e feito
# por Backup.sh (versionado no git) - aqui NAO ha duplicacao.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config.sh"

## Destino com timestamp, para nao sobrescrever backups antigos ##
STAMP="$(date '+%Y-%m-%d_%H-%M-%S')"
DEST="$BACKUP_DIR/$STAMP"

## Backup da pasta ~/debian ##
backup_debian_folder() {
  if [ -d "$DEBIAN_DIR" ]; then
    print_info "Copiando $DEBIAN_DIR -> $DEST/"
    mkdir -p "$DEST"
    cp -r "$DEBIAN_DIR" "$DEST/"
    print_success "Pasta debian copiada."
  else
    print_error "Pasta $DEBIAN_DIR nao encontrada."
  fi
}

## Backup dos wallpapers ##
backup_wallpapers() {
  if [ -d "$WALLPAPER_DIR" ]; then
    print_info "Copiando wallpapers -> $DEST/"
    mkdir -p "$DEST"
    cp -r "$WALLPAPER_DIR" "$DEST/"
    print_success "Wallpapers copiados."
  else
    print_info "Pasta de wallpapers nao encontrada, ignorando."
  fi
}

## Se executado diretamente, roda tudo. Se for 'source', apenas define as funcoes. ##
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  print_info "Backup de arquivos iniciando (destino: $DEST)"
  backup_debian_folder
  backup_wallpapers
  print_success "Backup de arquivos finalizado."
fi
