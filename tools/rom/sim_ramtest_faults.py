"""Run diag03_ramtest in the emulator with injected RAM faults and decode its border report.

    uv run python rom/sim_ramtest_faults.py
"""
import z80

ROM = open("../rom/custom/diag03_ramtest.bin", "rb").read()
HZ = 3.5e6


def run(desc, fault, seconds=45):
    m = z80.Z80Machine()
    m.set_memory_block(0, ROM)
    mem = bytearray(65536)
    mem[: len(ROM)] = ROM
    m.mark_addrs(0x8000, 0x8000, z80.Z80Machine.READ_MARK | z80.Z80Machine.WRITE_MARK)
    m.set_read_callback(lambda a: fault(a, mem[a]))
    m.set_write_callback(lambda a, v: mem.__setitem__(a, v))
    st = {"t": 0}
    ev = []
    m.set_output_callback(lambda p, v: ev.append((st["t"] / HZ, v & 7)) if p & 0xFF == 0xFE else None)
    m.set_input_callback(lambda p: 0xFF)
    while st["t"] < HZ * seconds:
        m.ticks_to_stop = 2000
        m.run()
        st["t"] += 2000
    seq = [("W" if c == 7 else "B", tn - ts) for (ts, c), (tn, _) in zip(ev, ev[1:] + [(st["t"] / HZ, None)])]
    starts = [k for k, (c, d) in enumerate(seq) if c == "B" and d > 4]
    if not starts:
        print(f"{desc}: no failure report (test passing)")
        return
    s = seq[starts[0] + 1:]
    region = 0
    while s[0][0] == "W" and s[0][1] < 0.5:
        region += 1
        s = s[2:] if s[1][1] < 1 else s[1:]  # last flash: keep the long black gap
    while s[0][0] == "B":
        s = s[1:]
    bits = "".join("1" if d > 0.8 else "0" for c, d in s if c == "W")[:16]
    print(f"{desc}: region {region}, bad bits {int(bits[:8], 2):02X}h, address {int(bits[8:], 2):02X}xxh")


run("no fault", lambda a, v: v, seconds=12)
run("video RAM bit 3 stuck at 1", lambda a, v: v | 0x08 if 0xC000 <= a < 0xDB00 else v)
run("RAM0 bit 6 stuck at 0 above 9000h", lambda a, v: v & ~0x40 if 0x9000 <= a < 0xC000 else v)
