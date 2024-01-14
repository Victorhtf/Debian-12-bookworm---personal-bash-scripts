#!/bin/bash

## Variables setup ##
USERNAME='victorhtf'
DESKTOP_DIRECTORY="$HOME/'Área de Trabalho'"
DOWNLOAD_DIRECTORY="$HOME/Downloads"
APPLICATIONS_DIRECTORY="$HOME/$DOWNLOAD_DIRECTORY/applications"
BACKUP_DIRECTORY="$HOME/Backups"
DEBIAN_DIRECTORY="$HOME/Debian"
MODEL_DIRECTORY="$HOME/$USERNAME/Models"


## Folders to create in /Backup/ ##
BACKUP_DIRECTORIES=(
  "$DEBIAN_DIRECTORY/.conf"
  "$DEBIAN_DIRECTORY/scripts"
  "$DEBIAN_DIRECTORY/dump"
)

## Models files to insert in Models folder ##
MODELS=(
  ".txt"
  ".sh"
  ".xlsx"
  ".csv"
  ".docx"
)

KEYBIND_CONFIG_FILE="$HOME/$USERNAME/$BACKUP_DIRECTORY/conf/keyboard-binds.conf"


## Git config ##
GIT_NAME="Victor Formisano"
GIT_EMAIL="victorformisano10@gmail.com"

## External link to applications ##
EDGE_REPO="https://go.microsoft.com/fwlink?linkid=2149051&brand=M102"
VSCODE_REPO="https://code.visualstudio.com/docs/?dv=linux64_deb"
SPOTIFY_REPO=


## Terminal colors ##
GREEN='\033[0;32m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m'

APT_PACKAGES=(
  dbus
  aircrack-ng
  btop
  cmatrix
  ffmpeg
  fdisk
  gimp
  gdebi
  git
  gnome-boxes
  gnome-sushi
  gnome-tweaks
  ncdu
  neofetch
  netbase
  net-tools
  netcat
  npm
  wget
  vlc
  wireless-tools
  safeeyes
  firmware-amd-graphics
  firmware-linux
  firmware-linux-nonfree
  python3
  )

FLATPAK_PACKAGES=(
  nl.hjdskes.gcolor3
  org.telegram.desktop
  com.github.flxzt.rnote
  com.stremio.Stremio
  io.github.lainsce.Colorway
  io.dbeaver.DBeaverCommunity
  com.rafaelmardojai.Blanket
  com.github.tchx84.Flatseal
  com.github.rajsolai.textsnatcher
  com.github.calo001.fondo
  org.librehunt.Organizer
  )

SNAP_PACKAGES=(
  notion-snap-reborn
  todoist
  postman
  john-the-riper
  )


## Print success message in green ##
print_success() {
  echo -e "${GREEN}[OK] - $1${NC}"
}

## Print info message in orange ##
print_info() {
  echo -e "${ORANGE}[INFO] - $1${NC}"
}

## Print error message in red ##
print_error() { 
  echo -e "${RED}[ERROR] - $1${NC}"
}

## Removing APT locks ##
remove_apt_locks() {  
  sudo rm /var/lib/dpkg/lock-frontend
  sudo rm /var/cache/apt/archives/lock
}

## Verify root permissions ##
verify_root() {
  print_info "Verifying root permissions..."
  if [ "$EUID" -ne 0 ]; then
    print_info "Please run this script as root."
    exit 1
  fi
}


## Add the input user to sudoers file ##
sudo_user() {
  print_info "Adding user to sudoers file..."
  
  if ! grep -q "$USERNAME ALL=(ALL:ALL) ALL" /etc/sudoers; then
    echo "$USERNAME ALL=(ALL:ALL) ALL" >> /etc/sudoers
    print_success "User $USERNAME added to sudo group successfully."
  else
    print_info "User $USERNAME is already in sudoers file."
  fi
}


## Testing internet connection ##
internet_test() {
  print_info "Checking internet connection..."

  if ! curl -sSf http://www.google.com >/dev/null; then
    print_error "[ERROR] - Internet connection not available."
    exit 1
  else
    print_success "[INFO] - Internet connection is okay."
  fi
}

## Updating repositories ##
external_repositories() {
  # Debian repositories
  deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
  deb-src http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware

  deb http://deb.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
  deb-src http://deb.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware

  deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
  deb-src http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware

  #Colocar aqui todos os outros repositórios que estão no resto do código
}

## Update system ##
update_system() {
  print_info "Updating system..."

  sudo apt update && apt upgrade -y
  print_success "System updated successfully."
}

## Removing GNOME Games ##
remove_games() {
  print_info "Removing GNOME games..."
  sudo apt purge iagno lightsoff four-in-a-row gnome-robots pegsolitaire gnome-2048 hitori gnome-klotski gnome-mines gnome-mahjongg gnome-sudoku quadrapassel swell-foop gnome-tetravex gnome-taquin aisleriot gnome-chess five-or-more gnome-nibbles tali ; sudo apt autoremove
  print_success "MOSTRAR AQUI O NOME DE CADA APP DESINSTALADO"
}

remove_libreoffice() {
  print_info "Removing Libreoffice apps..."
  sudo apt-get remove --purge "libreoffice*"
    print_success "Libreoffice apps successfully uninstalled"

}


general_settings() {
  print_info "Settings general configs..."

  cd conf
  cp keyboard-binds.conf /home/$USERNAME/.config/
}


## Creating Folders and giving permissions to access ##
folders_create() {
  print_info "Creating folders..."
  for dir in "${DIRECTORIES[@]}"; do
    mkdir -p "$dir"
    print_success "Folder successfully created: $dir"
  done
}


## Change Desktop folder name ##
rename_desktop() {
  print_info "Changing desktop folder name..."

  if [ -d "$DESKTOP_DIRECTORY" ]; then
    new_name="Desktop"
    mv "$DESKTOP_DIRECTORY" "/home/$USER/$new_name"
    print_success "Desktop directory changed to $new_name."
  else
    print_error "Desktop directory not found."
  fi
}


## Creating bash aliases link ##
create_bash_aliases_link() {
  print_info "Creating bash aliases link..."
  print_info -e "\nif [ -f ~/.bash_aliases ]; then\n    . ~/.bash_aliases\nfi" >> ~/.bashrc
  print_success "Bash aliases link created successfully."
}

## Create Models ##
create_models() {
  print_info "Creating files models..."

  for model in "${MODELS[@]}"; do
    touch "$MODEL_DIRECTORY/$model"
  done

  print_success "Modelos criados com sucesso em $MODEL_DIRECTORY."
}



## Install repository packages ##
install_apt_packages() {
  print_info "Installing APT packages..."
  sudo apt --fix-broken install -y

  for package in "${APT_PACKAGES[@]}"; do
    print_success "Package $package installed successfully." || print_error "Error installing package $package"
  done
}



## Install Flatpak packages ##
install_flatpak() {
  print_info "Installing Flatpak packages..."
  sudo apt install flatpak -y
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  flatpak install flathub ${FLATPAK_PACKAGES[@]} -y
  print_success "Flatpak packages installed successfully."

  if ! command -v flatpak &> /dev/null; then
    print_error "Flatpak not installed. Please check the installation."
    exit 1
  fi
}



## Install Snap packages ## 
install_snapd() {
  print_info "Installing Snapd..."
  sudo apt install snapd -y
  sudo snap install "${SNAP_PACKAGES[@]}"
  print_success "Snap packages installed successfully."
}


## Download external applications ##
install_external_applications() {
  print_info "Downloading external applications..."

  mkdir -p "$APPLICATIONS_DIRECTORY"
  cd "$APPLICATIONS_DIRECTORY"

  wget -c "$EDGE_REPO" -P "$APPLICATIONS_DIRECTORY"

  wget -c "$VSCODE_REPO" -P "$APPLICATIONS_DIRECTORY"

  sudo dpkg -i --refuse-downgrade *.deb || apt --fix-broken install -y
  print_success "External applications downloaded and installed successfully."
}



## Install Docker ## 
install_docker() {
  print_info "Installing Docker..."
  sudo apt-get update
  sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  print_success "Docker installed successfully."
}


## Install PuTTY ##
install_putty() {
  print_info "Installing PuTTY..."
  sudo apt-get install -y putty
  if ! command -v putty &> /dev/null; then
    print_error "PuTTY installation failed. Please check the installation."
    exit 1
  else
    print_success "PuTTY installed successfully."
  fi
}



## Install Spotify ##
install_spotify() {
  print_info "Installing Spotify..."

  curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg

  echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list > /dev/null

  sudo apt-get update && sudo apt-get install spotify-client

  print_success "Spotify installed successfully."
}



## Setup aliases in ~/.bashrc ##
setup_aliases() {
  echo "Setting up bash aliases"
  echo 'alias ..="cd .."' >> ~/.bashrc
  echo 'alias aliasconf="code ~/.bash_aliases"' >> ~/.bashrc
  echo 'alias cdd="cd /home/victorhtf/Desktop"' >> ~/.bashrc
  echo 'alias dir="dir --color=auto"' >> ~/.bashrc
  echo 'alias dup="docker up"' >> ~/.bashrc
  echo 'alias duprb="docker compose up -d --force-recreate --build"' >> ~/.bashrc
  echo 'alias egrep="egrep --color=auto"' >> ~/.bashrc
  echo 'alias fgrep="fgrep --color=auto"' >> ~/.bashrc
  echo 'alias fh="history|grep"' >> ~/.bashrc
  echo 'alias fp="apt list -i | grep"' >> ~/.bashrc
  echo 'alias grep="grep --color=auto"' >> ~/.bashrc
  echo 'alias ips="ip -c -br a"' >> ~/.bashrc
  echo 'alias la="ls -la"' >> ~/.bashrc
  echo 'alias ll="ls -l"' >> ~/.bashrc
  echo 'alias ls="ls --color=auto"' >> ~/.bashrc
  echo 'alias matrix="cmatrix"' >> ~/.bashrc
  echo 'alias mkdir="mkdir -pv"' >> ~/.bashrc
  echo 'alias nf="neofetch"' >> ~/.bashrc
  echo 'alias open="xdg-open ."' >> ~/.bashrc
  echo 'alias ports="sudo netstat -tulanp"' >> ~/.bashrc
  echo 'alias su="su -"' >> ~/.bashrc
  echo 'alias upd="sudo apt update && sudo apt upgrade -y"' >> ~/.bashrc
  echo 'alias ll="ls -al"' >> ~/.bashrc
  echo 'alias atualizar="sudo apt update && sudo apt upgrade -y"' >> ~/.bashrc

  echo "Bash aliases set up successfully."
}



## Setup Git credentials ##
setup_gitcredentials() {
  print_info "Setting up Git credentials..."
  git config --global user.name "$GIT_NAME"
  git config --global user.email "$GIT_EMAIL"
  print_success "Git credentials configured successfully."
}


## Setup keyboard binds ##
setup_keybinds() {

  print_info "Setting up keybinds..."

  if [ -f "$KEYBIND_CONFIG_FILE" ]; then
    while IFS= read -r line; do
      gsettings set $line
    done < "$KEYBIND_CONFIG_FILE"

    print_success "Keyboard binds configured successfully."
  else
    print_error "Error: Configuration file not found in: $CONFIG_FILE"
    exit 1
  fi
}


## Setup DCONF settings ##
dconf_setup() {
  print_info "Setting up DCONF..."
  dconf load / < $BACKUP_DIRECTORY/conf/dconf-general-settings.ini
  print_success "DCONF settings configured successfully."
}

## Setup GNOME minimize button in windows ##
setup_gnomesettings() {
  print_info "Setting up minimize button in GNOME interface..."
  gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,close"
  print_success "GNOME minimize button set up successfully."
}


## Function to finish setup ##
finish_setup() {
  print_info "Finishing setup..."

  apt update && apt dist-upgrade -y
  flatpak update
  apt autoclean
  apt autoremove -y
  print_success "Setup finished successfully."

  read -p "The setup is complete. Do you want to reboot the system now? (y/n): " choice
  case "$choice" in 
    y|Y ) 
      print_success "Rebooting system..."
      reboot
      ;;
    n|N ) 
      print_info "Not rebooting. Your system will not be affected until the next restart."
      ;;
    * ) 
      print_info "Invalid choice. The system will not be rebooted."
      ;;
  esac
}


# Starting functions
# remove_apt_locks
# verify_root
# sudo_user
# internet_test
# update_system
# remove_games
# remove_libreoffice
# general_settings
# create_models
# folders_create
# rename_desktop
# create_bash_aliases_link
# install_external_applications
# install_apt_packages
# install_putty
# install_flatpak
# install_snaps
# install_docker
# install_spotify
# setup_aliases
# setup_gitcredentials
# setup_gnomesettings
# setup_keybinds
# dconf_setup
# finish_setup
# gnome-session-properties