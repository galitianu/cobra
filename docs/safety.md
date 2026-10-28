# Safety rules (for the owner and for the agent)

## Power: the board's most dangerous point

The original CoBra uses **4116 DRAMs, which need three supplies**: +5 V, +12 V and −5 V. Some boards were modified for 4164 DRAMs, which need only +5 V. Which kind this board has is **unknown until Phase 0 is done**. See [hardware.md §11](hardware.md).

- **J9 power connector:** pin 1 = +12 V, 2 = GND, 3 = +5 V, 4 = −5 V, 5 = GND.
- Rated loads: +5 V 3 A, +12 V 0.3 A, −5 V 50 mA. +5 V must be within ±0.25 V.
- **With 4116s fitted, −5 V must be present before or with +12 V and +5 V**, and must not disappear while they are up. 4116s without −5 V are destroyed.
- **Never plug or unplug J9 while the PSU is on.**
- **A 4164 in a socket wired for 4116 gets +12 V on its supply pin (pin 8) and is destroyed.** Never fit or swap a DRAM until we have measured that socket's pins 8, 9 and 1.

## General rules

1. **Power off before** inserting or removing chips, moving jumpers, or attaching wires. Probing a powered board with the scope is fine.
2. **Check the PSU before connecting it to the board.** Measure each rail with no load, then check every pin of the plug against the J9 pinout above.
3. **Watch the first power-up after any change.** Keep a hand near the switch and touch chips briefly with a fingertip. A chip too hot to hold for 2 seconds means power off and report.
4. **Scope ground clip only on GND.** The scope ground is mains earth through its power cord. Clipping it onto +5 V or another rail shorts that rail through the scope. Make sure the PSU output isn't earth-referenced in a way that conflicts with this.
5. **Never connect a Pico or Raspberry Pi pin directly to a CoBra signal.** They are 3.3 V devices and CoBra signals are 5 V. Use the CD74HC4050 front end described in [equipment.md](equipment.md).
6. **Never drive the CoBra buses from outside while the Z80 is running.** That's bus contention, which damages chips.
7. **Chip orientation:** the notch / pin-1 dot must match the socket's notch and the silkscreen. A reversed chip at power-up is usually destroyed, and can take the rail down with it.
8. **ESD:** touch a grounded metal object before handling MOS chips (Z80, 8255, DRAMs, EPROMs). Store them on conductive foam or in their tubes.
9. **Don't use the RESET button while in the boot/logo configuration.** It clears the R register, so the board drops into a random memory map. Restart by **power-cycling** (with 4116s, through the PSU switch, not by pulling J9).
10. **Before first use, the agent must ask** about the PSU's rails and current limit, since we didn't build it and don't know its design.
