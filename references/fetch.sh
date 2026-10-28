#!/bin/sh
# Fetch the core CoBra documents into references/cobrasov/ (not committed: third-party copyright).
set -e
cd "$(dirname "$0")"
mkdir -p cobrasov
B="http://cobrasov.com/CoBra%20Project"
get() { [ -f "cobrasov/$1" ] || curl -sfL -o "cobrasov/$1" "$2" && echo "ok  $1" || echo "FAILED  $1 ($2)" >&2; }
get CoBra_Hardware_Manual_rev.1.0.pdf "$B/Manuals/CoBra%20Hardware%20Manual/CoBra%20Hardware%20Manual%20rev.1.0.pdf"
get boot.html   "$B/boot.html"
get rev0.2.html "$B/rev0.2.html"
git -C .. submodule update --init references/ceteras-CoBra
echo "Schematics, PCB files, mods and manual scans: download from https://cobrasov.com (see README.md for the list)."
