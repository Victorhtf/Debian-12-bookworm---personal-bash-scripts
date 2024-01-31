#!/bin/bash
USERNAME='victorhtf'

## Variables setup ##
DOWNLOAD_DIRECTORY="$HOME/Downloads"
APPLICATIONS_DIRECTORY="$DOWNLOAD_DIRECTORY/applications"
BACKUP_DIRECTORY="$HOME/Backups"
DEBIAN_DIRECTORY="$HOME/Debian"
TEMPLATE_DIRECTORY="$HOME/Templates"
CONF_FILE_ORIGIN="$HOME/Downloads/Backup/home/$USERNAME/Backups/conf"
CONF_FILE_DESTINATION="$HOME/Debian/conf"
SCRIPTS_FILES_ORIGIN="$HOME/Downloads/Backup/home/$USERNAME/Backups/scripts"
SCRIPTS_FILE_DESTINATION="$HOME/Debian/scripts"


## Folders to create in /Backup/ ##
DIRECTORIES=(
  "$DEBIAN_DIRECTORY/conf"
  "$DEBIAN_DIRECTORY/scripts"
  "$DEBIAN_DIRECTORY/dump"
  "$HOME/Pictures/Wallpapers"
)

## Template files to insert in template folder ##
TEMPLATES=(
  "Text-file.txt"
  "Bash-script.sh"
  "Sheets-file.xlsx"
  "CSV-file.csv"
  "Document-file.docx"
)

KEYBIND_CONFIG_FILE="$DEBIAN_DIRECTORY/conf/keyboard-binds.conf"


## Git config ##
GIT_NAME="Victor Formisano"
GIT_EMAIL="victorformisano10@gmail.com"

## External link to applications ##
EDGE_REPO="https://go.microsoft.com/fwlink?linkid=2149051&brand=M102.deb"
VSCODE_REPO="https://vscode.download.prss.microsoft.com/dbazure/download/stable/0ee08df0cf4527e40edc9aa28f4b5bd38bbff2b2/code_1.85.1-1702462158_amd64.deb"
RUNDECK_REPO="https://packagecloud.io/pagerduty/rundeck/packages/any/any/rundeck_5.0.1.20240115-1_all.deb/download.deb?distro_version_id=35"  
STEAM_REPO="https://cdn.akamai.steamstatic.com/client/installer/steam.deb"
TELEGRAM_REPO="https://telegram.org/dl/desktop/linux"
WPS_REPO="https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11711/wps-office_11.1.0.11711.XA_amd64.deb"


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
  python3-launchpadlib
  openjdk-11-jre-headless
  software-properties-common
  gimp
  gdebi
  net-tools
  gparted
  wine
  git
  gnome-shell-extension-manager
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
  flathub org.localsend.localsend_app
  org.bluesabre.MenuLibre
  com.github.flxzt.rnote
  com.mattjakeman.ExtensionManager
  io.github.realmazharhussain.GdmSettings
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
  john-the-ripper
)


## Print success message in green ##
print_success() {
  echo -e "${GREEN}[OK] - $1${NC}\n\n"
}

## Print info message in orange ##
print_info() {
  echo -e "${ORANGE}[INFO] - $1${NC}"
}

## Print error message in red ##
print_error() { 
  echo -e "${RED}[ERROR] - $1${NC}\n\n"
}



## Verify root permissions ##
verify_root() {
  print_info "Verifying root permissions..."
  if [ "$EUID" -ne 0 ]; then
    print_info "Please run this script as root."
  fi
}

## Removing APT locks ##
remove_apt_locks() {
  print_info "Removing APT locks..."
  
  # Check and remove /var/lib/apt/lists/lock
  if [ -f /var/lib/apt/lists/lock ]; then
    sudo rm /var/lib/apt/lists/lock
    print_success "Removed /var/lib/apt/lists/lock."
  else
    print_info "/var/lib/apt/lists/lock does not exist."
  fi

  # Check and remove /var/cache/apt/archives/lock
  if [ -f /var/cache/apt/archives/lock ]; then
    sudo rm /var/cache/apt/archives/lock
    print_success "Removed /var/cache/apt/archives/lock."
  else
    print_info "/var/cache/apt/archives/lock does not exist."
  fi

  # Check and remove /var/lib/dpkg/lock
  if [ -f /var/lib/dpkg/lock ]; then
    sudo rm /var/lib/dpkg/lock
    print_success "Removed /var/lib/dpkg/lock."
  else
    print_info "/var/lib/dpkg/lock does not exist."
  fi

  # Check and remove /var/lib/dpkg/lock-frontend
  if [ -f /var/lib/dpkg/lock-frontend ]; then
    sudo rm /var/lib/dpkg/lock-frontend
    print_success "Removed /var/lib/dpkg/lock-frontend."
  else
    print_info "/var/lib/dpkg/lock-frontend does not exist."
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


## Updating repositories ##
external_repositories() {
  # Debian repositories
  deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
  deb-src http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware

  deb http://deb.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
  deb-src http://deb.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware

  deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
  deb-src http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware

}

## Update system ##
update_system() {
  print_info "Updating system..."
  sudo apt-get update && sudo apt-get upgrade -y
  print_success "System updated successfully."
}

## Removing GNOME Games ##
remove_games() {
  print_info "Removing GNOME games..."
  sudo apt purge iagno lightsoff four-in-a-row gnome-robots pegsolitaire gnome-2048 hitori gnome-klotski gnome-mines gnome-mahjongg gnome-sudoku quadrapassel swell-foop gnome-tetravex gnome-taquin aisleriot gnome-chess five-or-more gnome-nibbles tali -y ; sudo apt autoremove
  print_success "Games uninstalled with success"
}

remove_libreoffice() {
  print_info "Removing Libreoffice apps..."
  sudo apt-get remove --purge "libreoffice*" -y
    print_success "Libreoffice apps successfully uninstalled"

}



## Creating Folders and giving permissions to access ##
create_folders() {
  print_info "Creating folders..."
  for dir in "${DIRECTORIES[@]}"; do
    mkdir -p "$dir"
    chmod 775 "$dir"
    print_success "Folder successfully created: $dir"
  done
}


copy_config_files() {
  print_info "Copying CONF files..."
  cp -r "$CONF_FILE_ORIGIN/." "$CONF_FILE_DESTINATION"
  print_success "CONF files copied successfully."
}

copy_scripts_files() {
  print_info "Copying SCRIPTS files..."
  cp -r "$SCRIPTS_FILES_ORIGIN/." "$SCRIPTS_FILE_DESTINATION"
  print_success "SCRIPTS files copied successfully."
}



## Creating bash aliases link ##
create_bash_aliases_link() {
  print_info "Creating bash aliases link..."
  print_info -e "\nif [ -f ~/.bash_aliases ]; then\n    . ~/.bash_aliases\nfi" >> ~/.bashrc
  print_success "Bash aliases link created successfully."
}

## Create templates ##
create_templates() {
  print_info "Creating files templates..."

  for template in "${TEMPLATES[@]}"; do
    touch "$TEMPLATE_DIRECTORY/$template"
  done

  print_success "Templates criados com sucesso em $TEMPLATE_DIRECTORY."
}



## Install repository packages ##
install_apt_packages() {
  print_info "Installing APT packages..."
  sudo apt --fix-broken install -y

  for package in "${APT_PACKAGES[@]}"; do
    sudo apt install $package -y
    print_success "Package $package installed successfully." || print_error "Error installing package $package"
  done
}


## Install snapd ##
install_snapd() {
  print_info "Installing Snap package management tools..."
  sudo apt-get update
  sudo apt-get install snapd -y
  print_success "Snap installed successfully."
}


## Install Flatpak packages ##
install_flatpak() {
  print_info "Installing Flatpak packages..."
  sudo apt install flatpak -y
  sudo flatpak remote-add --if-not-exists  flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  sudo flatpak install flathub ${FLATPAK_PACKAGES[@]} -y
  print_success "Flatpak packages installed successfully."

  if ! command -v flatpak &> /dev/null; then
    print_error "Flatpak not installed. Please check the installation."
  fi
}



## Install Snap packages ## 
install_snaps() {
    for package in "${SNAP_PACKAGES[@]}"; do
        if ! snap list "$package" >/dev/null 2>&1; then
            print_success "Installing $package..."
            sudo snap install "$package" --classic
        else
            print_info "$package is already installed."
        fi
    done
}



## Download external applications ##
install_external_applications() {
  print_info "Downloading external applications..."

  mkdir -p "$APPLICATIONS_DIRECTORY"
  cd "$APPLICATIONS_DIRECTORY"

  wget -c "$EDGE_REPO" -P "$APPLICATIONS_DIRECTORY"
  wget -c "$VSCODE_REPO" -P "$APPLICATIONS_DIRECTORY"
  wget -c "$TELEGRAM_REPO" -P "$APPLICATIONS_DIRECTORY"
  wget -c "$STEAM_REPO" -P "$APPLICATIONS_DIRECTORY"
  wget -c "$WPS_REPO" -P "$APPLICATIONS_DIRECTORY"
  

  # Check if any .deb files are present before attempting installation
  deb_files=("$APPLICATIONS_DIRECTORY"/*.deb)
  if [ ${#deb_files[@]} -gt 0 ]; then
    sudo dpkg -i --refuse-downgrade "${deb_files[@]}" || sudo apt --fix-broken install -y
    print_success "External applications downloaded and installed successfully."
  else
    print_error "No .deb files found in $APPLICATIONS_DIRECTORY."
  fi
}


## Install Wine ##
install_wine() {
  print_info "Installing wine..."
  sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
  sudo apt update
  sudo apt install --install-recommends winehq-stable
  print_success "Wine installed successfully."
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

  sudo groupadd docker
  sudo usermod -aG docker $USER
  
  print_success "Docker installed successfully."
}


## Install PuTTY ##
install_putty() {
  print_info "Installing PuTTY..."
  sudo apt-get install -y putty
  if ! command -v putty &> /dev/null; then
    print_error "PuTTY installation failed. Please check the installation."
  else
    print_success "PuTTY installed successfully."
  fi
}



## Install Spotify ##
install_spotify() {
  print_info "Installing Spotify..."

  curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
  echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

  sudo apt-get update && sudo apt-get install spotify-client


  print_success "Spotify installed successfully."
}


## Setup aliases in ~/.bashrc ##
setup_aliases() {
  echo "Setting up bash aliases"
  echo 'alias ..="cd .."' >> ~/.bashrc
  echo 'alias aliasconf="code ~/.bash_aliases"' >> ~/.bashrc
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
    while IFS=' ' read -r schema path key value; do
      # Verifica se a chave é uma lista
      if [[ "$value" =~ ^\[.*\]$ ]]; then
        # Remove os colchetes da lista e converte para array
        value=$(echo "$value" | sed 's/^\[\(.*\)\]$/\1/' | tr ',' '\n')
        value=($value)
        # Configura cada valor da lista
        for val in "${value[@]}"; do
          gsettings set "$schema" "$key" "$val"
        done
      else
        gsettings set "$schema" "$key" "$value"
      fi
    done < "$KEYBIND_CONFIG_FILE"

    print_success "Keyboard binds configured successfully."
  else
    print_error "Error: Configuration file not found in: $KEYBIND_CONFIG_FILE"
  fi
}


## Setup DCONF settings ##
dconf_setup() {
  print_info "Setting up DCONF..."
  dconf load / < $DEBIAN_DIRECTORY/conf/dconf-general-settings.ini
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
      sudo reboot
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

# verify_root
# sudo_user
# remove_apt_locks
# update_system
# remove_games
# remove_libreoffice
# create_templates 
# create_folders
# copy_config_files
# copy_scripts_files
# create_bash_aliases_link
# install_external_applications
# install_apt_packages
# install_putty
install_flatpak
# install_snapd
# install_snaps
# install_docker
# install_spotify
# setup_aliases
# setup_gitcredentials
# setup_keybinds
# dconf_setup
# setup_gnomesettings
# finish_setup

