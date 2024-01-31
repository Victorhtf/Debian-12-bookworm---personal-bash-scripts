#!/bin/bash
source /home/$USERNAME/Debian/scripts/Backup_Debian12.sh

USERNAME="victorhtf"

SCRIPTS_FOLDER="/home/$USERNAME/Debian/scripts"
DUMP_FOLDER="/home/$USERNAME/Debian/dump"
CONF_FOLDER="/home/$USERNAME/Debian/conf"
BACKUP_FOLDER="/home/$USERNAME/Backups"

## Terminal colors ##
GREEN='\033[0;32m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m'

## Print success message in green ##
print_success() {
  echo -e "${GREEN}[OK] - $1${NC}\n"
}

## Print info message in orange ##
print_info() {
  echo -e "${ORANGE}[INFO] - $1${NC}"
}

## Print error message in red ##
print_error() { 
  echo -e "${RED}[ERROR] - $1${NC}\n"
}


## Organize downloads folder ##
ORGANIZE_DOWNLOADS() {
  DIRECTORY_PATH="/home/$USERNAME/Downloads/"
  if [ ! -d "$DIRECTORY_PATH" ]; then
      print_error "Directory not found. Exiting the script."
      exit 1
  fi

  # Create folders in the user-provided directory
  mkdir -p "$DIRECTORY_PATH/images" "$DIRECTORY_PATH/media" "$DIRECTORY_PATH/documents" "$DIRECTORY_PATH/scripts" "$DIRECTORY_PATH/compressed" "$DIRECTORY_PATH/other" "$DIRECTORY_PATH/applications"

  # Move files to corresponding folders

  # Images
  find "$DIRECTORY_PATH" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.tif" -o -iname "*.tiff" -o -iname "*.bmp" -o -iname "*.gif" -o -iname "*.eps" -o -iname "*.raw" \) -exec mv {} "$DIRECTORY_PATH/images" \; 2>/dev/null

  # Media
  find "$DIRECTORY_PATH" -maxdepth 1 -type f \( -iname "*.mp3" -o -iname "*.m4a" -o -iname "*.flac" -o -iname "*.aac" -o -iname "*.ogg" -o -iname "*.wav" -o -iname "*.mp4" -o -iname "*.mov" -o -iname "*.avi" -o -iname "*.mpg" -o -iname "*.mpeg" -o -iname "*.webm" -o -iname "*.mpv" -o -iname "*.mp2" -o -iname "*.wmv" -o -iname "*.mkv" \) -exec mv {} "$DIRECTORY_PATH/media" \; 2>/dev/null

  # Documents
  find "$DIRECTORY_PATH" -maxdepth 1 -type f \( -iname "*.pdf" -o -iname "*.txt" -o -iname "*.docx" -o -iname "*.xlsx" -o -iname "*.xls" -o -iname "*.odt" -o -iname "*.ods" -o -iname "*.pptx" -o -iname "*.csv" \) -exec mv {} "$DIRECTORY_PATH/documents" \; 2>/dev/null

  # Scripts
  find "$DIRECTORY_PATH" -maxdepth 1 -type f \( -iname "*.py" -o -iname "*.rb" -o -iname "*.sh" -o -iname "*.bash" -o -iname "*.pl" -o -iname "*.php" -o -iname "*.js" \) -exec mv {} "$DIRECTORY_PATH/scripts" \; 2>/dev/null

  # Compressed
  find "$DIRECTORY_PATH" -maxdepth 1 -type f \( -iname "*.rar" -o -iname "*.zip" -o -iname "*.tar.gz" -o -iname "*.tar.xz" -o -iname "*.7z" -o -iname "*.bz2" \) -exec mv {} "$DIRECTORY_PATH/compressed" \; 2>/dev/null

  # Other
  find "$DIRECTORY_PATH" -maxdepth 1 -type f ! \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.tif" -o -iname "*.tiff" -o -iname "*.bmp" -o -iname "*.gif" -o -iname "*.eps" -o -iname "*.raw" -o -iname "*.mp3" -o -iname "*.m4a" -o -iname "*.flac" -o -iname "*.aac" -o -iname "*.ogg" -o -iname "*.wav" -o -iname "*.mp4" -o -iname "*.mov" -o -iname "*.avi" -o -iname "*.mpg" -o -iname "*.mpeg" -o -iname "*.webm" -o -iname "*.mpv" -o -iname "*.mp2" -o -iname "*.wmv" -o -iname "*.mkv" -o -iname "*.pdf" -o -iname "*.txt" -o -iname "*.docx" -o -iname "*.xlsx" -o -iname "*.xls" -o -iname "*.odt" -o -iname "*.ods" -o -iname "*.pptx" -o -iname "*.csv" -o -iname "*.py" -o -iname "*.rb" -o -iname "*.sh" -o -iname "*.bash" -o -iname "*.pl" -o -iname "*.php" -o -iname "*.js" -o -iname "*.rar" -o -iname "*.zip" -o -iname "*.tar.gz" -o -iname "*.tar.xz" -o -iname "*.7z" -o -iname "*.bz2" -o -iname "*.exe" -o -iname "*.AppImage" -o -iname "*.deb" \) -exec mv {} "$DIRECTORY_PATH/other" \; 2>/dev/null

  # Applications
  find "$DIRECTORY_PATH" -maxdepth 1 -type f \( -iname "*.deb" -o -iname "*.exe" -o -iname "*.AppImage" \) -exec mv {} "$DIRECTORY_PATH/applications" \; 2>/dev/null

}



## Run backup functions
ORGANIZE_DOWNLOADS
GNOME_BINDS_BACKUP
DCONF_BACKUP
GNOME_EXTENSIONS_BACKUP
BACKUP_DEBIAN

sudo -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u $USERNAME)/bus notify-send -i /home/$USERNAME/Downloads/OIP.jpeg "System backup" "Backup finished" 

