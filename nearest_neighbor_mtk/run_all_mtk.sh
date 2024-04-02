#!/usr/bin/bash
set -e

for modelfile in $(find ./models -maxdepth 2 -iname '*.mod'); do
    ./mtk.sh "$modelfile" &
done
wait
