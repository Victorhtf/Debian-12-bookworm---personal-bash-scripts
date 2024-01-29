#!/bin/bash

# Directory containing wallpaper images
WALLPAPER_DIR="/home/victorhtf/Pictures/Wallpapers"

# Check if the directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Wallpaper directory not found. Exiting the script."
    exit 1
fi

# Get a list of image files in the directory
shopt -s nullglob  # This ensures that if there are no matches, the list is empty
WALLPAPERS=("$WALLPAPER_DIR"/*.jpg "$WALLPAPER_DIR"/*.jpeg "$WALLPAPER_DIR"/*.png "$WALLPAPER_DIR"/*.webp)

# Check if there are any images in the directory
if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    echo "No wallpaper images found in the directory. Exiting the script."
    exit 1
fi

# Shuffle the list of images
SHUFFLED_WALLPAPERS=($(shuf -e "${WALLPAPERS[@]}"))

# Choose a random wallpaper
RANDOM_WALLPAPER=${SHUFFLED_WALLPAPERS[0]}

# Command to set the wallpaper (may vary depending on the desktop environment)
# The example below uses the `gsettings` command commonly used in GNOME environments
gsettings set org.gnome.desktop.background picture-uri "file://$RANDOM_WALLPAPER"

echo "Wallpaper changed to: $RANDOM_WALLPAPER"
