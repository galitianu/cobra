"""Compare two ROM images byte by byte.

    uv run python rom/romdiff.py chip_read.bin wanted.bin

Lists differing offsets and, for UV EPROMs, flags bytes that would need a bit
to go 0 -> 1 (impossible without erasing). Exit status 1 if the images differ.
"""
import hashlib
import sys
from pathlib import Path

a_path, b_path = sys.argv[1:3]
a, b = Path(a_path).read_bytes(), Path(b_path).read_bytes()
for path, data in ((a_path, a), (b_path, b)):
    print(f"{path}: {len(data)} bytes, md5 {hashlib.md5(data).hexdigest()}")
if len(a) != len(b):
    print(f"size differs: {len(a)} vs {len(b)}")

diffs = [(i, x, y) for i, (x, y) in enumerate(zip(a, b)) if x != y]
need_erase = 0
print(f"{len(diffs)} differing bytes")
for i, x, y in diffs:
    up = y & ~x & 0xFF
    need_erase += bool(up)
    note = f"  needs 0->1 bits {up:02X} (erase first)" if up else ""
    print(f"  {i:04X}  {x:02X} -> {y:02X}{note}")
if diffs:
    print(f"{need_erase} bytes need an erase before the first image can become the second")
sys.exit(1 if diffs or len(a) != len(b) else 0)
