# CoBra (Brașov, Romania) 2KB boot ROM dump from a К573РФ5 EPROM

Dumped 2026-10-10 from a Soviet К573РФ5 (2716-compatible, 2K x 8) EPROM found with a CoBra mainboard.
Read with an XGecu T48 and `minipro 0.7.4` on macOS using the generic 2716 profile:

    minipro -p AM2716@DIP24 -y -r dump.bin

Three consecutive reads at 5 V were identical and a verify at VCC = 4.5 V passed, so the data is stable.

- Size: 2048 bytes
- MD5: c79c66140c44dc0346a823e96a31f0e2

## Files

- `K573RF5_cobra_boot80k.hex` – xxd hex listing. Restore with `xxd -r K573RF5_cobra_boot80k.hex > dump.bin`
- `K573RF5_cobra_boot80k.b64` – base64. Restore with `base64 -d < K573RF5_cobra_boot80k.b64 > dump.bin`
- `diff_vs_cobrasov_BOOT_2K_COBRA_80K.txt` – the 22 bytes that differ from the reference image

## What it is

The code is the CoBra "Standard BOOT (v.1), 80K RAM" image, a slightly different revision from the one published at
http://cobrasov.com/CoBra%20Project/boot.html (`BOOT_2K_COBRA_80K.bin`, MD5 5f6d17b8765fb16dd89422690baa9e57).
It differs in 22 bytes:

- `0000`: `16 83` (LD D,83h) instead of `3E 83` (LD A,83h) before `LD R,A`. Relies on A = FFh after Z80 reset to keep bit 7 of R set.
- `011A`–`011D` and `0128`–`0129`: two keyboard-dispatch jumps go to `005E` and `04C6` instead of `07F4` and `07F0`.
- `07F0`–`07FF`: the reference image carries a small patch routine at the end of the ROM; this chip has other bytes there and nothing jumps to them.

Everything else, including the startup sequence (clear video RAM at C000h, copy ROM to 8000h, reset CTC and 8272, configure the 8255 via port DFh/FEh, draw the logo, scan the keyboard) is byte-identical to the reference.
