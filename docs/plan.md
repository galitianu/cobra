# Repair plan

Work through the phases in order. Each phase has a clear exit test. Don't skip ahead because something "probably works"; a wrong assumption early wastes days later. Record every result in the journal and update the **Status** section below.

## Status

- **Current phase:** 0 (inventory)
- **Board config:** unknown (4116 or 4164 DRAM? 64K/80K mod? FDC fitted? which BASIC EPROM set? which socket holds the boot ROM?)
- **Ruled out:** boot EPROM contents (РФ5 reads stable and is a valid 80K boot)
- **Suspects:** nothing yet

## Phase 0: Inventory (no power needed)

Goal: know exactly what we are working on.

- [ ] Photos of the whole board, both sides, in good light, plus close-ups of every jumper area and the power connector.
- [ ] Chip list: read the markings of every IC, or let the agent read them from the photos. In particular: the **CPU make** (Zilog / SGS / NEC / U880 / Soviet clone; this matters for hypothesis 1), the **DRAMs** (4116 / К565РУ3 = +12/+5/−5 V; 4164 / К565РУ5 = +5 V only), how many DRAMs are fitted (32 = original, 16 = 64K/80K mod), the boot and BASIC EPROMs, the 8255, and whether the floppy board exists.
- [ ] **DRAM socket power check (board unpowered first, then powered without chips if any are socketed):** measure pins 1, 8 and 9 of one socket per bank. The result decides whether the board needs +12 V and −5 V.
- [ ] Is the BASIC EPROM (27512) fitted? If so, read it on the T48 and compare with `rom/reference/SYSTEM_ROM.bin`.
- [ ] Is the board 80K-modified (extra DRAM row, 7411 / diode AND gate)? Is the floppy interface populated?
- [ ] Jumper **SB** (boot EPROM type, next to U89) and DIP switch **SS** (BASIC EPROM type) positions, compared with [hardware.md §6](hardware.md).
- [ ] Look for the known original-PCB layout fixes ([hardware.md §13](hardware.md)): U36/1 to LO6 (critical for startup), U83 pins 6/7 to GND, the I-signal fix, and the BRIGHT diodes. Also look for mod wiring: a 7411 or diode gates, bodge wires around U35/U36/U52/U55/U76.
- [ ] Visual inspection: burnt parts, bulging caps, corroded or broken traces, bent pins under chips, sockets with green corrosion, previous repair work.
- [x] PSU description: the owner built it from a Baby AT PC PSU, wired to a DIN plug. Worked a few years ago.
- [ ] **PSU test, off the board:** measure every pin of the DIN plug with the multimeter, map the pins to J9 (1 +12, 2 GND, 3 +5, 4 −5, 5 GND), and check the levels. Look over the PSU for bulging caps or a burnt smell, and check the fan.
- [ ] PSU loaded test on the board, with the scope on the rails (Phase 1).
- [ ] Exact description of the symptom: border colour, uniform screen vs grid of cells, what kind of display/TV and connection (RF / composite / RGB), whether anything changes when holding keys at power-up, and whether a keyboard is connected at all.

## Phase 1: Power, clock, reset (scope)

Goal: the CPU has everything it needs to run.

- [ ] PSU unloaded: every rail within ±5 %.
- [ ] On the board, loaded: +5 V between 4.75 and 5.25 V at the *far* chips (DRAMs, CPU), not just at the connector. Ripple below ~100 mV p-p (scope AC-coupled, 20 MHz bandwidth limit).
- [ ] If 4116 DRAMs are fitted: +12 V and −5 V present, with −5 V up before +12 V. Capture the power-up with the scope: CH1 −5 V, CH2 +12 V, CH3 +5 V, single trigger.
- [ ] Clock chain: 14 MHz at U57/2, 7 MHz at U61/6, 3.5 MHz at U61/9 and at **Z80 pin 6** (driven by 7407 U74/6 with a 330 Ω pull-up). The high level must be ≥ 4.4 V.
- [ ] Power-on reset: Z80 /RESET (26), NPOR (C15+, U36/4) and POR (U17/8, 8255 pin 35) on three channels, single-shot at power-on. /RESET should rise a few ms before NPOR, with ~20 ms time constants.
- [ ] Memory-config flip-flop after boot: PO (U36/5), LO6 (U36/9). In the startup/logo state both should be HIGH.
- [ ] /RESET (Z80 pin 26): low for a while after power-on, then high and staying high.
- [ ] Static levels: /BUSRQ (25) and /NMI (17) HIGH. /WAIT (24) HIGH with only short low pulses (**stuck low = CPU frozen by the video-RAM prioritiser U02**). /INT (16) HIGH in startup (interrupts only exist in BASIC). /HALT (18) HIGH.

## Phase 2: Is the CPU running the boot ROM?

Using the original РФ5:

- [ ] /M1 (Z80 pin 27), /MREQ (19), /RD (21) active, not stuck.
- [ ] Boot EPROM /CE (pin 18) and /OE (pin 20) pulsing.
- [ ] /HALT high. If it is low, the CPU executed HALT, usually because it ran into garbage.
- [ ] Border colour at the hang, and whether the logo appears briefly.

## Phase 3: Known-good minimal code

- [ ] Verify the socket's pin 21 per [procedures/programming.md](procedures/programming.md), then fit AT28C16 #1 with **boot80k_rf5_fix0** (the owner's ROM with `LD A,83h`). If the board now shows the logo, hypothesis 1 is confirmed, and the fix is simply this ROM.
- [ ] Fit AT28C16 #2 with **diag01_border**. Expected: the border cycles through 8 colours, ~1 s each.
  - **Pass:** CPU, ROM decode, I/O decode, 8255 and video border path work. The fault is in RAM, video RAM addressing, or later boot steps. Go to Phase 4.
  - **Fail:** fit AT28C16 #3 with **diag02_nop** and scope A0–A15, /CE, /M1. That isolates whether the CPU is fetching correctly, whether the ROM is selected, and whether the data bus is clean.

## Phase 4: RAM and video

- [ ] Write a RAM test ROM (no stack, results shown as border colour patterns plus a scope-visible signature) that tests the video bank first, then the other banks, and reports the failing bank and bit.
- [ ] Try cobrasov's 64K STD TEST and HOMOK TEST ROMs. Both are 2K and fit an AT28C16. Check whether the board is 64K or 80K first.
- [ ] Video timing: line sync ~15.6 kHz, frame ~50 Hz. Check that the video address multiplexers switch, and that RAS/CAS reach the DRAMs.
- [ ] Replace or reseat suspect DRAMs one at a time.

## Phase 5: BASIC, keyboard, full boot

- [ ] BASIC EPROM verified on the T48 against the reference.
- [ ] Keyboard connected and the matrix scanning; no false key presses.
- [ ] Boot to the Spectrum copyright message.

## Phase 6: Peripherals and hardening

- [ ] Tape load (Pico or Raspberry Pi playing `.tap` audio into EAR).
- [ ] Floppy, if fitted.
- [ ] Long burn-in: leave it running for an hour, then check temperatures.
- [ ] Final ROM decision: keep the РФ5, or move to an AT28C16 / 27C512 set.

## Open hypotheses

Rank and update these as evidence arrives.

1. **The ROM's first instruction is `LD D,83h`, not `LD A,83h`.** If this board's Z80 doesn't power up with A bit 7 = 1, R7 = 0. Once NPOR rises (~20 ms), the boot EPROM drops out of the map, partway through the screen clear: a partly blank screen, then a hang. **Cheap test: AT28C16 #1 = `boot80k_rf5_fix0`.** Note that the cobrasov reference image has `LD A,83h`.
2. **Bank #0 DRAM / 64K-bank fault.** The 80K boot first uses bank #0 right after the screen clear (copying the ROM to 8000h, then the first PUSH at 0096h). A blank screen and no logo fits this well.
3. **Power problem:** missing −5 V / +12 V for 4116s, bad sequencing, or a marginal +5 V from the home-made PSU.
4. **Board/ROM mismatch:** an 80K boot on a 64K or unmodified board (O6 = 1 behaviour differs), or swapped boot/BASIC sockets.
5. **CPU frozen in /WAIT** (U02 prioritiser), or the memory-config latch U36 not behaving (including the original U36/1 layout bug).
6. Video RAM bank #1 / video address mux (74LS153 vs 74ALS153) fault, so the screen doesn't show what the CPU wrote.
7. False key press from floating keyboard inputs. Less likely: the mainboard has 4K7 pull-ups on K0–K5.
