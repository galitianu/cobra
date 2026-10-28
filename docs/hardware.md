# CoBra mainboard: technical reference

A short reference for repair work, built from the sources listed below. Every section names its sources. **UNVERIFIED** means the sources disagree, or the point is an inference that hasn't been checked on the owner's board. Confirm those points on the board before acting on them.

U-numbers follow the **original 1988 hardware manual** (factory/original-layout boards, PCB "921442431", layout rev.3). cobrasov.com's reproduction boards (v0.2, v1.2, v1.3) **renumber some parts**: on v0.2, for example, U01 is the 27512 BASIC EPROM and the jumpers are JP1–JP24. Before using a pin number, check which board it applies to.

## Sources

| Tag | File (under `references/` unless noted) | What it is |
|---|---|---|
| HWM | `cobrasov/CoBra_Hardware_Manual_rev.1.0.pdf` | English re-edition of the 1988 ITCI Brașov hardware manual. Text, block diagrams, schematics A1.1–A1.15 and A2.1–A2.3, parts lists. Page numbers below are PDF pages, which equal the printed page numbers. **Primary source.** |
| SCAN | `cobrasov/original_manual_scans/pag01–70.jpg` | Scan of the original Romanian manual (70 pages). pag70 is the **mainboard component placement**, which the English PDF lacks. pag64–69 cover the power-supply PCB and RGB monitor interface. |
| REV0 / REV02 / REV12 / REV13 | `cobrasov/pages/txt/rev0.txt`, `rev0.2.txt`, `rev1.2.txt`, `rev1.3.txt` | cobrasov.com mainboard pages: layout bugs, build notes, fixes |
| CONN | `cobrasov/mods/Mainboard_Modifications_Connection_changes.pdf` | Full list of track cuts and rewires on an original rev.3 board (layout bugs plus the 64K, 80K and 80-column mods) |
| DOCS | `cobrasov/pages/txt/docs.txt` and `cobrasov/pages/images/docs__*.jpg` | Scans of period notes: 64K mod, 80K mod, 80K memory map, PAL coder |
| JMP02 / SCH02 | `cobrasov/schematics/Jumper_settings_main_board_v0.2.pdf`, `Scheme_microcalculator_CoBra_v0.2_sch3.17e_mod0.4a.pdf` | Reproduction board v0.2 jumpers and schematics |
| SCHv0 / v1.2 / v1.3 | `cobrasov/schematics/Scheme_microcalculator_CoBra_v0_original.pdf`, `…v1.2_64K_rom_bugfix.pdf`, `…v1.3_80K.pdf` | gschem redraws (Romanian) |
| BOOT | `cobrasov/pages/txt/boot.txt` | cobrasov boot-ROM page |
| ASM64 / ASM80 | `rom/reference/BOOT_2K_COBRA_64K_compilable.asm`, `BOOT_2K_COBRA_80K_updated_compilable.asm` | Commented disassemblies of the standard boot ROMs |
| CET | `ceteras-CoBra/mainboard/2layer/kicad/main.kicad_pcb` (+ `main.pdf`) | ceteras' KiCad re-creation of the original board with the **original U-numbers**. Pin-to-net data in this file was extracted with a script and matches HWM wherever both cover a pin. |
| LDT | `ldtlb-blog/cobra-about.md` (Romanian) | Tom Sowell's 2022 build log (cobrasov v0.2 board): debugging notes |

---

## 1. Chip list with designators

Sources: HWM p.26–29 (parts lists), HWM p.40–58 (schematics), SCAN pag70 (placement). U52's type comes from the HWM p.41 note and CET.

### Mainboard

| Ref | Type | Function |
|---|---|---|
| U90 | Z80A CPU | 3.5 MHz CPU |
| U71, U72, U73, U74 | 74(LS)07 (CDB407) | **Open-collector** CPU→bus buffers for address and control lines. Bus pull-ups are 21× 620–680 Ω (R45–R47, R49–R66). U72 also drives /INT, and U74 also buffers the CPU clock. |
| U79 | i8255 PPI | Keyboard, tape, border, speaker, RS-232, joystick/parallel, configuration bit O6 |
| U76 | i8212 | Latch that returns video-DRAM data to the CPU data bus |
| U89 | 2716 (2732/2764/27128) in a 28-pin socket | **BOOT EPROM** |
| U01, U18, U23, U42, U59, U75, U84, U91 | 8× 2716 or 4× 2732 | 16 KB BASIC EPROM set. With 4× 2732, U59/U75/U84/U91 are used and U01/U18/U23/U42 stay empty (HWM p.42). |
| U70 | 74LS42 | BASIC EPROM /OE decoder (N0→U91 … N7→U01) |
| U56 | 74LS42 | Memory decoder (boot /OE, BASIC /OE, bank CAS selects) |
| U36 | 74LS74 | **Memory-configuration flip-flops** (PO, LO6) |
| U04–U11 | 8× 4116 | DRAM **bank #1 = video RAM** (16 KB) |
| U24–U31 | 8× 4116 | DRAM bank #0 |
| U62–U69 | 8× 4116 | DRAM bank #2 |
| U43–U50 | 8× 4116 | DRAM bank #3 |
| U41, U58 | 74157 | Row/column address multiplexers for system DRAM (banks 0, 2, 3) |
| U03, U20, U22, U39 | 74(LS)153 | Video-DRAM address multiplexers (CPU vs video controller) |
| U51 | 74LS157 | Video page-mode column address switch |
| U02 | 74LS74 | Memory-access prioritiser, which generates **/WAIT**, plus VMA |
| U57 | 74LS04 | 14 MHz crystal oscillator gates, and inverters |
| U61 | 74LS74 | ÷2 → SCLK 7 MHz, ÷2 → CLK 3.5 MHz |
| U60 | 7495 | Johnson counter ÷8 (character timing) |
| U77, U78, U81, U82, U83 | 7495 | Pixel and attribute shift/hold registers |
| U80, U85 | 74LS157 | Ink/paper select and border select |
| U86 | 7407 | RGBI and sync output drivers |
| U12, U13 | 74LS193 | Horizontal counter ÷56 |
| U32, U33 | 74LS193 | Vertical counter ÷312 |
| U15 | 74LS74 | Vertical counter stage / NBRD |
| U14, U40 | 74LS10 | Gates |
| U52 | **74LS11** | 3-input AND. The 1988 schematic says 7410, but the PCB needs 7411 (HWM p.41 note, CET). |
| U16, U17, U37, U54, U55, U87 | 74LS00 | Gates. U17 handles reset/interrupt gating and the POR inverter. U54/U55 build NCSx, NIORD and NIOWR. |
| U19, U38 | 74LS08 | Gates |
| U21 | 74LS51 | AOI (video RAS/CAS) |
| U34 | 74LS20 | Vertical decode (NVS) |
| U35, U88 | 74LS86 | XOR. U35 does address remapping and the 8255 chip select. U88 handles FLASH and sync. |
| U53 | 74LS04 | Inverters (RFSH, RD, IORQ, MREQ, WR, ICS) |
| U92 | 741 | Tape-input comparator (runs from +5 V and −5 V) |
| T1 | 2N2222 | Composite video output |
| T2 | BC251 | RS-232 TxD level shifter |
| Xtal | 14 MHz | Master clock |
| K1 | push button | RESET |
| SB | switch/jumper ("sb SWITCH" in the parts list) | Boot EPROM type |
| SS | DIP switch | BASIC EPROM type / address mapping |

### Floppy interface board (separate PCB, "CX-FDC rel 2.0")

Source: HWM p.26 and p.56–58. U01 Z80A-CTC, U02 i8272A, U03 74LS14, U04 74LS153, U05 74155/156, U06 7438, U07 74S174, U08 74193, U09 74LS74, U10 74LS08, U12 74LS153, U13 74S188 PROM (digital PLL table on HWM p.19), U14 74LS10, U15 74LS51, U16 74LS04, U17 74LS74, U18 7495, 16 MHz crystal, DIP switch SD0–3 selecting 8 or 4 MHz per drive.

### Where the chips sit

Source: SCAN pag70, as drawn, with J3/J4 at the top edge. Confirm against the real board with a photo.

- Z80 **U90** is top right. The reset button K1 and power connector J9 are at the top right corner.
- 8255 **U79** is top centre-left, with i8212 U76 to its left. The video registers U77–U88 are in the top-left area.
- **U89 (boot EPROM)** is a tall 28-pin socket right of U79, directly below the SB jumper. Its pin-1 notch is at the top.
- The BASIC EPROMs form a column right of U89: U91 (top), U84, U75, U59, U42, U23, U18, U01 (bottom).
- The DRAM is a 4×8 block on the left. From the top: U62–69 (bank 2), U43–50 (bank 3), U24–31 (bank 0), U04–11 (bank 1, video, bottom row).
- The 14 MHz crystal is between the DRAM block and the TTL column, beside U57/U40.
- The TTL logic is the block to the lower right: U70, SS, U71–74 top row; U51–U56, U58; U32–U38; U12–U17.

---

## 2. Clocks

Sources: HWM p.5, p.12, p.17, p.44, p.57. Pin numbers from CET.

| Signal | Freq | Where |
|---|---|---|
| XCLK | 14 MHz | Crystal oscillator U57/13→12 and U57/1→2 (R38, R35 680 Ω; C24 220 pF; C30 15 pF). Output U57/2 → U61/3. |
| SCLK (dot clock) | 7 MHz | U61/6 (also U61/2 and U61/11) |
| CLK (CPU) | 3.5 MHz | U61/9 → U74/5 → **U74/6** (open collector, R70 330 Ω pull-up) → **Z80 pin 6** |
| Character clock | 875 kHz (1.143 µs) | U60 Johnson counter outputs QA–QD |
| Line | 15.625 kHz (64 µs = 56 characters) | U12/U13 |
| Frame / INT | 50 Hz (312 lines, ≈20 ms) | U32/U33/U15 |
| FDC clock | 16 MHz crystal ÷2 or ÷4 = 8 or 4 MHz | Floppy board U16/U17/U04 |

The Z80 clock comes from a **7407 open-collector output with a 330 Ω pull-up**. Expect slow rising edges, and check that the high level reaches about 4.4 V or more. The Z80 needs VCC − 0.6 V on CLK.

---

## 3. Reset and power-on circuit

Sources: HWM p.9–10, p.41 (Fig. A1.2); BOOT ("Difficulties in writing…"); CET.

- **NRST** (Z80 pin 26) is pulled up by **R09 2K2**.
- **NPOR** is the voltage on **C15 10 µF**. It charges from NRST through **P02 (D02) 1N4148**, so NRST stays about 0.6 V above NPOR and the **CPU leaves reset a few ms before NPOR goes high**. P03 discharges C15 into VCC at power-off. Time constant ≈ 2.2 kΩ × 10 µF ≈ 22 ms.
- NPOR drives **U36/4 and U36/10 (/PRESET)**, which forces both configuration flip-flops to 1 (the startup configuration) during power-up.
- **POR = NAND(NPOR, NPOR) at U17/8**. It drives **8255 RESET (pin 35)**, active high. The 8255 therefore leaves reset *after* the CPU, so the boot code must wait (it clears the screen first) before programming the 8255.
- **RESET button K1** connects BNM1 to U17/1,2 (R06 1K pull-up). NMR = U17/6 = NAND(M1R, VLD) pulls NRST low through P01. The button only acts **during an M1 cycle inside the VLD window**.
- **Do not press RESET in the startup (logo) configuration.** Reset clears R, so R7 = 0 and the board falls into a random memory configuration (HWM p.10). To restart from the boot ROM, power-cycle. cobrasov boards later added a separate "COBRA RESET" (REV02).
- The original PCB layout had **U36/1 wired to U36/5 (PO) instead of LO6 (U36/9)**. CONN marks this "Critical. Affecting computer startup", fixed by cut #5 side 2 and wire #1 side 2. A working original board should carry this fix.

---

## 4. Memory configuration logic (R register bit 7, U36)

Sources: HWM p.8–11, p.41; BOOT; CET.

- **U36 first half (D-FF)**: D (pin 2) = **BA7**, CLK (pin 3) = **RFSH** (U53/2, the inverted BNRFSH), /PRE (pin 4) = NPOR, /CLR (pin 1) = **LO6**, Q (pin 5) = **PO**, /Q (pin 6) = **NPO**.
  At every refresh cycle the Z80 puts R on A0–A7. This FF samples **R bit 7**, so `LD R,A` with bit 7 = 1 holds the startup configuration.
- **U36 second half**: D (pin 12) = **O6** (8255 PC6, with R27 1K pull-up to VCC), CLK (pin 11) = NPO, /PRE (pin 10) = NPOR, /CLR (pin 13) = VCC, Q (pin 9) = **LO6**, /Q (pin 8) = **NLO6**.
- Switching sequence: `OUT (FEh)` with O6 set as required, then `LD R,A` (bit 7 = 0), then `JP (HL)`. The map changes after the `JP (HL)` opcode fetch (HWM Fig. 3).
- In BASIC (LO6 = 0), /CLR on U36/1 holds PO = 0, so changes to R7 are ignored. CP/M can return to startup (`DI; LD HL,0; LD A,80h; OUT (FEh),A; LD R,A; JP (HL)`, from DOCS 80K memory map scan). Going from CP/M to BASIC must pass through startup (BOOT).

| Configuration | PO (U36/5) | NPO (U36/6) | LO6 (U36/9) | R7 |
|---|---|---|---|---|
| Startup ("COBRA") | 1 | 0 | 1 | 1 |
| CP/M | 0 | 1 | 1 | 0 |
| BASIC (Spectrum) | 0 | 1 | 0 | 0 |

A 150 pF capacitor from **U36/3** to GND was needed on cobrasov's v0.2 build. Without it, the RFSH edge sampled BA7 before it was stable: pressing D gave one blue border flash and then a hang, with LO6 falling to 0 (REV02). Rev.3.17e replaced it with a gated MRFSH.

---

## 5. Memory map

Sources: HWM p.11 Fig. 4. The U56 decode was cross-checked by working through Fig. A1.2 (p.41). The 80K map is from the DOCS scan `docs__CoBra_80k_-_Harta_Memoriei.jpg`.

### Original 64K board (4 banks × 16 KB)

| Address | Startup | CP/M | BASIC |
|---|---|---|---|
| 0000–3FFF | **BOOT EPROM U89** (2 KB mirrored or larger) | bank #2 | bank #0 (**read-only**: writes blocked by U54/11) |
| 4000–7FFF | **BASIC EPROM** (U91…U01) | bank #3 | **bank #1 video** (screen at 4000, attributes at 5800) |
| 8000–9FFF | ½ bank #0 | ½ bank #0 | bank #2 |
| A000–BFFF | bank #1 (video, upper 8 KB) | bank #1 | bank #2 |
| C000–DFFF | **bank #1 video** (screen **C000–D7FF**, attributes **D800–DAFF**) | bank #1 video | bank #3 |
| E000–FFFF | other ½ bank #0 | ½ bank #0 | bank #3 |

- Video RAM is bank #1 (U04–U11). The CPU sees it at **C000h in startup and CP/M** and at **4000h in BASIC** (HWM p.11–14).
- In BASIC, Spectrum BASIC is copied from EPROM to bank #0 and runs from RAM there (bank #0 becomes read-only).
- U56 (7442) inputs are A (pin 15) = AB14 = BA14 XOR (BA13·BA15·LO6), B (pin 14) = AB15 = BA15 XOR LO6, C (pin 13) = NPO, D (pin 12) = NS = NAND(MREQ, /RFSH). Outputs: pin 3 N2 = **NOEB** (boot /OE), pin 4 N3 = **NOES** (BASIC /OE via U70), pins 1/5 N0/N4 → **NCS0**, pins 2/6 N1/N5 → **CS1/NCS1** (video), pin 7 N6 = **NCS2**, pin 9 N7 = **NCS3**.
- **The DRAM bank selects are CAS lines.** RAS for banks 0/2/3 is **BNMREQ** on every memory cycle (HWM p.43). WE = RD.
- Refresh: banks 0/2/3 use Z80 refresh (7-bit R on A0–A6, RAS via MREQ). Bank #1 is refreshed by the video controller's reads, one every 1.14 µs (HWM p.14).

### "64K modification" and "80K modification"

Sources: CONN notes; REV12; REV13; DOCS scans; HWM p.54 Fig. A1.15; REV02.

- **64K mod**: banks #0, #2 and #3 (48 KB of 4116) are replaced by **one bank of 8× 4164 (64K×1)**, of which only 48 KB is addressed. Typically it goes in the U24–U31 position, though any of the three works. Changes:
  - CAS for the 64K bank = AND(NCS0, NCS2, NCS3) through a 7411 gate (U52), then R33 33 Ω.
  - **DRAM pin 9 = A7** from a free 74157 section (U58/4, inputs AB15/AB14) through R34 33 Ω.
  - Pin 8 (VDD +12 V on 4116) is rewired to **+5 V**.
  - VBB is removed from pin 1.
  - Bank #1 (video) can stay 4116 or be changed to single-supply parts.
  Total RAM is still 64 KB.
- **80K mod** (needs the 64K mod first): the whole 64 KB of the 4164 bank plus the 16 KB video bank become addressable. **8255 PC6 (O6) then selects between video RAM and "RAM1"** in one 16 KB window:

| Address | Startup ("Cobra") | CP/M | BASIC |
|---|---|---|---|
| 0000–3FFF | BOOT | RAM0 | RAM0 (read-only) |
| 4000–7FFF | BASIC/OPUS EPROM | **RAM1 (O6=0) / VRAM (O6=1)** | RAM1. The scan marks this window "RAM1+VRAM" for writes, i.e. writes probably reach both so that the screen at 4000h is displayed (UNVERIFIED reading of a hand-drawn note). |
| 8000–BFFF | RAM0 | RAM2 | RAM2 |
| C000–FFFF | **RAM1 (O6=0) / VRAM (O6=1)** | RAM3 | RAM3 |

  Hardware: U35/9 is fed from **PO instead of LO6**. CS1 for the i8212 (U76/13) and NCS1 (U02/1) are regenerated from diode-AND gates (Fig. A1.15). The **3-diode AND gate (D19/D20/D21 on cobrasov boards) misbehaves and is usually replaced by a 7411 gate** (REV02, LDT). The 80K boot ROM writes `40h` to port FEh (O6 = 1) "to allow access to video memory in the startup config" (ASM80, line 0032).
- **How to tell 64K from 80K on the bench (inference, UNVERIFIED):**
  - Count populated DRAM chips: 32 means original 64K; 16 means 64K- or 80K-modified.
  - Look for the 4164/К565РУ5 marking.
  - Look for a 7411 or diode gates and bodge wires around U35, U36, U52, U55 and U76/13.
  - Measure DRAM pin 8 (+12 V means 4116 wiring, +5 V means single-supply wiring).

---

## 6. EPROM sockets and jumpers

Sources: HWM p.42 Fig. A1.3 (+ notes); REV0; JMP02; SCH02 p.10; REV02; CONN; BOOT.

### Original board

- **U89 boot EPROM**, 28-pin socket. **/CE (socket pin 20) = NPO** (U36/6) and **/OE (socket pin 22) = NOEB** (U56/3), so it is enabled only in the startup configuration. Socket pins 1, 27 and 28 = VCC, pin 2 = BA12, **pin 26 = VCC**.
  - **Jumper SB**: **1-2 = 2716** (pin 23 = VPP tied to VCC), **3-4 = 2732/2764** (pin 23 = A11 = BA11).
  - A **27128 can't use its upper 8 KB**, because pin 26 (A13) is hard-wired to VCC. Rewiring it to BA13 would allow 16 KB (REV0).
  - A **24-pin 2716 (К573РФ5)** sits in the lower 24 positions, so its pin 1 lands in socket pin 3. Chip pin 18 /CE = socket 20, chip pin 20 /OE = socket 22, chip pin 21 VPP = socket 23 (**must be +5 V, SB 1-2**), chip pin 24 VCC = socket 26, chip pin 12 GND = socket 14. (Standard 2716-in-28-pin practice. UNVERIFIED on this board until checked with a photo.)
- **BASIC EPROMs**: /CE (2716 pin 18) = NPO. /OE (pin 20) from U70 outputs N0…N7 → U91, U84, U75, U59, U42, U23, U18, U01. Pin 21 = VPP/A11 from SS. **SS DIP switch**: 1-16 = 2716, 2-15 = 2732, as printed on HWM p.42. The per-pole mapping of BA11, BA12 and BA13 to U70 A/B/C is not fully legible (UNVERIFIED).
- The common **27512 single-chip BASIC mod** (CONN):
  - NOES goes directly to the 27512's /OE.
  - **8255 PC7 "SO" (U79/10) drives EPROM A14.** By convention, Spectrum BASIC sits at 4000–7FFF of a 32 KB image, so SO = 1 selects it (BOOT).
  - A15 comes from a manual switch.
  - cobrasov's own board swapped roles: **boot 2716 in the U23 position and the BASIC 27512 in U89** (CONN rewire #5, #6). The owner's board may have been modified like this. Check which socket really holds the РФ5.

### cobrasov v0.2 reproduction board (for reference only)

| Jumper | 2716 | 2732 | 2764 | 27128 | 27256 | 27512 |
|---|---|---|---|---|---|---|
| JP7 (U89/23) | 2-3 | 1-2 | 1-2 | 1-2 | 1-2 | 1-2 |
| JP8 (U89/26) | 2-3 | 2-3 | 2-3 | 1-2 | 1-2 | 1-2 |

- JP22 and JP23 select boot A15/A14, for 27256/27512 chips holding several boot images.
- BASIC 27512: JP1/JP2 set A15/A14 manually. JP3/JP4 hand them to software: **TO (PC3) → A15, SO (PC7) → A14**.
- JP5, JP6 and JP10–JP19 choose Std 64K / 64K-mod / 80K / 80-column.
- JP9 makes the BASIC RAM R/O or R/W.
- JP24 chooses the DRAM A7 source for 7-bit or 8-bit refresh (REV02, JMP02).

---

## 7. I/O port map

Sources: HWM p.16–17, p.50, p.56; ASM64/ASM80; CET. Decoding is **partial**: each device looks at only one or two address lines.

| Device | Select logic | Ports used by ROMs | Notes |
|---|---|---|---|
| **8255 U79** | /CS = NOT(BA0 XOR BA5): selected when **A0 ≠ A5**. 8255 A0 = BA0, **8255 A1 = BNRD** (read/write steers the port). | **FEh**: read = Port A, write = Port C. **DFh** (and 1Fh): read = Port B, write = control. | Reads with A0=0, A5=1 give Port A; reads with A0=1, A5=0 give Port B (Kempston 1Fh). Writes with A0=0 go to Port C; writes with A0=1 go to the control register. Init: **`OUT (DFh),92h`** (A in, B in, C out, mode 0). |
| **Z80-CTC** (FDC board U01) | /CE = **BA2** (low), CS0 = BA3, CS1 = BA4 | **E3h** ch0, **EBh** ch1, **F3h** ch2, **FBh** ch3 | Mode 2 interrupts for FDC byte/sector events. ch0 counts bytes; ch1+ch2 cascade for end of sector and drive the 8272 TC. |
| **i8272A FDC** (FDC board U02) | /CS = **BA1** (low), A0 = BA3 | **F5h** = main status register (read), **FDh** = data register | **Not FCh.** FCh also has A0=0/A5=1 and would select the 8255 as well. Spectrum AY add-ons at xxFDh collide with the FDC data port (LDT). |
| I/O strobes | NIORD = NAND(RD, IORQ) at U54/6. NIOWR = NAND(WR, IORQ) at U54/8. | | |

The ports were chosen so that A0 = A5 and A1 = A2 = 1 where needed, which keeps the devices out of each other's way. **Original PCB bug:** JEXA/8 (FDC /CS) was wired to BA7 instead of BA1. CONN cut #11 side 1 and wire #22 side 2 fix it ("Critical, floppy").

---

## 8. 8255 port assignments (U79)

Sources: HWM p.16–17, p.50 Fig. A1.11, p.51–52; CET for pin numbers.

| Port bit | 8255 pin | Signal | Function |
|---|---|---|---|
| PA0–PA3 | 4, 3, 2, 1 | K0–K3 | Keyboard columns (Spectrum bits 0–3) |
| PA4 | 40 | K4 | Keyboard column (bit 4) |
| PA5 | 39 | K5 | 6th column (CoBra extra keys such as CTRL); also J5/9b |
| PA6 | 38 | TI | **EAR / tape input** (U92 741 comparator, R98/D9/D10 limiter) |
| PA7 | 37 | SI | RS-232 RxD (R94, Zener D05) |
| PB0–PB7 | 18–25 | PB0–7 | Joystick (Kempston PB0 right, PB1 left, PB2 down, PB3 up, PB4 fire) and 8-bit input port on J5. R99–R106 8K2 pull-**downs**. |
| PC0–PC2 | 14, 15, 16 | B0–B2 | **Border colour** |
| PC3 | 17 | TO | **MIC / tape out** (R89/R97, P06/P07) |
| PC4 | 13 | LS | **Speaker** (C45 → J7/3a "DIF", J3) |
| PC5 | 12 | O5 | General output / parallel-port strobe. Used by the 80-column mod. |
| PC6 | 11 | O6 | **Memory-configuration bit** → U36/12 (R27 1K pull-up). In the 80K mod it also selects VRAM or RAM1. |
| PC7 | 10 | SO | **RS-232 TxD** (U87/12,13 inverter → T2 BC251). On 27512-BASIC mods it is also **BASIC EPROM A14**. |

- **Keyboard**: rows are the high address lines **A8–A15**, each through a diode P11–P18 (1N4148) to J7 (KA8–KA15). Columns K0–K5 have **4K7 pull-ups R108–R113 on the mainboard** (HWM p.52). With no keyboard attached, every column should read 1, meaning no key. The CoBra keyboard is an 8×6 matrix plus 10 compound keys (HWM p.19–22).
- Control pins: **/RD pin 5 = NIORD (U54/6)**, **/WR pin 36 = NIOWR (U54/8)**, **/CS pin 6 = NICS (U53/6)**, **A0 pin 9 = BA0**, **A1 pin 8 = BNRD**, **RESET pin 35 = POR (U17/8)**, VCC pin 26, GND pin 7, D0–D7 pins 34…27.

---

## 9. Video generation (overview)

Sources: HWM p.11–15 (Figs. 5–8), p.44–49, p.53.

- **Timing chain**: 14 MHz → U61 → SCLK 7 MHz → U60 7495 Johnson ÷8 (QA–QD). The decode gates U38, U40, U21 and U19 produce:
  - video RAS (VNRS, through **CVR 390 pF**) and video CAS (VNCS, **CCS 150 pF**, **CCC 390 pF**);
  - STB, SLD, SM, S0.
  U12/U13 (÷56) give the character address and HB/HS. U32/U33/U15 (÷312) give the line, row and third, plus NVS, NBRD and **VLD** (vertical).
- **Video address**: the video controller reads bank #1 in page mode (RAS, CAS, CAS: bitmap byte, then attribute byte) once per character (1.14 µs). U03, U20, U22 and U39 (74153) switch between CPU address (BA0–BA13) and video address. U51 switches the column address between the two CAS cycles.
- **CPU access to video RAM**: NCS1 → prioritiser **U02** pulls **/WAIT (Z80 pin 24) low** until a free slot comes. Read data is caught in **i8212 U76** and held on the data bus (DS1 = CS1, /DS0 = BNRD). Write data comes straight from the CPU bus.
- **Pixel path**:
  - Bitmap → U78/U82 (load/shift), with U83 adding a 2-SCLK delay.
  - Attribute → U77/U81.
  - U80 selects ink or paper. U85 selects border (from PC0–2) or picture under NBRD.
  - U86 7407 drives RGBI and sync. Gate U87/8 blanks during retrace.
  - U88/11 + T1 make the mono composite signal.
- **FLASH**: oscillator U88/6, U88/8 (C42 220 µF, R44, R43 4K7*), gated by attribute bit 7.
- **BRIGHT**: diode gate BD6N + R73. The diodes were missing on the original PCB and had to be added (REV0).
- Composite video comes out on **J1 pin 7 (VC)**, with GND on J1/2. J1/3–6 carry R, G, B, I. J1/8 is VS (positive sync), J1/9 VNS, J1/1 VVM (modulator supply).
- **INT**: NKBI = U17/11 = NAND(NLO6, VLD) → U72/1→2 → **Z80 /INT pin 16** (R69 4K7 pull-up). **Interrupts only occur in the BASIC configuration**, at 50 Hz.

---

## 10. CPU bus and test points

Sources: HWM p.40 Fig. A1.1; CET for verified pin nets. Measure all of these relative to GND (e.g. Z80 pin 29, 8255 pin 7).

### Z80A, U90 (DIP-40)

| Pin | Signal | Normal running state / what to look for |
|---|---|---|
| 6 | CLK | 3.5 MHz square wave from U74/6 (7407 + R70 330 Ω). Check amplitude and edges. |
| 26 | /RESET | Low at power-on, then high (R09 2K2, C15 10 µF, about 20 ms). Must stay high. |
| 27 | /M1 | Pulses about every 1–2 µs while running. Static means the CPU has stopped. |
| 19 | /MREQ | Pulsing (also the RAS for system DRAM, via U71/8) |
| 20 | /IORQ | Pulses only on IN/OUT (8255, CTC, FDC) |
| 21 | /RD | Pulsing |
| 22 | /WR | Pulsing (memory writes, OUTs) |
| 18 | /HALT | High. Low means a HALT executed (only goes to J8). |
| 24 | /WAIT | High, with short low pulses during CPU video-RAM accesses (U02/5). **Stuck low freezes the CPU.** |
| 16 | /INT | High in startup and CP/M. 50 Hz pulses in BASIC. From U72/2. |
| 17 | /NMI | High (R67 4K7 pull-up) |
| 25 | /BUSRQ | High (R68 4K7 pull-up) |
| 28 | /RFSH | Pulsing after each M1 |
| 11 / 29 | VCC / GND | +5 V / 0 V |
| 30–40, 1–5 | A0–A15 | Buffered onto the bus by U73 (A0–A4, A6), U74 (A7–A11), U72 (A5, A12, A13), U71 (A14, A15) |
| 14, 15, 12, 8, 7, 9, 10, 13 | D0–D7 | Data. 4K7 pull-ups R10–R17 per HWM p.40. |

Buffered bus test points (7407 outputs, pull-ups R45–R66):

| Signal | Test point |
|---|---|
| BNRD | U71/2 |
| BNIORQ | U71/4 |
| BA15 | U71/6 |
| BNMREQ | U71/8 |
| BNWR | U71/10 |
| BA14 | U71/12 |
| BA5, BA12, BA13 | U72/4, /6, /12 |
| BNM1 | U72/8 |
| BNRFSH | U72/10 |
| BA2, BA1, BA0, BA3, BA4, BA6 | U73/2, /4, /6, /8, /10, /12 |
| BA8, BA7, BA9, BA10, BA11 | U74/2, /4, /8, /10, /12 |
| CLK (to CPU) | U74/6 |

**A bus line with a dead pull-up or a dead 7407 gate sticks low.**

### 8255, U79

See §8 for the full pin list. Key test points:

| Pin | Signal |
|---|---|
| 35 | RESET (high only during power-on) |
| 6 | /CS |
| 5 | /RD |
| 36 | /WR |
| 8 | A1 (= BNRD) |
| 9 | A0 |
| 14–16 | Border bits |
| 11 | O6 |
| 10 | SO |

### EPROM enables

| Signal | Location | Behaviour |
|---|---|---|
| Boot /CE | U89 socket pin 20 (2716 chip pin 18) = NPO = U36/6 | Low throughout the startup configuration |
| Boot /OE | U89 socket pin 22 (2716 chip pin 20) = NOEB = U56/3 | Pulses low on reads of 0000–3FFF in startup |
| BASIC /CE | 2716 pin 18 = NPO | |
| BASIC /OE | 2716 pin 20 = U70 outputs; U70 enabled by NOES = U56/4 | |

### Other key nodes

| Node | Location |
|---|---|
| PO | U36/5 |
| NPO | U36/6 |
| LO6 | U36/9 |
| NLO6 | U36/8 |
| RFSH clock | U36/3 |
| BA7 | U36/2 |
| NPOR | C15+ / U36/4 |
| POR | U17/8 |
| NMR (reset button path) | U17/6 |
| NKBI | U17/11 |
| NS | U54/3 |
| NCS0 | U55/6 |
| CS1 | U55/11 |
| NCS1 | U55/8 |
| NCS2 | U56/7 |
| NCS3 | U56/9 |
| NWAIT | U02/5. U02/3 clock is "QD" in HWM Fig. A1.5 but "QC" in HWM text and CET (UNVERIFIED which). |
| XCLK | U57/2 |
| SCLK | U61/6 |
| CLK | U61/9 |
| VLD | U37/6 |

---

## 11. DRAM types, power rails, sequencing

Sources: HWM p.22–25, p.27, p.43, p.47, p.51; CONN; REV0; REV02. Pinouts are the standard JEDEC 4116/4164 pinouts, and they agree with HWM p.43/47.

| Pin | 4116 (16K×1, original) | 4164 (64K×1) |
|---|---|---|
| 1 | **VBB −5 V** | NC |
| 8 | **VDD +12 V** | **VCC +5 V** |
| 9 | **VCC +5 V** | **A7** |
| 16 | GND | GND |
| 4 / 15 / 3 | /RAS / /CAS / /WE | same |
| 2 / 14 | DIN / DOUT | same |

- **The original board is wired for 4116, which needs all three supplies.** **A 4164 in an unmodified 4116 position gets +12 V on its VCC pin (pin 8) and will be destroyed.** Before fitting any DRAM, measure pins 8, 9 and 1 of each bank's sockets with no chips installed.
- Soviet equivalents named in the sources: К565РУ5 = 4164 (64K×1), К565РУ6 = 16K×1 single +5 V with pin 9 NC (CONN). К565РУ3 is generally the 4116 equivalent (UNVERIFIED, not stated in the sources). Romanian MMN4116 / MMN4164-3 (Microelectronica) also appear (CET, REV02).
- **Supplies (HWM p.22, j9)**: **+5 V 3 A**, **−5 V 50 mA**, **+12 V 0.3 A**.
  - J9 pinout: **1 = +12 V, 2 = GND, 3 = +5 V, 4 = −5 V, 5 = GND**.
  - +5 V tolerance is ±0.25 V; the original PSU had a crowbar at about 6 V.
  - **With 4116 fitted, −5 V must come up first.** The original PSU held +5 and +12 off until −5 was present.
  - **Never plug or unplug J9 with power on.** This can destroy the 4116s (HWM p.25–26).
- With an all-4164 board, +12 V only goes to J8 (expansion). −5 V is still used by U92 (741 tape input, pin 4) and the RS-232 TxD stage (R84/T2). The board should boot without them, but tape and RS-232 won't work (inference, UNVERIFIED).
- Video output stage supply VVS comes from VCC through P4 1N4148 and C44 100 µF (HWM p.49).

---

## 12. Boot ROM sequence (for interpreting a hang)

Sources: ASM64, ASM80, BOOT, `docs/history.md`. The owner's РФ5 is a variant of the 80K boot.

80K standard boot (`BOOT_2K_COBRA_80K`):

| Addr | What it does | Hardware exercised |
|---|---|---|
| 0000 | `LD A,83h; LD R,A` (owner's chip: `LD D,83h`, which relies on A = FFh after reset) | R7 = 1 holds the startup map |
| 0004 | `LD SP,FD73h` | Stack in ½ bank #0 (E000–FFFF window), not used yet |
| 0007 | `LDIR` 00h over C000–DAFF | Video bank #1, /WAIT prioritiser, U03/U20/U22/U39. **Result: blank black screen.** |
| 0014 | `LDIR` 0000–07FF → 8000 | **First write to bank #0** (CAS0 / the 64K bank) |
| 001F | `OUT` 03h → E3h, EBh, F3h, FBh; `OUT (FDh),0` | CTC/FDC (harmless with no FDC board) |
| 002C | `OUT (DFh),92h` ×2; `OUT (FEh),40h` | 8255 init, border black, O6 = 1 |
| 0056 | `IN A,(FEh)` (CTRL test) | Keyboard |
| 0091 | Logo: attributes D900…, **first `PUSH BC` at 0096** (stack FD71) | **First stack use, which needs working bank #0** |

The 64K boot does the same, except it sets `SP=FFFFh`, clears the screen, programs the 8255, and pushes first at 002C.

**Implication (inference):** a clean blank screen followed by no logo is consistent with:
- a CPU that runs the clear but then fails on bank #0 RAM (stack, or the 8000 copy);
- a hang on the 8255 programming;
- a CPU stuck in /WAIT.

It is also consistent with a video path that displays all-zero data whatever the RAM holds. Discriminate with a scope or logic probe on /M1, /WAIT, the 8255 /WR (pin 36) and NCS0 (U55/6). The border colour after the hang is a cheap first clue (`docs/history.md` table).

**Inference (UNVERIFIED):** if the fitted Z80 clone does *not* power up with A bit 7 = 1, the owner's `LD D,83h` variant leaves R7 = 0. U36 is preset only while NPOR is low (≈ the first 10–20 ms). After that the boot EPROM would disappear from the map in the middle of the screen clear.

---

## 13. Known failure modes and repair notes

### Original PCB layout bugs (rev.3)

Source: CONN, REV0, HWM notes p.40–53. A board that ever worked should carry these fixes. On a non-working board, check each one.

| Bug | Fix | Severity |
|---|---|---|
| U36/1 tied to U36/5 (PO) | Should go to LO6 (U36/9) | **Critical, startup** |
| U85/12 (I) fed through gate U87/11–13 to U86/11 | Cut so I goes straight to U86/11. U87/11 must drive RS-232 instead. | **Critical, video/RS-232** |
| U83 pins 6/7 not connected to GND (7495 mode/GND) | Add the connection | **Critical, video** |
| BA7 instead of BA1 at JEXA/8 | Rewire to BA1 | **Critical, floppy** |
| NVS (U34/8) missing to JEXA/9 | Add the connection | **Critical, floppy** |
| SO wired straight to R87; R107 to GND instead of VCC; joystick common on J6/10 instead of J6/8; U85/13 to U80/3, U81/11 | Per CONN | Medium |
| BRIGHT diodes missing | Holes added and diodes fitted | |

### Timing-sensitive parts

Sources: REV02, LDT.

- **Video address muxes U03/U20/U22/U39 must be 74ALS153.** With 74LS153, the image was corrupt from the startup screen onward.
- U41/U58 (system DRAM muxes): use **74S157 with 200 ns DRAM** and 74LS157 with faster parts. **120 ns DRAMs never worked reliably** in system banks; 200 ns parts are recommended.
- DRAM must hold DOUT valid while CAS stays low.
- **150 pF from DRAM pin 4 (RAS) to GND** on banks 0/2/3 was needed with MMN4164-3. TMS4164-20 parts needed no capacitor, but did need the 8-bit refresh circuit. **TI TMS4164 needs 256-cycle (8-bit) refresh**; the Z80 provides only 7-bit, which gives corruption after 10–20 s of idle. Fix with the "Refresh DRAM pe 8 biti" circuit (`schematics/Refresh_DRAM_pe_8_biti_sch3.16a_mod0.4.pdf`).
- **CCC = 560 pF** (originally 390 pF*) and **C49 = 330 pF** (80K mod) were the delay capacitors that really mattered.
- **150 pF on U36/3** fixes the "D key → blue flash → freeze" fault.
- The LDT build needed trial-and-error tuning of **five delay capacitors** before BASIC loaded. Switching 64K→80K mode by jumper changed the memory timing, so the tuning had to be redone.
- **Diode AND gate in the 80K mod (D19–D21)** fails to work and is replaced with a **7411** gate (REV02, LDT). The symptom was that part of the upper address space was unusable.

### Other faults

- **Hot chips:**
  - LDT found an IC in the video circuit running hot. Logo letters filled in gradually as the board warmed up, and replacing the chip cured it.
  - Months later another warm chip was found. After it was replaced, the video became sharp.
  - Use touch or thermal inspection of the video TTL (U77–U88, U03–U39 area) when the picture changes with time.
- **Sync noise/rolling** (REV02): long NHB, NVS and HS tracks run through the DRAM block. Terminate them: resistor to VCC on NHB (U87/9) and NVS (U87/10), resistor to GND on HS (U88/13). About 750 Ω was used on the PAL-coder side.
- **Jumper mistakes** cost LDT an evening twice (BASIC not starting, then CP/M not loading). On jumpered boards, re-read the jumper table before debugging.
- **3.5" drives** must supply a Shugart-style READY. LDT added a READY switch per drive (fdd pages).

---

## 14. Connectors (selected)

Source: HWM p.35–38.

- **J9 power**: 1 +12 V, 2 GND, 3 +5 V, 4 −5 V, 5 GND.
- **J1 video**: 1 VVM, 2 GND, 3 R, 4 G, 5 B, 6 I, 7 composite (mono), 8 +sync, 9 −sync.
- **J7 keyboard (2×10)**:
  - a-row: 2 VCC, 3 DIF (speaker), 4 KA8, 5 KA10, 6 KA12, 7 KA14, 8 K4, 9 K2, 10 K0.
  - b-row: 2 VCC, 3 GND, 4 KA9, 5 KA11, 6 KA13, 7 KA15, 8 K3, 9 K1, 10 K5.
- **J4 tape**: 1,4 out; 2 GND; 3,5 in.
- **J2 RS-232**: 2 TxD, 3 RxD, 7 GND.
- **J8 expansion (DIN 3×32)**: full bus including NWAIT, NRST, NINT, NHALT, BCLK, and VDD/VBB/VCC.
- **jEX FDC (2×15)**: VCC, D0–D7, BA1–BA4, NIORD, NIOWR, BNIORQ, BNRD, BNM1, NINT, IEI/IEO, NRST, POR, BCLK, SI/TRG3.

## What the sources don't cover

- No service/test manual from the factory (ITCI) was found, only the hardware description manual.
- The English manual omits pages 64–70. Scans exist in SCAN, but there is no translation.
- No original documentation of the 64K or 80K modifications exists beyond hand-drawn period notes (DOCS) and cobrasov's reconstruction.
