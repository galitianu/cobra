# Equipment and how we use it

## Owner's kit

| Item | Details | Role |
|---|---|---|
| CoBra mainboard | revision, 64K or 80K, and floppy fitted: **unknown** | the patient |
| Home-made PSU | built a few years ago by the owner from an old **Baby AT PC power supply**, wired to a DIN plug for the CoBra power connector. Worked back then. AT PSUs give +5, +12, −5 and −12 V. The plug wiring needs checking against J9 | power |
| Multimeter | owner's | static voltages, continuity, resistance |
| Cheap Chinese LCD with composite input | fed from CoBra J1 pin 7 (composite), J1 pin 2 GND | display. **Later: a USB capture card**, so the agent can see the screen too |
| Rigol DS1054Z | upgraded, reports **DS1104Z** (100 MHz), FW 00.04.05.SP2, USB to the Mac | main measuring tool, 4 analog channels |
| XGecu T48 | FW 00.1.03, driven by `minipro` 0.7.4 | read/program/verify ROMs |
| К573РФ5 | original boot EPROM, 80K boot variant, healthy | keep as the known reference, **do not erase yet** |
| 4× AT28C16 | 2K EEPROM, 2716 pinout, 5 V programmable | experiment ROMs (diagnostics, copies) |
| Raspberry Pi Pico | RP2040, **3.3 V GPIO** | logic analyser / signal source later |
| Raspberry Pi 2B | **3.3 V GPIO** | optional Linux helper |
| Breadboards, jumper wires | | |

The owner says they have **little electrical-engineering experience**. Every instruction must say exactly which chip and pin to touch, where the ground clip goes, and what reading to expect. Ask for a photo whenever we're unsure about something physical.

## Rigol scope

- Connected over **USB**. Controlled through the `rigol` MCP server (configured in [.mcp.json](../.mcp.json), code in `tools/rigol-mcp`, `send_raw` enabled) or through the CLI fallback:

  ```sh
  uv run --project tools/rigol-mcp python tools/rigol/scope.py idn
  uv run --project tools/rigol-mcp python tools/rigol/scope.py shot <name>          # PNG into captures/scope/screenshots/
  uv run --project tools/rigol-mcp python tools/rigol/scope.py scpi ":TIM:SCAL 1e-6" ":MEAS:ITEM? FREQ,CHAN1"
  uv run --project tools/rigol-mcp python tools/rigol/scope.py state
  ```

- Only one client can hold the USB connection at a time. If the MCP server has it, the CLI fails, and the other way round.
- There are no digital channels. Four analog channels are enough for strobes (/M1, /MREQ, /RD, /IORQ…), clocks, sync and rails, but not for a whole 8- or 16-bit bus at once. The Pico fills that gap (see below).
- Probe practice for the owner: set the probe and the channel to **×10**, clip the ground to a board **GND** (a 7805 tab or a 74xx pin 7 is fine, never a supply rail), and touch the tip to the pin. Use the shortest ground lead you have for clock edges.

## T48 programmer (minipro)

See [procedures/programming.md](procedures/programming.md) for exact commands.

## Raspberry Pi Pico: planned uses

- **Logic analyser** with 24 channels at up to 100 MS/s, using gusmanb's open-source *LogicAnalyzer* firmware and desktop app (https://github.com/gusmanb/logicanalyzer). Use it to capture the address/data bus and many strobes at once, for example to watch exactly which address the CPU goes astray at.
- **⚠ The RP2040 is NOT 5 V tolerant.** The CoBra is a 5 V TTL/NMOS board. Connecting a Pico pin directly to a CoBra signal can destroy the Pico. Level shifting is needed. The easiest DIP option is **CD74HC4050** hex buffers powered from the Pico's 3.3 V: inputs tolerate 5 V, 6 channels each, so 4 chips give 24 channels. Avoid TXS0108E auto-direction modules for this job.
- Pico **outputs** (3.3 V) can drive 5 V TTL inputs directly (V<sub>IH</sub> = 2.0 V). Later uses: keyboard-matrix emulation, generating tape-loading audio.

## Raspberry Pi 2B: planned uses

Optional. It can be a remote host for the scope and Pico, play `.tap` audio into the EAR input once the machine boots, or run sigrok/PulseView. It has the same 3.3 V GPIO restriction as the Pico.

## Shopping list (only when needed)

- 3–4× **CD74HC4050** (DIP-16) for the Pico logic analyser front end.
- A **USB composite capture card** (any cheap UVC "EasyCap-style" or HDMI capture with a composite converter), so the agent can see the screen.
- A **UV EPROM eraser**, only if we ever want to rewrite the РФ5.
- 0.1 µF ceramic capacitors and a 4164 or two as spares, once we know the DRAM type.
