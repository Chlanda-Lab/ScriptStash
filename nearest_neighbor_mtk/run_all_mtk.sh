#!/usr/bin/bash
set -e

for modelfile in $(find ./ -maxdepth 2 -iname '*.mod'); do
    ./mtk.sh" "$modelfile"
done
