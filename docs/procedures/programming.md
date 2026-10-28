# Programming and reading ROMs with the T48

All commands run on the Mac. `minipro` is installed via Homebrew. 2716-type chips have no electronic ID, so always pass `-y` to skip the ID check.

## Placing the chip in the ZIF socket

- Use the same orientation as the reference picture on the T48 case: the 24-pin chip pushed fully to the **bottom** of the 40-pin socket, notch / pin 1 towards the **lever**. If unsure, ask for a photo before powering anything.
- Run a contact check before every write. A bad contact gives silent garbage:

  ```sh
  minipro -p AT28C16@DIP24 -z      # pin contact check
  ```

## AT28C16 (the 4 new EEPROMs)

```sh
minipro -p AT28C16@DIP24 -y -r readback.bin            # read
minipro -p AT28C16@DIP24 -y -w rom/custom/diag01_border.bin   # erase+write+verify (automatic)
minipro -p AT28C16@DIP24 -y -m rom/custom/diag01_border.bin   # verify only
minipro -p AT28C16@DIP24 -y -o vcc=4.5 -m image.bin           # verify at 4.5 V (margin)
```

- Images must be exactly 2048 bytes. `tools/rom/build.sh` pads custom ROMs with FFh.
- Label each chip with a sticker showing what is on it, e.g. `D1 diag01`, and log it in the journal.

**Chip allocation plan:**

| Chip | Content |
|---|---|
| AT28C16 #1 | `rom/custom/boot80k_rf5_fix0.bin`: the РФ5 image with only byte 0 changed, from `16` (`LD D,83h`) to `3E` (`LD A,83h`). Tests hypothesis #1 in [plan.md](../plan.md). |
| AT28C16 #2 | `diag01_border` |
| AT28C16 #3 | `diag02_nop` |
| AT28C16 #4 | spare: RAM test ROM / cobrasov test ROMs |

## К573РФ5 (original Soviet 2716)

- **Read:** `minipro -p AM2716@DIP24 -y -r dump.bin`. Read it three times and compare MD5s.
- **Verify against our copy:** `minipro -p AM2716@DIP24 -y -m rom/dumps/K573RF5_boot80k_original.bin`
- **Write:** only after a UV erase of 30–40 minutes and a blank check (`-b`). Needs 25 V VPP and a 50 ms pulse: `-o vpp=25 -o pulse=50000`. This is untested with our T48 firmware. Don't do it unless we really need to; the AT28C16s make it unnecessary.

## Comparing images

```sh
cd tools && uv run python rom/romdiff.py a.bin b.bin
```

## AT28C16 in the CoBra socket: check pin 21 first

A 2716 uses pin 21 as VPP, which must sit at +5 V when reading. On the AT28C16, pin 21 is **/WE (write enable)**. If the board holds that pin at +5 V, the chip is read-only on the board, which is what we want. If the board connects it to an address line (possible if the socket is a 28-pin socket with size jumpers), CPU writes into the ROM address range could **overwrite the EEPROM**. That's harmless to the hardware but confusing.

On the original board, the boot socket U89 is a 28-pin socket. The 24-pin chip sits in the lower 24 positions, so chip pin 1 lands in socket pin 3 and **chip pin 21 lands in socket pin 23**. Jumper **SB** selects what socket pin 23 sees: **1-2 = VCC (2716 mode)**, 3-4 = BA11 (2732/2764 mode). See [hardware.md §6](../hardware.md).

**Before the first AT28C16 goes into the board:**

1. Confirm from a photo that SB is in the 2716 position (1-2).
2. With the board **unpowered** and the socket empty, measure resistance from socket pin 23 to socket pin 26 (VCC). It should read ~0 Ω.
3. Confirm which socket actually holds the boot ROM. Some modified boards swap the boot and BASIC sockets.
