# -*- coding: utf-8 -*-
#
# nautilus_background_scripts.py
# ------------------------------
# Extensao do Nautilus que adiciona um submenu "Scripts" ao clicar com o
# botao direito na AREA VAZIA (background) de uma pasta. Lista dinamicamente
# os executaveis contidos em:
#
#     ~/.local/share/nautilus/background-scripts/
#
# Cada executavel vira um item do submenu. Ao ser escolhido, o script e
# executado com a PASTA ATUAL como:
#   - primeiro argumento ($1), e
#   - variavel de ambiente NAUTILUS_SCRIPT_CURRENT_URI (padrao do Nautilus).
#
# Assim voce so precisa jogar um script executavel naquela pasta e ele
# aparece no menu automaticamente -- igual a pasta de scripts nativa do
# Nautilus, mas funcionando no clique em area vazia.
#
# Compatibilidade: Nautilus 4.x (GNOME 43+). Requer python3-nautilus.

import os
import subprocess
from gi import require_version, get_required_version

# Descobre a versao da API do Nautilus disponivel (4.0 no GNOME 43+).
_api = get_required_version("Nautilus")
if _api is None:
    try:
        require_version("Nautilus", "4.0")
    except Exception:
        require_version("Nautilus", "3.0")

from gi.repository import Nautilus, GObject  # noqa: E402
from gi.repository import GLib  # noqa: E402
from urllib.parse import unquote, urlparse  # noqa: E402


SCRIPTS_DIR = os.path.join(
    GLib.get_user_data_dir(), "nautilus", "background-scripts"
)


def _uri_to_path(uri):
    """Converte uma file:// URI para um caminho de sistema de arquivos."""
    if not uri:
        return None
    parsed = urlparse(uri)
    if parsed.scheme and parsed.scheme != "file":
        return None  # so lidamos com pastas locais
    return unquote(parsed.path)


def _list_scripts(directory):
    """Retorna lista de (nome_exibicao, caminho_absoluto) dos executaveis
    diretos na pasta, ordenados por nome. Ignora ocultos."""
    scripts = []
    try:
        for entry in sorted(os.listdir(directory)):
            if entry.startswith("."):
                continue
            full = os.path.join(directory, entry)
            if os.path.isfile(full) and os.access(full, os.X_OK):
                scripts.append((entry, full))
    except FileNotFoundError:
        pass
    except OSError:
        pass
    return scripts


class BackgroundScriptsProvider(GObject.GObject, Nautilus.MenuProvider):
    """Fornece o submenu 'Scripts' no clique em area vazia."""

    def _run(self, menu_item, script_path, folder_path):
        """Executa o script passando a pasta atual como arg e via env."""
        env = dict(os.environ)
        # Padrao do Nautilus: expõe a pasta atual como URI file://
        env["NAUTILUS_SCRIPT_CURRENT_URI"] = GLib.filename_to_uri(
            folder_path, None
        )
        try:
            subprocess.Popen(
                [script_path, folder_path],
                cwd=folder_path,
                env=env,
            )
        except Exception as exc:  # nao deixa excecao quebrar o Nautilus
            print("background-scripts: falha ao executar "
                  "%s: %s" % (script_path, exc))

    def _build_menu(self, folder_path):
        scripts = _list_scripts(SCRIPTS_DIR)
        if not scripts:
            return None

        top = Nautilus.MenuItem(
            name="BackgroundScripts::Top",
            label="Scripts",
            tip="Scripts para a pasta atual",
        )
        submenu = Nautilus.Menu()
        top.set_submenu(submenu)

        for display_name, path in scripts:
            item = Nautilus.MenuItem(
                name="BackgroundScripts::%s" % display_name,
                label=display_name,
                tip="Executar: %s" % display_name,
            )
            item.connect("activate", self._run, path, folder_path)
            submenu.append_item(item)

        return top

    # Chamado pelo Nautilus no clique em AREA VAZIA (background).
    def get_background_items(self, *args):
        # Compat: a assinatura mudou entre versoes (com/sem 'window').
        # O ultimo argumento e sempre a pasta atual (FileInfo).
        current_folder = args[-1]
        try:
            uri = current_folder.get_uri()
        except Exception:
            return []

        folder_path = _uri_to_path(uri)
        if not folder_path or not os.path.isdir(folder_path):
            return []

        top = self._build_menu(folder_path)
        return [top] if top is not None else []
