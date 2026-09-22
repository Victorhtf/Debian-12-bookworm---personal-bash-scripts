#!/bin/bash
USERNAME='victorhtf'

## Diretorio onde este script (e os arquivos que o acompanham) estao ##
## Assim os arquivos do repo sao encontrados de onde quer que o script rode ##
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

## Resolve o usuario/HOME REAIS mesmo se o script for rodado com sudo.
## Sem isso, com 'sudo' o $HOME vira /root e os arquivos/config iriam para
## o usuario errado. Preferimos configurar como o usuario que chamou o sudo.
if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
  USERNAME="$SUDO_USER"
else
  USERNAME="$(id -un)"
fi
USER_HOME="$(getent passwd "$USERNAME" | cut -d: -f6)"
USER_HOME="${USER_HOME:-$HOME}"

## Variables setup ##
DOWNLOAD_DIRECTORY="$USER_HOME/Downloads"
APPLICATIONS_DIRECTORY="$DOWNLOAD_DIRECTORY/applications"
BACKUP_DIRECTORY="$USER_HOME/Backups"
DEBIAN_DIRECTORY="$USER_HOME/debian"
TEMPLATE_DIRECTORY="$USER_HOME/Templates"

## Origem: pastas dentro do proprio repositorio clonado ##
REPO_SCRIPTS_DIR="$SCRIPT_DIR/scripts"
REPO_ASSETS_DIR="$SCRIPT_DIR/assets"

## Destino: pasta padrao de scripts e de configuracoes ##
CONF_FILE_DESTINATION="$DEBIAN_DIRECTORY/conf"
SCRIPTS_FILE_DESTINATION="$DEBIAN_DIRECTORY/scripts"


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

## Keybinds em formato dconf load (mantido na pasta assets do repo) ##
KEYBIND_DCONF_FILE="$REPO_ASSETS_DIR/keybinds.dconf"


## Git config ##
GIT_NAME="Victor Formisano"
GIT_EMAIL="victorformisano10@gmail.com"

## External link to applications ##
EDGE_REPO="https://go.microsoft.com/fwlink?linkid=2149051&brand=M102.deb"
VSCODE_REPO="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
STEAM_REPO="https://cdn.akamai.steamstatic.com/client/installer/steam.deb"
# TELEGRAM_REPO="https://telegram.org/dl/desktop/linux"   # usar Flatpak (org.telegram.desktop)
# WPS_REPO="https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11711/wps-office_11.1.0.11711.XA_amd64.deb"   # nao uso mais


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
  fastfetch
  netbase
  net-tools
  netcat-openbsd
  nodejs
  npm
  wget
  vlc
  wireless-tools
  firmware-amd-graphics
  firmware-linux
  firmware-linux-nonfree
  python3

  # --- Essenciais (kit de sobrevivencia) ---
  curl
  ca-certificates
  gnupg
  apt-transport-https
  build-essential
  unzip
  zip
  vim
  tree
  jq
  rsync
  htop

  # --- Ferramentas modernas de terminal ---
  nala
  eza
  bat
  ripgrep
  fd-find
  zoxide
  fzf
  gdu
  tmux
  trash-cli

  # --- Rede / midia / desktop ---
  nmap
  flameshot
  yt-dlp
)

FLATPAK_PACKAGES=(
  org.telegram.desktop
  com.mattjakeman.ExtensionManager
  io.github.realmazharhussain.GdmSettings
  com.stremio.Stremio
  io.dbeaver.DBeaverCommunity
  com.rafaelmardojai.Blanket
  com.github.tchx84.Flatseal
  be.alexandervanhee.gradia
)

SNAP_PACKAGES=(
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
  deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
  deb-src http://deb.debian.org/debian trixie main contrib non-free non-free-firmware

  deb http://deb.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
  deb-src http://deb.debian.org/debian-security trixie-security main contrib non-free non-free-firmware

  deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
  deb-src http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware

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
  print_info "Copying CONF/asset files..."
  mkdir -p "$CONF_FILE_DESTINATION"

  if [ -d "$REPO_ASSETS_DIR" ]; then
    cp -r "$REPO_ASSETS_DIR/." "$CONF_FILE_DESTINATION"
    print_success "Asset files copied from repo to $CONF_FILE_DESTINATION."
  else
    print_error "Assets directory not found: $REPO_ASSETS_DIR"
  fi
}

copy_scripts_files() {
  print_info "Copying SCRIPTS files..."
  mkdir -p "$SCRIPTS_FILE_DESTINATION"

  if [ -d "$REPO_SCRIPTS_DIR" ]; then
    cp -r "$REPO_SCRIPTS_DIR/." "$SCRIPTS_FILE_DESTINATION"
    chmod +x "$SCRIPTS_FILE_DESTINATION"/*.sh 2>/dev/null
    print_success "SCRIPTS files copied from repo to $SCRIPTS_FILE_DESTINATION."
  else
    print_error "Scripts directory not found: $REPO_SCRIPTS_DIR"
  fi
}



## Creating bash aliases link ##
create_bash_aliases_link() {
  print_info "Creating bash aliases link..."
  # Só adiciona o bloco se ele ainda nao existir, evitando duplicatas a cada execucao
  if ! grep -q "if \[ -f ~/.bash_aliases \]" ~/.bashrc; then
    cat >> ~/.bashrc <<'EOF'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
EOF
  fi
  print_success "Bash aliases link created successfully."
}

## Create templates ##
create_templates() {
  print_info "Creating files templates..."
  mkdir -p "$TEMPLATE_DIRECTORY"

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
  wget -c "$STEAM_REPO" -P "$APPLICATIONS_DIRECTORY"
  # Telegram: instalado via Flatpak (org.telegram.desktop), nao aqui.
  # WPS desativado.

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

  # Habilita arquitetura i386 (o repo do WineHQ exige amd64 + i386)
  sudo dpkg --add-architecture i386

  # Baixa a CHAVE GPG do WineHQ para o caminho que o .sources referencia
  # (Signed-By: /etc/apt/keyrings/winehq-archive.key). Sem isso o repo fica
  # "not signed" e o apt recusa.
  sudo mkdir -p /etc/apt/keyrings
  sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

  # Baixa o arquivo de repositorio (.sources) para o trixie
  sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/trixie/winehq-trixie.sources

  sudo apt update
  if sudo apt install --install-recommends -y winehq-stable; then
    print_success "Wine installed successfully."
  else
    print_error "Falha ao instalar o Wine. Verifique a chave/repositorio do WineHQ."
  fi
}


## Install Docker ## 
install_docker() {
  print_info "Installing Docker..."
  sudo apt-get update
  sudo apt-get install -y apt-transport-https ca-certificates curl
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  sudo groupadd -f docker
  sudo usermod -aG docker $USER
  
  print_success "Docker installed successfully."
}


## Install Spotify ## (removido: nao uso mais)
# install_spotify() {
#   print_info "Installing Spotify..."
#
#   curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
#   echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
#
#   sudo apt-get update && sudo apt-get install spotify-client
#
#   print_success "Spotify installed successfully."
# }


## Setup aliases in ~/.bashrc ##
setup_aliases() {
  echo "Setting up bash aliases"

  # Se o bloco de aliases ja existir, remove antes de reescrever (idempotente)
  if grep -q "# >>> victor aliases >>>" ~/.bashrc; then
    sed -i '/# >>> victor aliases >>>/,/# <<< victor aliases <<</d' ~/.bashrc
  fi

  cat >> ~/.bashrc <<'EOF'
# >>> victor aliases >>>
alias ..="cd .."
alias aliasconf="code ~/.bash_aliases"
alias dup="docker up"
alias duprb="docker compose up -d --force-recreate --build"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"
alias fh="history|grep"
alias fp="apt list -i | grep"
alias ips="ip -c -br a"
alias matrix="cmatrix"
alias mkdir="mkdir -pv"
alias ff="fastfetch"
alias open="xdg-open ."
alias ports="sudo netstat -tulanp"
alias su="su -"
alias upd="sudo apt update && sudo apt upgrade -y"
alias atualizar="sudo apt update && sudo apt upgrade -y"

# Ferramentas modernas (nomes de binario do Debian diferem do comando usual)
alias ls="eza --icons --group-directories-first"
alias ll="eza -l --icons --group-directories-first"
alias la="eza -la --icons --group-directories-first"
alias tree="eza --tree --icons"
alias bat="batcat"
alias fd="fdfind"
alias rg="rg --smart-case"
alias grep="grep --color=auto"
alias tp="trash-put"
# zoxide: 'cd' inteligente (use 'z <pasta>')
eval "$(zoxide init bash)"
# fzf: atalhos (Ctrl-R historico, Ctrl-T arquivos) + completion.
# Metodo novo (fzf >= 0.48): gerencia o PROMPT_COMMAND corretamente e evita
# o vazamento de CPR (^[[..R) que ocorria com o source antigo do key-bindings.
command -v fzf >/dev/null && eval "$(fzf --bash)"
# <<< victor aliases <<<
EOF

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


## Setup keyboard binds via dconf load (gerado do gist pessoal) ##
setup_keybinds_dconf() {
  print_info "Setting up keybinds via dconf..."

  # Procura o keybinds.dconf: primeiro nos assets do repo, depois na pasta conf instalada
  local kb_file=""
  if [ -f "$REPO_ASSETS_DIR/keybinds.dconf" ]; then
    kb_file="$REPO_ASSETS_DIR/keybinds.dconf"
  elif [ -f "$CONF_FILE_DESTINATION/keybinds.dconf" ]; then
    kb_file="$CONF_FILE_DESTINATION/keybinds.dconf"
  fi

  if [ -n "$kb_file" ]; then
    dconf load / < "$kb_file"
    # Marca que este sistema ja recebeu as binds do repo. O backup agendado
    # so pode exportar/commitar depois que esta sentinela existir, evitando
    # que uma maquina recem-instalada sobrescreva o repo com um estado vazio.
    mkdir -p "$HOME/.config/debian-scripts"
    date '+%Y-%m-%dT%H:%M:%S%z' > "$HOME/.config/debian-scripts/.initialized"
    print_success "Keyboard binds (dconf) configured from: $kb_file"
  else
    print_error "Error: keybinds.dconf not found in $REPO_ASSETS_DIR nor $CONF_FILE_DESTINATION"
  fi
}


## Setup GNOME Terminal profiles via dconf load (perfil, cores, fonte, binds) ##
setup_terminal_dconf() {
  print_info "Setting up GNOME Terminal profiles via dconf..."

  local term_file=""
  if [ -f "$REPO_ASSETS_DIR/terminal.dconf" ]; then
    term_file="$REPO_ASSETS_DIR/terminal.dconf"
  elif [ -f "$CONF_FILE_DESTINATION/terminal.dconf" ]; then
    term_file="$CONF_FILE_DESTINATION/terminal.dconf"
  fi

  if [ -n "$term_file" ]; then
    dconf load / < "$term_file"
    print_success "GNOME Terminal profiles restored from: $term_file"
  else
    print_info "terminal.dconf not found in $REPO_ASSETS_DIR; skipping terminal restore."
  fi
}


## Restaura os agendamentos (crontab) versionados em assets/crontab ##
## O arquivo usa o placeholder __HOME__ para portabilidade entre usuarios. ##
setup_cron_from_repo() {
  print_info "Restoring user crontab from repo..."

  local cron_file="$REPO_ASSETS_DIR/crontab"
  if [ ! -f "$cron_file" ]; then
    print_info "assets/crontab not found; skipping crontab restore."
    return
  fi

  # Substitui __HOME__ pelo HOME real e instala o crontab do usuario
  sed "s#__HOME__#${HOME}#g" "$cron_file" | crontab -
  print_success "Crontab restored from: $cron_file (verifique com: crontab -l)"
}


## Install GNOME extensions from the saved list (downloaded from extensions.gnome.org) ##
install_gnome_extensions() {
  print_info "Installing GNOME extensions..."

  local ext_list="$REPO_ASSETS_DIR/gnome-extensions.list"
  local ext_settings="$REPO_ASSETS_DIR/gnome-extensions-settings.dconf"

  if [ ! -f "$ext_list" ]; then
    print_info "Lista de extensoes ainda nao existe ($ext_list)."
    print_info "Isso e normal na primeira instalacao. Depois de habilitar suas extensoes,"
    print_info "rode 'Backup.sh' para gerar a lista e versiona-la no repo."
    return
  fi

  if ! command -v gnome-extensions &> /dev/null; then
    print_error "gnome-extensions CLI not found. Install 'gnome-shell-extensions' first."
    return
  fi

  # Versao do GNOME Shell para pedir o zip compativel na API da EGO
  local shell_ver
  shell_ver="$(gnome-shell --version 2>/dev/null | grep -oE '[0-9]+' | head -1)"
  print_info "GNOME Shell version detected: ${shell_ver:-desconhecida}"

  local tmpdir
  tmpdir="$(mktemp -d)"

  while IFS= read -r uuid; do
    [ -z "$uuid" ] && continue
    case "$uuid" in \#*) continue ;; esac   # ignora comentarios

    if gnome-extensions list 2>/dev/null | grep -qx "$uuid"; then
      print_info "$uuid already installed, skipping."
      continue
    fi

    print_info "Downloading $uuid from extensions.gnome.org..."
    # Descobre a URL de download compativel via API de info da EGO
    local info_url="https://extensions.gnome.org/extension-info/?uuid=${uuid}&shell_version=${shell_ver}"
    local dl_path
    dl_path="$(curl -sf "$info_url" | grep -oE '"download_url": *"[^"]+"' | sed 's/.*"download_url": *"//; s/"//')"

    if [ -z "$dl_path" ]; then
      print_error "No compatible download found for $uuid (shell $shell_ver). Install manually."
      continue
    fi

    local zip="$tmpdir/${uuid}.zip"
    if curl -sfL "https://extensions.gnome.org${dl_path}" -o "$zip"; then
      if gnome-extensions install --force "$zip"; then
        gnome-extensions enable "$uuid" 2>/dev/null
        print_success "Installed and enabled $uuid."
      else
        print_error "Failed to install $uuid from $zip."
      fi
    else
      print_error "Download failed for $uuid."
    fi
  done < "$ext_list"

  # Restaura as configuracoes das extensoes, se existirem
  if [ -f "$ext_settings" ]; then
    dconf load /org/gnome/shell/extensions/ < "$ext_settings"
    print_success "Extension settings restored."
  fi

  rm -rf "$tmpdir"
  print_info "GNOME extensions step finished. A logout/login may be required to activate them."
}


## Instala um agendamento (cron) que roda o backup do GNOME periodicamente ##
## Se detectar mudanca em binds/extensoes, ele commita e da push automaticamente. ##
setup_backup_cron() {
  print_info "Setting up backup cron job..."

  local backup_script="$SCRIPTS_FILE_DESTINATION/Backup.sh"
  local schedule="0 */6 * * *"   # a cada 6 horas; ajuste se quiser
  local log_file="$HOME/.config/debian-scripts/backup.log"

  if [ ! -f "$backup_script" ]; then
    print_error "Backup script not found at $backup_script (rode copy_scripts_files antes)."
    return
  fi
  chmod +x "$backup_script"
  mkdir -p "$(dirname "$log_file")"

  # Linha do cron. --push para publicar automaticamente quando houver mudanca.
  # Passamos as variaveis de ambiente necessarias para o dconf funcionar via cron.
  local cron_line="$schedule DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/\$(id -u)/bus $backup_script --push >> $log_file 2>&1"

  # Idempotente: remove entradas antigas do backup (nome novo e antigo) antes de re-adicionar
  local current
  current="$(crontab -l 2>/dev/null | grep -vE "Backup\.sh|Backup_gnome_config\.sh")"
  { [ -n "$current" ] && echo "$current"; echo "$cron_line"; } | crontab -

  print_success "Cron job installed ($schedule). Log: $log_file"
  print_info "Verifique com: crontab -l"
}


## Setup DCONF settings ##
dconf_setup() {
  print_info "Setting up DCONF..."
  local dconf_file="$REPO_ASSETS_DIR/dconf-general-settings.ini"
  if [ -f "$dconf_file" ]; then
    dconf load / < "$dconf_file"
    print_success "DCONF settings configured successfully."
  else
    print_info "dconf-general-settings.ini not found in assets, skipping."
  fi
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

  sudo apt update && sudo apt dist-upgrade -y
  flatpak update -y
  sudo apt autoclean
  sudo apt autoremove -y
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


# =====================================================================
# MENU INTERATIVO
# Navegue pelos submenus e escolha o que executar. Nada roda sem sua escolha.
# =====================================================================

pause() { echo; read -rp "Pressione Enter para continuar..."; }

## --- Submenu: APPS --- ##
menu_apps() {
  while true; do
    clear
    echo "===== APPS ====="
    echo " 1) Instalar pacotes APT"
    echo " 2) Instalar Flatpaks"
    echo " 3) Instalar Snapd (gerenciador)"
    echo " 4) Instalar Snaps"
    echo " 5) Instalar Docker"
    echo " 6) Instalar Wine"
    echo " 7) Apps externos (.deb: Edge, VSCode, Steam)"
    echo " 8) TUDO de apps (1..7)"
    echo " 0) Voltar"
    read -rp "> " o
    case "$o" in
      1) install_apt_packages; pause ;;
      2) install_flatpak; pause ;;
      3) install_snapd; pause ;;
      4) install_snaps; pause ;;
      5) install_docker; pause ;;
      6) install_wine; pause ;;
      7) install_external_applications; pause ;;
      8) install_apt_packages; install_flatpak; install_snapd; install_snaps; \
         install_docker; install_wine; install_external_applications; pause ;;
      0) return ;;
      *) echo "Opcao invalida"; sleep 1 ;;
    esac
  done
}

## --- Submenu: BACKUPS --- ##
menu_backups() {
  while true; do
    clear
    echo "===== BACKUPS ====="
    echo " 1) Agendar backup automatico (cron: exporta binds/extensoes/terminal/cron e commita se mudar)"
    echo " 2) Rodar backup de configs agora (binds + extensoes + terminal + cron -> git)"
    echo " 3) Rodar backup de arquivos agora (~/debian + wallpapers -> ~/Backups)"
    echo " 0) Voltar"
    read -rp "> " o
    case "$o" in
      1) setup_backup_cron; pause ;;
      2) "$SCRIPTS_FILE_DESTINATION/Backup.sh" --push 2>/dev/null \
           || bash "$REPO_SCRIPTS_DIR/Backup.sh" --push; pause ;;
      3) "$SCRIPTS_FILE_DESTINATION/Backup_files.sh" 2>/dev/null \
           || bash "$REPO_SCRIPTS_DIR/Backup_files.sh"; pause ;;
      0) return ;;
      *) echo "Opcao invalida"; sleep 1 ;;
    esac
  done
}

## --- Submenu: CONFIGS (GNOME + shell) --- ##
menu_configs() {
  while true; do
    clear
    echo "===== CONFIGS ====="
    echo " 1) Aplicar keybinds do repo (dconf) + marcar inicializacao"
    echo " 2) Instalar extensoes GNOME (download da EGO + restaura settings)"
    echo " 3) Aplicar dconf geral (dconf-general-settings.ini)"
    echo " 4) Botao minimizar na barra de titulo"
    echo " 5) Aliases de shell (~/.bashrc)"
    echo " 6) Link do ~/.bash_aliases"
    echo " 7) Credenciais do Git"
    echo " 8) TODAS as configs (1..7 + terminal + cron)"
    echo " 9) Restaurar perfil do GNOME Terminal (dconf)"
    echo " 0) Voltar"
    read -rp "> " o
    case "$o" in
      1) setup_keybinds_dconf; pause ;;
      2) install_gnome_extensions; pause ;;
      3) dconf_setup; pause ;;
      4) setup_gnomesettings; pause ;;
      5) setup_aliases; pause ;;
      6) create_bash_aliases_link; pause ;;
      7) setup_gitcredentials; pause ;;
      8) setup_keybinds_dconf; setup_terminal_dconf; install_gnome_extensions; dconf_setup; \
         setup_gnomesettings; setup_aliases; create_bash_aliases_link; setup_gitcredentials; \
         setup_cron_from_repo; pause ;;
      9) setup_terminal_dconf; pause ;;
      0) return ;;
      *) echo "Opcao invalida"; sleep 1 ;;
    esac
  done
}

## --- Submenu: PURGE / LIMPEZA --- ##
menu_purge() {
  while true; do
    clear
    echo "===== PURGE / LIMPEZA ====="
    echo " 1) Remover jogos do GNOME"
    echo " 2) Remover LibreOffice"
    echo " 3) Ambos (1 e 2)"
    echo " 0) Voltar"
    read -rp "> " o
    case "$o" in
      1) remove_games; pause ;;
      2) remove_libreoffice; pause ;;
      3) remove_games; remove_libreoffice; pause ;;
      0) return ;;
      *) echo "Opcao invalida"; sleep 1 ;;
    esac
  done
}

## --- Submenu: AMBIENTE (pastas, templates, copias) --- ##
menu_ambiente() {
  while true; do
    clear
    echo "===== AMBIENTE ====="
    echo " 1) Criar pastas (~/debian/{conf,scripts,dump}, Wallpapers)"
    echo " 2) Criar templates (~/Templates)"
    echo " 3) Copiar assets do repo -> ~/debian/conf"
    echo " 4) Copiar scripts do repo -> ~/debian/scripts"
    echo " 5) TUDO de ambiente (1..4)"
    echo " 0) Voltar"
    read -rp "> " o
    case "$o" in
      1) create_folders; pause ;;
      2) create_templates; pause ;;
      3) copy_config_files; pause ;;
      4) copy_scripts_files; pause ;;
      5) create_folders; create_templates; copy_config_files; copy_scripts_files; pause ;;
      0) return ;;
      *) echo "Opcao invalida"; sleep 1 ;;
    esac
  done
}

## --- Submenu: SISTEMA --- ##
menu_sistema() {
  while true; do
    clear
    echo "===== SISTEMA ====="
    echo " 1) Atualizar sistema (apt update && upgrade)"
    echo " 2) Remover locks do APT (use se o apt travar)"
    echo " 3) Adicionar usuario ao sudoers"
    echo " 4) Finalizar (dist-upgrade + limpeza + reboot opcional)"
    echo " 0) Voltar"
    read -rp "> " o
    case "$o" in
      1) update_system; pause ;;
      2) remove_apt_locks; pause ;;
      3) sudo_user; pause ;;
      4) finish_setup; pause ;;
      0) return ;;
      *) echo "Opcao invalida"; sleep 1 ;;
    esac
  done
}

## --- Instalacao COMPLETA (tudo na ordem correta) --- ##
run_full_install() {
  clear
  echo ">>> Instalacao completa iniciando..."
  update_system
  remove_games
  create_templates
  create_folders
  copy_config_files
  copy_scripts_files
  create_bash_aliases_link
  setup_aliases
  setup_gitcredentials
  install_apt_packages
  install_external_applications
  install_flatpak
  install_snapd
  install_snaps
  install_docker
  install_wine
  setup_keybinds_dconf
  setup_terminal_dconf
  install_gnome_extensions
  dconf_setup
  setup_gnomesettings
  setup_cron_from_repo
  setup_backup_cron
  finish_setup
}

## --- MENU PRINCIPAL --- ##
main_menu() {
  while true; do
    clear
    echo "############################################"
    echo "#        SETUP DEBIAN - MENU PRINCIPAL     #"
    echo "############################################"
    echo " 1) Apps        (apt, flatpak, snap, docker, wine, externos)"
    echo " 2) Backups     (cron, backup de configs, backup de arquivos)"
    echo " 3) Configs     (keybinds, extensoes, dconf, aliases, git)"
    echo " 4) Purge       (jogos, libreoffice)"
    echo " 5) Ambiente    (pastas, templates, copiar scripts/assets)"
    echo " 6) Sistema     (update, locks, sudoers, finalizar)"
    echo "--------------------------------------------"
    echo " 9) INSTALACAO COMPLETA (tudo na ordem correta)"
    echo " 0) Sair"
    read -rp "> " o
    case "$o" in
      1) menu_apps ;;
      2) menu_backups ;;
      3) menu_configs ;;
      4) menu_purge ;;
      5) menu_ambiente ;;
      6) menu_sistema ;;
      9) run_full_install; pause ;;
      0) echo "Saindo."; exit 0 ;;
      *) echo "Opcao invalida"; sleep 1 ;;
    esac
  done
}

# Guard: nao rode com sudo/root. Os comandos que precisam de root ja usam
# 'sudo' internamente; rodar o script inteiro como root faria os arquivos e
# as configs (dconf/gsettings) irem para /root em vez da sua home.
if [ "$(id -u)" -eq 0 ] && [ -z "${SUDO_USER:-}" ]; then
  echo "NAO rode este script como root/sudo."
  echo "Rode como seu usuario normal:  bash Setup_Debian.sh"
  echo "As funcoes que precisam de root pedem a senha do sudo quando necessario."
  exit 1
fi
if [ -n "${SUDO_USER:-}" ]; then
  echo "Aviso: detectado 'sudo'. Reexecutando como o usuario '$SUDO_USER' para evitar"
  echo "que arquivos/config vao para /root..."
  exec sudo -u "$SUDO_USER" -H bash "${BASH_SOURCE[0]}" "$@"
fi

# Inicia o menu
main_menu

