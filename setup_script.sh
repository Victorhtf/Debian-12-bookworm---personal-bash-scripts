#!/bin/bash

## Setup variables
DESKTOP_DIRECTORY="/home/$USER/'Área de Trabalho'"
BACKUP_DIRECTORY="/home/victorhtf/Backups"
DOWNLOAD_DIRECTORY="/home/$USER/Downloads/Programas"

GIT_NAME="Victor Formisano"
GIT_EMAIL="victorformisano10@gmail.com"

EDGE_REPO=https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/microsoft-edge-stable_119.0.2151.97-1_amd64.deb
VSCODE_REPO=https://vscode.download.prss.microsoft.com/dbazure/download/stable/0ee08df0cf4527e40edc9aa28f4b5bd38bbff2b2/code_1.85.1-1702462158_amd64.deb
SPOTIFY_REPO=

APT_PACKAGES='
  aircrack-ng
  btop
  cmatrix
  ffmpeg
  fdisk
  flatpak
  snapd
  gimp
  gdebi
  git
  gnome-boxes
  gnome-sushi
  gnome-tweaks
  ncdu
  gnome-tweak-tool
  neofetch
  netbase
  net-tools
  netcat
  npm
  onedriver
  wget
  vlc
  wireless-tools
  safeeyes
  firmware-adm-graphics
  firmware-linux
  firmware-linux-nonfree
  java-commom
  python3'

$FLATPAK_PACKAGES='
  nl.hjdskes.gcolor3
  org.telegram.desktop
  io.github.lainsce.Colorway
  io.dbeaver.DBeaverCommunity
  com.rafaelmardojai.Blanket
  com.github.tchx84.Flatseal
  com.github.rajsolai.textsnatcher
  com.github.calo001.fondo
  org.librehunt.Organizer'

$SNAP_PACKAGES='
  notion-snap-reborn
  todoist
  postman
  john-the-riper'


internet_test(){
if ! ping -c 1 8.8.8.8 -q &> /dev/null; then
  echo -e "${VERMELHO}[ERROR] - Verify internet connection.${SEM_COR}"
  exit 1
else
  echo -e "${VERDE}[INFO] - Internet ok.${SEM_COR}"
fi
}


## Verify root permissions ##
verify_root() {
  if [ "$USER" -ne 0 ]; then
    echo "Por favor, execute este script como root."
    exit 1
  fi
}


## Update system ##
update_system() {
  apt update
  apt upgrade -y
}

rename_desktop() {
  if [ -d "$DESKTOP_DIRECTORY" ]; then
    new_name="Desktop"
    mv "$DESKTOP_DIRECTORY" "/home/$USER/$new_name"
    echo "Desktop directory changed to $new_name."
  else
    echo "Desktop directory not found."
  fi
}


## Creating Folders and giving permissions to access ##
sudo mkdir -p /home/$USER/Other/conf/ /home/$USER/Other/scripts/ && sudo chmod -R ogu+wrx /home/$USER/Other
sudo mkdir -p /home/$USER/Backups/conf/ /home/$USER/Backups/scripts/ && sudo chmod -R ogu+wrx /home/$USER/Backups


## Change Desktop folder name ##
rename_desktop() {
  if [ -d "$DESKTOP_DIRECTORY" ]; then
    new_name="Desktop"
    mv "$DESKTOP_DIRECTORY" "/home/$USER/$new_name"
    echo "Desktop directory changed to $new_name."
  else
    echo "Desktop directory not found."
  fi
}


## Creating bash aliases link ##
create_bash_aliases_link() {
  echo -e "\nif [ -f ~/.bash_aliases ]; then\n    . ~/.bash_aliases\nfi" >> ~/.bashrc
}


## Download external aplications ##
install_external_applications() {
  mkdir  $DOWNLOAD_DIRECTORY
  cd     $DOWNLOAD_DIRECTORY

  wget -c $EDGE_REPO       -P $DOWNLOAD_DIRECTORY
  wget -c $SPOTIFY_REPO    -P $DOWNLOAD_DIRECTORY
  # wget -c $VSCODE          -P $DOWNLOAD_DIRECTORY

  sudo dpkg -i *.deb
}


## Install repository packages ##
install_packages() {
  apt install -y "${APT_PACKAGES[@]}"
}


## Install Flatpak packages ##
install_flatpak() {
  flatpak install flathub $FLATPAK_PACKAGES -y
}


## Install Snap packages ## 
install_snaps() {
  snap install $SNAP_PACKAGES
}


## Install Docker ## 
apt-get update
apt-get install ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


# Install Spotify
curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

sudo apt-get update && sudo apt-get install spotify-client

# Setup aliases in ~/.bashrc ##
setup_aliases() {
  alias ..='cd ..' >> ~/.bashrc
  alias "aliasconf='code ~/.bash_aliases'" >> ~/.bashrc
  echo "alias cdd='cd /home/victorhtf/Desktop'" >> ~/.bashrc
  echo "alias dir='dir --color=auto'" >> ~/.bashrc
  echo "alias dup='docker up'" >> ~/.bashrc
  echo "alias duprb='docker compose up -d --force-recreate --build'" >> ~/.bashrc
  echo "alias egrep='egrep --color=auto'" >> ~/.bashrc
  echo "alias fgrep='fgrep --color=auto'" >> ~/.bashrc
  echo "alias fh='history|grep'" >> ~/.bashrc
  echo "alias fp='apt list -i | grep'" >> ~/.bashrc
  echo "alias grep='grep --color=auto'" >> ~/.bashrc
  echo "alias ips='ip -c -br a'" >> ~/.bashrc
  echo "alias la='ls -la'" >> ~/.bashrc
  echo "alias ll='ls -l'" >> ~/.bashrc
  echo "alias ls='ls --color=auto'" >> ~/.bashrc
  echo "alias matrix='cmatrix'" >> ~/.bashrc
  echo "alias mkdir='mkdir -pv'" >> ~/.bashrc
  echo "alias nf='neofetch'" >> ~/.bashrc
  echo "alias open='xdg-open .'" >> ~/.bashrc
  echo "alias ports='sudo netstat -tulanp'" >> ~/.bashrc
  echo "alias su='su -'" >> ~/.bashrc
  echo "alias upd='sudo apt update && sudo apt upgrade -y'" >> ~/.bashrc
  echo "alias ll='ls -al'" >> ~/.bashrc
  echo "alias atualizar='sudo apt update && sudo apt upgrade -y'" >> ~/.bashrc
}


# Setup keyboard binds ##
setup_keybinds() {
  cd "$BACKUP_DIRECTORY"
  gsettings list-recursively org.gnome.desktop.wm.keybindings | \
    while IFS= read -r line; do
      gsettings set $line
    done
}


## Setup Git credentials ##
setup_gitcredentials() {
  git config --global user.name "$GIT_NAME"
  git config --global user.email "$GIT_EMAIL"
}

## Setup Gnome minimize button in windows ##
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,close"

## Setup DCONF settings ##
dconf load / < dconf-settings.ini


## Finishing script... ##
finish_setup() {
  apt update && apt dist-upgrade -y
  flatpak update
  apt autoclean
  apt autoremove -y
  echo "Setup finished..."
  echo "Rebooting system..."
  reboot
}


# Starting functions
internet_test
verify_root
update_system
install_external_applications
install_packages
install_flatpak
install_snaps
setup_aliases
setup_keybinds
rename_desktop
setup_gitcredentials
finish_setup
gnome-session-properties