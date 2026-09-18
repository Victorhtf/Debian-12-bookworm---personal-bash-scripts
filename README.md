# Debian personal bash scripts

Scripts de pós-instalação e manutenção para Debian (testado no Debian 13 / trixie).

## Estrutura

```
.
├── Setup_Debian.sh              # entrypoint: pós-instalação (funções comentadas por padrão)
├── scripts/                     # scripts do dia-a-dia → copiados para ~/debian/scripts
│   ├── config.sh                # configuração central: paths + funções de log (sourced pelos demais)
│   ├── Daily_Debian.sh          # orquestrador: organiza downloads + backup de arquivos + notify
│   ├── Autowallpaper.sh         # wallpaper aleatório (tema claro/escuro)
│   ├── Organize_folders.sh      # organiza uma pasta informada (interativo)
│   ├── Backup_files.sh          # backup local de ~/debian + wallpapers → ~/Backups/<timestamp>
│   └── Backup_gnome_config.sh   # exporta keybinds + extensões GNOME e commita se mudar
└── assets/                      # arquivos auxiliares (configs versionadas)
    ├── keybinds.dconf
    ├── gnome-extensions.list
    └── gnome-extensions-settings.dconf
```

## Instalação inicial

```bash
git clone <repo> ~/debian-scripts
cd ~/debian-scripts
# Descomente as funções desejadas no final de Setup_Debian.sh, depois:
bash Setup_Debian.sh
```

O setup:
1. Cria `~/debian/{conf,scripts,dump}` e outras pastas
2. Copia `scripts/*` → `~/debian/scripts` (sua pasta padrão de scripts)
3. Copia `assets/*` → `~/debian/conf`
4. Instala pacotes APT / Flatpak / Snap
5. Carrega keybinds (`setup_keybinds_dconf`) e extensões (`install_gnome_extensions`)

## Backup / export das configs do GNOME

O `scripts/Backup_gnome_config.sh` exporta o estado atual do sistema para `assets/`
e commita **apenas se houver diferença**:

```bash
~/debian/scripts/Backup_gnome_config.sh            # exporta + commit local se mudou
~/debian/scripts/Backup_gnome_config.sh --push     # também faz git push
~/debian/scripts/Backup_gnome_config.sh --no-commit # só exporta, sem git
```

Exporta:
- Keybinds (dconf) → `assets/keybinds.dconf`
- Lista de extensões habilitadas → `assets/gnome-extensions.list`
- Configurações das extensões → `assets/gnome-extensions-settings.dconf`

Assim o repositório mantém sempre a versão mais atual das suas binds e extensões.

## Extensões GNOME

- **Backup**: `Backup_gnome_config.sh` salva a lista de UUIDs e as configs.
- **Restore**: `install_gnome_extensions` (em `Setup_Debian.sh`) baixa cada extensão
  compatível de [extensions.gnome.org](https://extensions.gnome.org) e restaura as configs.
  Extensões que não existirem mais na EGO precisam ser instaladas manualmente (o script avisa).

## Notas

- **Configuração central**: `scripts/config.sh` define todos os caminhos (`DEBIAN_DIR`,
  `SCRIPTS_DIR`, `CONF_DIR`, `BACKUP_DIR`, `WALLPAPER_DIR`, etc.) e as funções de log.
  Todos os scripts fazem `source` dele — mude um caminho em um único lugar.
- **Três papéis separados, sem redundância**:
  - `Backup_gnome_config.sh` → configs do GNOME (binds + extensões), **versionado no git**
  - `Backup_files.sh` → backup local de arquivos (`~/debian` + wallpapers) em `~/Backups`
  - `Daily_Debian.sh` → orquestrador (organiza downloads + backup de arquivos + notify)
- Debian 13 (trixie): pacotes ajustados — `fastfetch` (ex-neofetch), `netcat-openbsd`,
  `openjdk` removido, `nodejs` explícito, Wine via repo trixie.
- `Setup_Debian.sh` mantém todas as chamadas de função **comentadas** no final;
  descomente só o que quiser rodar.
