#!/bin/bash

USERNAME=victorhtf

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


## Save gnome-keybinds in conf file ##
GNOME_BINDS_BACKUP() {
    print_info "Saving gnome-keybinds to $CONF_FOLDER/keyboard-binds.conf..."
    sudo -u $USERNAME gsettings list-recursively org.gnome.desktop.wm.keybindings >> "$CONF_FOLDER/keyboard-binds.conf"
    print_success "Keyboard binds configuration saved successfully."
}

## Save all settings in a conf file ##
DCONF_BACKUP() {
    print_info "Saving DCONF settings to $CONF_FOLDER/dconf-general-settings.ini..."
    sudo -u $USERNAME dconf dump / >> "$CONF_FOLDER/dconf-general-settings.ini"
    print_success "DCONF settings saved successfully."
}

## Save downloaded gnome-extensions list in txt file file ##
GNOME_EXTENSIONS_BACKUP() {
    print_info "Saving GNOME extensions list to $DUMP_FOLDER/gnome-extensions-list.txt..."
    sudo -u $USERNAME ls /home/$USERNAME/.local/share/gnome-shell/extensions >> "$DUMP_FOLDER/gnome-extensions-list.txt"
    print_success "GNOME extensions list saved successfully."
}

## Backup Debian folder ##
BACKUP_DEBIAN() {
    print_info "Copying Debian folder from /home/$USERNAME/ to $BACKUP_FOLDER/"
    cp -r "/home/$USERNAME/Debian" "$BACKUP_FOLDER"
    print_success "Scripts backed up successfully."
}

## Backup Wallpaper folder ##
BACKUP_WALLPAPERS() {
    print_info "Copying Wallpapers folder from /home/$USERNAME/ to $BACKUP_FOLDER/"
    cp -r "/home/$USERNAME/Pictures/Wallpapers" "$BACKUP_FOLDER"
    print_success "Wallpapers backed up successfully."
}


