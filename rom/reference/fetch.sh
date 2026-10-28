#!/bin/sh
# Re-download the third-party CoBra ROM images and disassemblies listed in MANIFEST.md
# (they are not committed) and check each MD5.
set -e
cd "$(dirname "$0")"
grep -E '^\| [^ ]+ \| [0-9]+ \| `[0-9a-f]{32}` \| https?://' MANIFEST.md |
while IFS='|' read -r _ file size md5 url _; do
    file=$(echo "$file" | xargs); url=$(echo "$url" | xargs); md5=$(echo "$md5" | tr -d ' `')
    [ -f "$file" ] || curl -sfL -o "$file" "$url" || { echo "FAILED  $file" >&2; continue; }
    got=$(md5 -q "$file" 2>/dev/null || md5sum "$file" | cut -d' ' -f1)
    [ "$got" = "$md5" ] && echo "ok      $file" || echo "MD5 MISMATCH $file" >&2
done
