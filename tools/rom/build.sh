#!/bin/sh
# Assemble every rom/custom/*.asm with sjasmplus and pad each image to 2 KB (2716 / AT28C16) with FFh.
# Usage: tools/rom/build.sh [file.asm ...]
set -e
cd "$(dirname "$0")/../../rom/custom"
SJ="${SJASMPLUS:-$HOME/.local/bin/sjasmplus}"
for src in ${@:-*.asm}; do
    src=$(basename "$src"); bin="${src%.asm}.bin"
    "$SJ" --nologo --msg=war --lst="${src%.asm}.lst" "$src"
    size=$(wc -c < "$bin" | tr -d ' ')
    [ "$size" -le 2048 ] || { echo "$bin is $size bytes, exceeds 2 KB" >&2; exit 1; }
    python3 -I -c "import sys; p=sys.argv[1]; d=open(p,'rb').read(); open(p,'wb').write(d+b'\xff'*(2048-len(d)))" "$bin"
    printf '%-24s %5s bytes code, md5 %s\n' "$bin" "$size" "$(md5 -q "$bin")"
done
