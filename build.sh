#!/usr/bin/env bash
cd "$(dirname "$0")"
set -eu

file="main.c"

for arg in "$@"; do
    if [[ $arg == *=* ]]; then
        var="${arg%%=*}"
        val="${arg#*=}"
        declare "$var"="$val"
    else
        declare $arg='1'
    fi
done

common_link="-lpthread -lm"
common_flags="-pedantic -Wall -Wno-unused-function -Wno-gnu-anonymous-struct -Wno-nested-anon-types"
common_cpp="-std=c++23 -fno-exceptions"
common_gui="-DOS_GUI=1"

common_opt="-O3 -s"
common_dbg="-O0 -g3 -fvisibility=hidden -DENABLE_ASSERT=1 -DDEBUG=1"

lnx_dbg="-ggdb -fsanitize=address,undefined"
bsd_dbg="-ggdb"

if [ ! -v release ]; then debug=1; fi

if [ -v cross ]; then
    case "${cross,,}" in
        "atmega328p")
            compiler=$([ -v cpp ] && echo "avr-g++" || echo "avr-gcc")
            if [ ! -v clock ]; then clock=16000000; fi
            flags="-Os -ffunction-sections -fdata-sections -mmcu=$cross -DF_CPU=$clock "

            printf "+ [ AVR "
            if [ -v cpp ]; then
                flags+=$common_cpp
                printf "C++ "
            else
                printf "C "
            fi
            printf "compilation ]\n"
            [ -v debug ] && echo "+ [ debug mode ]" || echo "+ [ release mode ]"

            (
                set -x
                $compiler $flags -c $file -o main.out
                $compiler $flags main.out -o main.elf
                avr-objcopy -O ihex -R .eeprom main.elf main.ihex
            )
            if [ ! -v noflash ]; then
                if [ ! -v device ]; then
                    echo "You didn't provide a device with \`device=/dev/something\`"
                    exit -1
                fi
                (
                    set -x
                    sudo avrdude -F -V -c arduino -p atmega328p -P $device \
                         -b 115200 -U flash:w:main.ihex
                )
            fi
            ;;
        "cortex-m7")
            compiler=$([ -v cpp ] && echo "arm-none-eabi-g++" || echo "arm-none-eabi-gcc")

            printf "+ [ ARM-NONE "
            if [ -v cpp ]; then
                flags+=$common_cpp
                printf "C++ "
            else
                printf "C "
            fi
            printf "compilation ]\n"
            [ -v debug ] && echo "+ [ debug mode ]" || echo "+ [ release mode ]"

            (
                set -x
                $compiler $file -T stm32_linker.ld -o main.elf -mcpu=cortex-m7 -mthumb -nostdlib
            )
            if [ ! -v noflash ]; then
                if [ ! -v device ]; then
                    echo "You didn't provide a device with \`device=/dev/something\`"
                    exit -1
                fi
                (
                    set -x
                )
            fi
            ;;
        *)
            exit -1
            ;;
    esac
else
    if [ ! -v gcc ]; then clang=1; fi

    if [ -v gcc ];   then compiler=$([ -v cpp ] && echo "g++" || echo "gcc");         fi
    if [ -v clang ]; then compiler=$([ -v cpp ] && echo "clang++" || echo "clang");   fi

    case "$(uname)" in
        "Linux")
            os="LNX"
            if [ -v gui ]; then
                display_server=$(echo "$XDG_SESSION_TYPE")
            fi
            ;;
        *BSD*)
            os="BSD"
            if [ -v gui ]; then
                display_server=$(echo "$XDG_SESSION_TYPE")
            fi
            ;;
        "Darwin")
            os="MACOS"
            ;;
        *)
            exit -1
            ;;
    esac

    flags="$common_flags $common_link "
    if [ -v cpp ]; then flags+="$common_cpp "; fi

    if [ -v debug ]; then
        flags+="$common_dbg "
        if [ "$os" == "LNX" ]; then
            flags+="$lnx_dbg "
        elif [ "$os" == "BSD" ]; then
            flags+="$bsd_dbg "
        elif [ "$os" == "MACOS" ]; then
            flags+="$macos_dbg "
        fi
    else
        flags+="$common_opt "
    fi

    if [ -v gui ]; then
        flags+="$common_gui "
        if [[ $os == "LNX" || $os == "BSD" ]]; then
            if [ "$display_server" == "x11" ]; then
                flags+="-D${os}_X11=1 -lX11 -lXext "
            else
                flags+="-D${os}_Wayland=1 "
            fi
        fi

        if [ -v opengl ]; then
            flags+="-lGL -lGLU -DUSING_OPENGL=1 "
        fi
    fi

    if   [ -v gcc ];   then printf "+ [ GNU "
    elif [ -v clang ]; then printf "+ [ Clang "
    fi

    [ -v cpp ] && printf "C++ " || printf "C "; printf "compilation ]\n"
    [ -v debug ] && echo "+ [ debug mode ]" || echo "+ [ release mode ]"
    (set -x; $compiler $flags $file -o main)
fi
