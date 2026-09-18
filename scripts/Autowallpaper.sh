#!/bin/bash
#
# Autowallpaper.sh - define um wallpaper aleatorio da pasta de wallpapers.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config.sh"

if [ ! -d "$WALLPAPER_DIR" ]; then
  print_error "Pasta de wallpapers nao encontrada: $WALLPAPER_DIR"
  exit 1
fi

shopt -s nullglob
WALLPAPERS=("$WALLPAPER_DIR"/*.jpg "$WALLPAPER_DIR"/*.jpeg "$WALLPAPER_DIR"/*.png "$WALLPAPER_DIR"/*.webp)

if [ ${#WALLPAPERS[@]} -eq 0 ]; then
  print_error "Nenhuma imagem encontrada em $WALLPAPER_DIR"
  exit 1
fi

# Escolhe um aleatorio
RANDOM_WALLPAPER="$(shuf -e "${WALLPAPERS[@]}" | head -1)"
URI="file://$RANDOM_WALLPAPER"

# Define para tema claro e escuro (GNOME atual usa picture-uri-dark tambem)
gsettings set org.gnome.desktop.background picture-uri "$URI"
gsettings set org.gnome.desktop.background picture-uri-dark "$URI"

print_success "Wallpaper alterado para: $RANDOM_WALLPAPER"
