#!/bin/sh

HUGO_VERSION="0.145.0"

docker run \
        --name opendevies \
        --rm \
        -p 1313:1313 \
        -v ${PWD}:/src \
        hugomods/hugo:exts-"$HUGO_VERSION" "$@"

