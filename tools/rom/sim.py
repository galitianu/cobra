"""Run a ROM image in a Z80 emulator and report what it does, before burning it.

    uv run python rom/sim.py ../rom/custom/diag01_border.bin [--seconds 5] [--mhz 3.5]

Reports every OUT (port, value, time), every IN, any write to memory (RAM use),
and whether execution ever left the ROM's address range. The ROM is mapped at
0000h; reads elsewhere return 00h unless --ram is given (then it is plain RAM).
"""
import argparse
from pathlib import Path

import z80

p = argparse.ArgumentParser()
p.add_argument("rom")
p.add_argument("--seconds", type=float, default=3.0)
p.add_argument("--mhz", type=float, default=3.5)
p.add_argument("--in-value", type=lambda s: int(s, 0), default=0xFF, help="value returned by IN (default FFh: no key pressed)")
p.add_argument("--max-events", type=int, default=40)
args = p.parse_args()

rom = Path(args.rom).read_bytes()
m = z80.Z80Machine()
m.set_memory_block(0, rom)
hz = args.mhz * 1e6
t_total = 0
events = []
pcs_outside = set()


def log(kind, text):
    if len(events) < args.max_events:
        events.append(f"{t_total / hz * 1000:10.3f} ms  {kind:5} {text}")


def on_out(port, value):
    log("OUT", f"port {port & 0xFF:02X}h (full {port:04X}h) <- {value:02X}h")


def on_in(port):
    log("IN", f"port {port & 0xFF:02X}h (full {port:04X}h) -> {args.in_value:02X}h")
    return args.in_value


m.set_output_callback(on_out)
m.set_input_callback(on_in)

# The emulator has a flat 64 KB RAM. Detect writes by snapshotting the non-ROM area.
before = bytes(m.memory[len(rom):])
slice_ticks = 1000
budget = int(args.seconds * hz)
while t_total < budget:
    m.ticks_to_stop = slice_ticks
    m.run()
    t_total += slice_ticks
    if m.pc >= len(rom):
        pcs_outside.add(m.pc)
    if m.halted:
        log("HALT", f"at PC={m.pc:04X}h")
        break

after = bytes(m.memory[len(rom):])
writes = [i + len(rom) for i, (a, b) in enumerate(zip(before, after)) if a != b]
rom_changed = bytes(m.memory[: len(rom)]) != rom

print(f"ran {t_total / hz:.2f} s emulated at {args.mhz} MHz, final PC={m.pc:04X}h")
print("\n".join(events) or "(no I/O)")
print(f"memory writes outside ROM: {len(writes)}" + (f", first at {writes[0]:04X}h" if writes else ""))
print(f"ROM area modified by code: {rom_changed}")
print(f"PC sampled outside ROM: {sorted(pcs_outside)[:10] if pcs_outside else 'never'}")
