#!/bin/bash
#
# config.sh - configuracao central compartilhada por todos os scripts.
# Fonte unica de caminhos e funcoes de log. Todos os scripts fazem:
#   source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
#
# Os caminhos derivam de $HOME/$USER, sem hardcode de usuario.

## Usuario e home ##
USERNAME="${USER:-$(id -un)}"
HOME_DIR="${HOME:-/home/$USERNAME}"

## Diretorios principais ##
# DEBIAN_DIR e derivado automaticamente da localizacao real do repositorio,
# entao funciona seja qual for o nome da pasta (debian-scripts, etc.).
# config.sh vive em <repo>/scripts/, logo o repo e o diretorio pai.
_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEBIAN_DIR="$(cd "$_CONFIG_DIR" && git rev-parse --show-toplevel 2>/dev/null)"
[ -z "$DEBIAN_DIR" ] && DEBIAN_DIR="$(cd "$_CONFIG_DIR/.." && pwd)"
SCRIPTS_DIR="$DEBIAN_DIR/scripts"
CONF_DIR="$DEBIAN_DIR/conf"
DUMP_DIR="$DEBIAN_DIR/dump"
BACKUP_DIR="$HOME_DIR/Backups"
WALLPAPER_DIR="$HOME_DIR/pictures/wallpapers"
DOWNLOADS_DIR="$HOME_DIR/downloads"

## Estado interno (sentinela de inicializacao, logs) ##
STATE_DIR="$HOME_DIR/.config/debian-scripts"
INIT_SENTINEL="$STATE_DIR/.initialized"

## Terminal colors ##
GREEN='\033[0;32m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m'

## Log helpers ##
print_success() { echo -e "${GREEN}[OK] - $1${NC}"; }
print_info()    { echo -e "${ORANGE}[INFO] - $1${NC}"; }
print_error()   { echo -e "${RED}[ERROR] - $1${NC}"; }
