#!/bin/bash -eu

OUT_DIR="build/desktop"
mkdir -p $OUT_DIR
odin build source/main_desktop \
	-strict-style \
	-out:$OUT_DIR/echo_chamber \
	-extra-linker-flags:"-L$HOME/.local/lib" \
	-debug

cp -R ./assets/ ./$OUT_DIR/
echo "Desktop build created in ${OUT_DIR}"
