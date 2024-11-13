#!/usr/bin/env bash

if [ "$1" = "release" ]; then
    flags="-Isrc/base -O3 -Wall -s -fno-exceptions"
else
    flags="-Isrc/base -O0 -ggdb -fno-exceptions \
    -Wno-cpp -fsanitize=address,undefined -g3 -fvisibility=hidden"
fi

gcc src/main.c -o main $flags
