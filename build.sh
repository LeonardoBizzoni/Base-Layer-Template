#!/usr/bin/env bash

if [ "$1" = "release" ]; then
    flags="-O3 -Wall -s -fno-exceptions"
else
    flags="-O0 -ggdb -fno-exceptions -Wno-cpp -fsanitize=address"
fi

g++ src/main.cpp -o main $flags
