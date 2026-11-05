# This board: inventory and observations

From the owner's photos on 2026-11-05 (`photos/20261105_*.jpg`). Positions are mapped to the original placement drawing (`references/cobrasov/original_manual_scans/pag70.jpg`).

**Photo orientation:** `20261105_board_top.jpg` is the placement drawing rotated 90° clockwise. The drawing's top edge (J3/J4, J8, J9) is the photo's right edge. Its left edge (U85…, the DRAM bank ends) is the photo's top edge. This mapping was checked against the Z80 and 8255 notches.

## Identity

- PCB marking **"921442431 Rev A"** along the edge. This is the original ITCI Brașov mainboard, the layout described in the hardware manual.
- Floppy interface: not present (bare mainboard).

## Main chips

| Ref | Fitted | Notes |
|---|---|---|
| U90 CPU | **MMN 80CPU** (Microelectronica, Romanian Z80 clone), date code 820 | Its register values after reset are unknown, so hypothesis 1 stays open |
| U79 PPI | **КР580ВВ55А** (Soviet 8255), 9002 | |
| U89 boot | **К573РФ5** labelled "Boot" (9003) in a 28-pin socket | **⚠ Orientation suspect, see below** |
| BASIC U91…U01 | **8× MMN 2616** (Romanian 2K×8 ROM/EPROM), date codes 767 / 887 / 890 / 892, with hand-written numbers on top | The original 8-chip, 16 KB BASIC set. Read and verify on the T48 later. |
| Bank #1 (video), U04–U11 | **8× КР565РУ6** (16K×1, **single +5 V**), 9003 | Leftmost DRAM column in the board photo |
| Bank #0, U24–U31 | empty | |
| Bank #3, U43–U50 | **8× MMN 4164-2** (64K×1, single +5 V) | The "64K mod" bank sits here, not in bank 0 |
| Bank #2, U62–U69 | empty | |
| TTL | Romanian CDB series (CDB 400E, 403E, 404E, 408E, 410E, 4153E/EN, 4157E, 4193E, 474E, 486E, 495E…), Soviet/Romanian 7417, one National **DM7407N** (P8552) | 7417s fitted where the manual says 7407 (U71–U74 area). Equivalent in practice (open collector, 15 V). |
| 741 | **βA741N** | Tape-input comparator U92 |

## What this means

- **This is a 64K/80K-modified board with single-supply DRAM:** 8× 4164 plus 8× РУ6, 16 chips. **The DRAM doesn't use −5 V or +12 V.** That makes the PSU's −5 V reading of −7.03 V much less critical. On this board −5 V only feeds the 741 tape comparator and the RS-232 TxD stage (hardware.md §11), and +12 V only goes to J8. Still to confirm on the powered board: DRAM pin 8 = +5 V, pin 1 not at −5 V.
- **Mod hardware present:**
  - A **piggyback daughterboard** with a CDB 400E (7400), a CDB 403E (7403, open-collector NAND), 1N4148 diodes and resistors, wired with yellow wires. This is most likely the 64K/80K mod logic (CAS gating / CS1 regeneration).
  - Several yellow bodge wires on the top and white bodge wires on the solder side, probably the CONN layout fixes and the mod rewires.
  - Whether it is configured as 64K or 80K is unknown. Trace the daughterboard later.
- **A bundle of loose yellow wires** is soldered near J3/J4 (green sleeves, free ends). Purpose unknown: possibly an old keyboard or tape harness. **The free ends must be insulated or confirmed dead before any power-up.**
- The solder side has brown flux residue but no obvious corrosion or burnt areas. Clean with isopropyl alcohol later; it isn't urgent.

## ⚠ Boot ROM orientation

- The placement drawing marks U89's pin-1 corner at the end **towards SB / J8**. That is the right end in `board_top`, and the end with the **empty socket positions** in `boot_rom_8255_basic_roms`.
- A 2716 in this 28-pin socket must sit at the end away from pin 1, which it does. **But its pin 1 must also face the socket's pin-1 end.**
- The РФ5's printed triangle and bar marks are at the **opposite** end, away from the empty positions.
- If those marks are pin 1, the chip is **in backwards**. A reversed 2716 has VCC and GND on the wrong pins, so the CPU could never have run the boot code. That alone would explain a screen showing only whatever the video circuit reads from uninitialised RAM.
- **Status: UNVERIFIED.** The pin-1 marking convention on this Soviet ceramic package hasn't been confirmed. Don't power the board with this chip fitted until it is resolved. The AT28C16 test ROMs (clear notch) make the question moot for testing.

## Power connectors

- **J9 (power)** is the single 5-pin DIN in the corner by the CPU, next to the microswitch "COD 5979" (K1, the RESET button). See `cpu_J9_reset.jpg` and `edge_J9_J8.jpg`. This matches the drawing: J9 at the corner beside K1 and J8.
- **J3 and J4** are the pair of DIN sockets on the opposite end of the same edge (`edge_J3_J4_loose_wires.jpg`). They are audio and tape. **Never plug the PSU into these.**
