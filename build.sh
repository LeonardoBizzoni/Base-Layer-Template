#!/usr/bin/env bash
cd "$(dirname "$0")"

if [ "$(uname)" == "Linux" ]; then
    os="LNX"
    display_server=$(loginctl show-session $(awk '/tty/ {print $1}' <(loginctl)) -p Type | awk -F= '{print $2}')
elif [[ "$(uname)" == *"BSD"* ]]; then
    os="BSD"
    display_server=$(echo "$XDG_SESSION_TYPE")
else exit -1; fi

for arg in "$@"; do declare $arg='1'; done
if [ ! -v clang ];   then gcc=1; fi
if [ ! -v release ]; then debug=1; fi
if [ -v gcc ]; then compiler=$([ -v cpp ] && echo "g++" || echo "gcc"); fi
if [ -v clang ]; then compiler=$([ -v cpp ] && echo "clang++" || echo "clang"); fi

flags+="-Isrc/base -pedantic -Wno-cpp -lpthread -lm "
if [ -v cpp ]; then flags+="-std=c++23 -fno-exceptions"; fi
if [ -v release ]; then flags+="-O3 -s "
else
    flags+="-O0 -ggdb -g3 -fvisibility=hidden -fsanitize=address,undefined -DENABLE_ASSERT -DDEBUG"
fi
if [ -v gui ]; then
    flags+=" -DOS_GUI "

    if [ "$display_server" == "x11" ]; then flags+="-lX11 -lXext -D${os}_X11";
    else flags+="-D${os}_Wayland"; fi
fi

[ -v gcc ] && printf "+ [ GNU " || printf "+ [ Clang "
[ -v cpp ] && printf "C++ " || printf "C "
printf "compilation ]\n"
[ -v debug ] && echo "+ [ debug mode ]" || echo "+ [ release mode ]"
(set -x; $compiler $flags -o main src/main.c)
