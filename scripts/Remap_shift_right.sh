#!/bin/bash
#
# Remap_shift_right.sh - transforma o Shift DIREITO num modificador Hyper (X11).
#
# Objetivo: usar o Shift direito como tecla de atalho (ex.: no Kitty, ShiftR+T),
# reduzindo os atalhos de 3 teclas (Ctrl+Shift+X) para 2.
#
# IMPORTANTE:
#   - So funciona em sessao X11 (nao Wayland).
#   - O Shift direito DEIXA de fazer maiusculas; use o Shift esquerdo para isso.
#   - Para reverter: 'setxkbmap' (recarrega o layout padrao) ou logout/login.
#
# Uso: rode na sua sessao grafica (ex.: no autostart) - ./Remap_shift_right.sh

# So faz sentido em X11
if [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
  echo "Sessao Wayland detectada; remapeamento via xmodmap nao se aplica. Saindo."
  exit 0
fi

command -v xmodmap >/dev/null || { echo "xmodmap nao instalado (sudo apt install x11-xserver-utils)."; exit 1; }

# Shift_R = keycode 62. Tira do modificador shift e transforma em Hyper_R (mod3).
xmodmap -e "remove shift = Shift_R"
xmodmap -e "keycode 62 = Hyper_R"
xmodmap -e "remove mod4 = Hyper_R"   # garante que Hyper nao fique junto do Super/mod4
xmodmap -e "add mod3 = Hyper_R"

echo "Shift direito remapeado para Hyper (mod3). Atalhos do Kitty usam 'hyper'."
