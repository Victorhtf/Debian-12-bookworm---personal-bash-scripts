#!/bin/bash

echo 'Starting script...'

## Notify user about the running script ##
notify-send "Starting boot scripts..." "Iniciando boot script"


# Save gnome-keybinds in txt file ##
gsettings list-recursively org.gnome.desktop.wm.keybindings > /home/victorhtf/Other/conf/keyboard-binds.txt


## Save downloaded gnome-extensions list in txt file file ##
ls ~/.local/share/gnome-shell/extensions >> /home/$USER/Other/conf/gnome-extensions-list.txt 


## Save all settings in a txt file ##
dconf dump / > /home/victorhtf/Other/conf/dconf-general-settings.ini


## Save remaining changes in txt file
gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings >> /home/$USER/Other/conf/gsettings-keybinds-list.txt 


## Making Scripts folder backup ##
sudo mkdir -p /home/$USER/Other/scripts/  && sudo cp -r /home/$USER/Other/scripts/* /home/$USER/Backups/scripts/
sudo mkdir -p /home/$USER/Other/conf/ && sudo chmod -R ogu+wrx /home/$USER/Backups && sudo cp -r /home/$USER/Other/conf/* /home/$USER/Backups/conf/ 



echo 'Script finished...'


