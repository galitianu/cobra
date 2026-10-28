# History: what we learned before this project folder existed

Source: bb thread `thr_jhfvizuhfe` ("CoBra board analysis", 2026-10-10). This file keeps the facts from it so nobody has to re-read the thread.

## The machine and the symptom

- **CoBra** is a Romanian Z80A computer from Brașov, compatible with the ZX Spectrum 48K and able to run CP/M with the floppy add-on. Main reference: [cobrasov.com](https://cobrasov.com).
- The owner has the **bare mainboard** and built a **home-made power supply** for it.
- **Symptom:** on power-up the screen initialises to "blank characters" and nothing else happens. We still don't know the exact border colour, or whether the screen is uniform or a grid of cells. Ask about this first (see [plan.md](plan.md)).

## How the boot ROM works (summary of cobrasov.com disassemblies)

Standard 64K boot:

1. `LD A,80h / LD R,A`. Bit 7 of the Z80 R register drives the latch that keeps the board in the **startup memory map** (boot EPROM at 0000h, video RAM at C000h).
2. Clears video RAM C000h–DAFFh with 00h (attribute 00h is black on black). The clear also gives the 8255 its settling time after reset.
3. Programs the 8255 (`OUT (DFh),92h`), then writes `40h` to port FEh, which sets the border to black.
4. Draws the CoBra logo in the middle third of the screen (cyan/magenta attributes), then loops forever, scrolling it and scanning the keyboard on port FEh.
5. A key press leaves the loop. K0/K1 columns load BASIC: they copy the BASIC EPROM to RAM with a red or cyan border, clear R bit 7 and jump to 0000h, so Spectrum BASIC runs from RAM. K2 boots the floppy, K3/K4 run tape load/verify.
6. Spectrum BASIC then sets a white border, clears to white paper and prints the copyright message.

The **80K boot** also copies itself to DRAM at 8000h, resets the CTC (ports E3/EB/F3/FBh) and puts the 8272 FDC in standby (`OUT (FDh),0`) before the logo.

**How to read the border colour at the hang:**

| Observation | Meaning |
|---|---|
| black border + black screen | never finished drawing the logo, or video reads different RAM than the CPU writes |
| red/cyan border | a key press was detected (possibly a false one from floating keyboard inputs); the BASIC copy or memory-map switch failed |
| white border + white screen | Spectrum BASIC started and crashed, usually lower RAM or RAM timing |
| grid of distinct empty cells | attribute area holds non-uniform data, i.e. the clear never reached it (DRAM bank or addressing problem) |

**Floating keyboard trap:** with no keyboard, or with open 8255 port inputs, the ROM can see a false key press and leave the logo loop immediately.

**Correction (2026-10-28):** the original board was designed for **4116** DRAMs (+12/+5/−5 V). 4164s only appear on 64K/80K-modified boards. See [hardware.md §11](hardware.md).

Known board fixes from cobrasov.com: a 150 pF capacitor on RAS, 74ALS153 video address multiplexers, a 7411 replacing the 3-diode AND gate in the 80K modification, and chips that run hot. 4164 DRAMs are noise-sensitive. The design relied on 200 ns parts after 120 ns ones failed.

## The boot EPROM: К573РФ5

- Soviet 2716 equivalent: 2K×8, 24-pin, standard 2716 pinout, 5 V read, **25 V VPP with a 50 ms program pulse** per byte, ~450 ns access time.
- Read on 2026-10-10 with the XGecu T48 using `minipro -p AM2716@DIP24 -y -r dump.bin`. Three reads were identical and a verify at VCC = 4.5 V passed, so **the chip is healthy and its data is stable**.
- MD5 `c79c66140c44dc0346a823e96a31f0e2`, saved as [rom/dumps/K573RF5_boot80k_original.bin](../rom/dumps/K573RF5_boot80k_original.bin).
- Published for posterity as a public gist: https://gist.github.com/galitianu/32a524e600a784fa2823dbd38377ee99
- **Content:** the CoBra "Standard BOOT 80K", a slightly different revision of cobrasov's `BOOT_2K_COBRA_80K.bin` (MD5 `5f6d17b8765fb16dd89422690baa9e57`). It differs in 22 bytes:
  - `0000`: `16 83` (`LD D,83h`) instead of `3E 83` (`LD A,83h`) before `LD R,A`. It still works because A = FFh after a Z80 reset, which keeps R bit 7 set.
  - `011A–011D` and `0128–0129`: two keyboard-dispatch jumps go to `005E` and `04C6` instead of `07F4` and `07F0`. Both targets are valid code.
  - `07F0–07FF`: the published image has a small patch there (it sets 8255 PC7 = "SO" = BASIC EPROM A14, then `RST 38h`). This chip has other bytes there, and nothing jumps to them.
- 19 of the 22 differing bytes need a 0→1 bit change, so turning this chip into the reference image requires a **UV erase** first.
- **Open question:** this is an *80K* boot. If the board is a plain 64K machine, or has no floppy interface, this ROM may not suit it. We still don't know which the board is.

## Programmer facts

- XGecu **T48**, driven on macOS by open-source `minipro` 0.7.4 (Homebrew). XGecu's own Xgpro only runs on Windows.
- T48 firmware **00.1.03**, while minipro expects 01.1.32 and warns that T48 support is incomplete. Reads and verifies work fine.
- minipro's stock 2716 profiles use 18 V VPP. A 25 V write to the РФ5 would need `-o vpp=25 -o pulse=50000`, which is untested. Only Xgpro on Windows can update the T48 firmware.
- The owner has since bought **4× AT28C16** EEPROMs. They are 5 V-programmable 2716 drop-ins that need no UV and no 25 V, so they are the main experimentation chips now.

## Replacement chips (for later)

- 2716 socket: **AT28C16** (in production).
- 27C512 sockets (BASIC, larger boot images): Winbond **W27C512/W27E512**, **SST27SF512** (electrically erasable, NOS), or Microchip **AT27C512R** (OTP, in production).
- Avoid AT28C256 as a 27C256 drop-in (pins 1 and 27 differ), and 32-pin 39SF0x0 flash, which needs an adapter.
