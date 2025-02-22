#!/usr/bin/env bash
cd "$(dirname "$0")"

common_link="-lpthread -lm"
common_flags="-Isrc/base -pedantic -Wall -Wno-cpp -Wno-unused-function"
common_cpp="-std=c++23 -fno-exceptions"

common_opt="-O3 -s"
common_dbg="-O0 -g3 -fvisibility=hidden -DENABLE_ASSERT -DDEBUG"
common_avr="-c -Os -ffunction-sections -fdata-sections"

lnx_dbg="-ggdb -fsanitize=address,undefined"
bsd_dbg="-ggdb"

common_gui="-DOS_GUI"
gui_x11="-D${os}_X11 -lX11 -lXext"
gui_wayland="-D${os}_Wayland"

for arg in "$@"; do
    if [[ $arg == *=* ]]; then
        var="${arg%%=*}"
        val="${arg#*=}"
        declare "$var"="$val"
    else
	declare $arg='1'
    fi
done

if [[ ! -v clang && ! -v avr ]]; then gcc=1;   fi
if [ ! -v release ];             then debug=1; fi

# Compiler detection
if [ -v gcc ];   then compiler=$([ -v cpp ] && echo "g++" || echo "gcc");         fi
if [ -v clang ]; then compiler=$([ -v cpp ] && echo "clang++" || echo "clang");   fi
if [ -v avr ];   then compiler=$([ -v cpp ] && echo "avr-g++" || echo "avr-gcc"); fi

# OS detection
if [ ! -v avr ]; then
    if [ "$(uname)" == "Linux" ]; then
	os="LNX"
	display_server=$(echo "$XDG_SESSION_TYPE")
    elif [[ "$(uname)" == *"BSD"* ]]; then
	os="BSD"
	display_server=$(echo "$XDG_SESSION_TYPE")
    elif [[ "$(uname)" == "Darwin" ]]; then
	os="MACOS"
    else
	exit -1;
    fi
else
    if [ ! -v board ]; then board="Arduino-Uno"; fi
    case $board in
	"Arduino-Uno")
	    board="atmega328"
	    if [ ! -v clock ]; then clock=16000000; fi
	    ;;
	*)
	    exit -1
	    ;;
    esac

    echo $clock
    echo $board
    common_avr+=" -mmcu=$board -DF_CPU=$clock"
fi

flags="$common_flags "
if [ -v cpp ]; then flags+="$common_cpp "; fi
if [ -v avr ]; then
    flags+="$common_avr "
else
    flags+="$common_link "
    if [ -v debug ]; then
	flags+="$common_dbg "
	if [ os == "LNX" ]; then
	    flags+="$lnx_dbg "
	elif [ os == "BSD" ]; then
	    flags+="$bsd_dbg "
	elif [ os == "MACOS" ]; then
	    flags+="$macos_dbg "
	fi
    else
	flags+="$common_opt "
    fi

    if [ -v gui ]; then
	flags+="$common_gui "
	if [ os == "LNX" || os == "BSD" ]; then
	    if [ "$display_server" == "x11" ]; then
		flags+="$gui_x11 "
	    else
		flags+="$gui_wayland "
	    fi
	fi
    fi
fi

if   [ -v gcc ];   then printf "+ [ GNU "
elif [ -v clang ]; then printf "+ [ Clang "
else                    printf "+ [ AVR "
fi

[ -v cpp ] && printf "C++ " || printf "C "; printf "compilation ]\n"
[ -v debug ] && echo "+ [ debug mode ]" || echo "+ [ release mode ]"
(set -x; $compiler $flags -o main src/main.c)
