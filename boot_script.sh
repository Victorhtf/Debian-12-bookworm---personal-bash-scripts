#!/bin/bash

DUMP_FOLDER="dump"
BACKUP_FOLDER="Backups"

## Notify user about the running script ##
notify-send "Starting boot script..." "Making backups..."

# Save gnome-keybinds in conf file ##
gsettings list-recursively org.gnome.desktop.wm.keybindings >> "/home/$USER/$BACKUP_FOLDER/conf/keyboard-binds.conf"
echo "Configurações de atalhos de teclado salvas em: /home/$USER/$BACKUP_FOLDER/conf/keyboard-binds.conf"

## Save all settings in a conf file ##
dconf dump / >> "/home/$USER/$BACKUP_FOLDER/conf/dconf-general-settings.ini"
echo "Configurações DCONF salvas em: /home/$USER/$BACKUP_FOLDER/conf/dconf-general-settings.ini"

## Save downloaded gnome-extensions list in txt file file ##
ls ~/.local/share/gnome-shell/extensions >> "/home/$USER/$BACKUP_FOLDER/conf/gnome-extensions-list.txt"
echo "Lista de extensões do GNOME salvas em: /home/$USER/$BACKUP_FOLDER/conf/gnome-extensions-list.txt"

notify-send 'Script finished...'
