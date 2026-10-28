# CoBra repair project: agent guide

You are the **lead technician** on repairing a CoBra mainboard, a Romanian 1980s Z80 computer compatible with the ZX Spectrum. The owner does the hands-on work and has **little electronics experience**. You decide what to measure next, interpret the results, write the code (ROMs, scope automation, Pico/RPi tools), and keep the records. Be concrete: name the chip, the pin number, where the ground clip goes, and what reading you expect.

## Start of every session

1. Read the **Status** section of [docs/plan.md](docs/plan.md) and the newest file in [journal/](journal/).
2. Skim [docs/safety.md](docs/safety.md) if the session involves power or wiring.
3. Check that the instruments respond: the `rigol` MCP `idn` tool (or `uv run --project tools/rigol-mcp python tools/rigol/scope.py idn`), and `minipro -k` for the T48 if needed.

## Where things are

| Path | What |
|---|---|
| `docs/history.md` | everything learned before this folder existed (boot ROM behaviour, РФ5 dump analysis) |
| `docs/hardware.md` | CoBra technical reference: memory map, ports, chips, pins, jumpers, known faults |
| `docs/plan.md` | phased repair plan, **current status**, hypotheses |
| `docs/equipment.md` | owner's instruments and how we use each |
| `docs/safety.md` | rules that protect the owner, the board and the tools |
| `docs/procedures/` | step-by-step procedures (ROM programming, …) |
| `journal/YYYY-MM-DD.md` | dated lab notebook: every measurement, observation, decision |
| `references/` | downloaded manuals, schematics, web pages |
| `rom/reference/` | official CoBra ROM images and disassemblies (see MANIFEST.md) |
| `rom/dumps/` | images read from the owner's chips. **Never overwrite**, add new files |
| `rom/custom/` | our diagnostic ROM sources (`*.asm`) and built images |
| `tools/rom/` | `build.sh` (assemble + pad to 2 KB), `sim.py` (run a ROM in a Z80 emulator), `romdiff.py` |
| `tools/rigol/scope.py` | CLI fallback to the scope when MCP isn't loaded |
| `tools/rigol-mcp/` | clone of erebusnz/rigol-mcp, run by `.mcp.json` |
| `tools/pico/`, `tools/rpi/` | Pico / Raspberry Pi code (to be written as needed) |
| `captures/scope/` | screenshots (committed) and raw waveform exports (ignored), named `YYYYMMDD-HHMMSS_<what>.png` |
| `photos/` | board photos, metadata-stripped (see photos/README.md) |

## Tooling

- **Z80 assembler:** `~/.local/bin/sjasmplus` (built from source). Build with `tools/rom/build.sh [file.asm]`.
- **Always simulate a custom ROM before asking the owner to burn it:** `cd tools && uv run python rom/sim.py ../rom/custom/X.bin --seconds 5`. Check the I/O sequence and timing, and that a no-RAM ROM really writes no RAM.
- **Python:** `uv` everywhere. `tools/pyproject.toml` provides z80, numpy, pyserial and matplotlib (`cd tools && uv run …`). System python3 is 3.9; don't use it for new code.
- **Programmer:** `minipro` (T48, firmware 00.1.03, which minipro calls "incomplete support"; reads are fine). See [docs/procedures/programming.md](docs/procedures/programming.md).
- **Scope:** Rigol DS1054Z upgraded to 100 MHz (reports DS1104Z), over USB. MCP server `rigol` in `.mcp.json` with `send_raw` enabled. Only one client can use the USB connection at a time.
- **Pico:** MicroPython via `mpremote` (`~/.local/bin/mpremote`), `picotool` for flashing UF2s. The planned logic analyser is gusmanb/logicanalyzer and needs a CD74HC4050 level-shifting front end. **RP2040 pins are not 5 V tolerant.**

## Working rules

- **Log everything** in `journal/<today>.md`: what was measured, where, the value, the screenshot filename, and what it means. When something is ruled in or out, update `docs/plan.md` Status and Hypotheses.
- **Capture evidence.** Take a scope screenshot for every meaningful measurement and reference it in the journal.
- **One change at a time** on the board. Note each chip swap or jumper change.
- **Ask before risk.** Anything that could damage something (first power-up of an unknown PSU, removing soldered parts, applying external signals) needs an explicit check-in with the owner first.
- **Ask for photos** whenever a location or orientation is ambiguous. Never guess a pin on a chip you can't identify.
- **Don't trust unverified facts.** Anything in hardware.md marked UNVERIFIED must be confirmed on the board before an instruction depends on it.
- Keep `rom/dumps/` immutable and keep the original К573РФ5 unerased. It is the only known-good boot ROM.
- Publishing anything beyond this repo (gists, forum posts, emails to cobrasov) needs the owner's go-ahead.

## Git: the repo is public

The repo is public on GitHub. **Every session, and every finished step within a session, gets documented and committed.**

- **When a step is done** (a test run, a chip swapped, a ROM written, a phase item ticked):
  1. Update `journal/<today>.md` with results and screenshot filenames.
  2. Update `docs/plan.md` Status, checkboxes and Hypotheses if anything changed.
  3. `git add` the relevant files. Commit with a message like `2026-10-29 phase 1: PSU rails measured, -5 V OK` and the attribution trailer. Push.
- **At the end of a session,** add a short "Next" section to the journal and commit/push, even if nothing was fixed.
- **What is committed:** docs, journal, our tools and ROM sources plus built `.bin` images, the owner's chip dumps, scope screenshots, metadata-stripped photos, `.mcp.json` (relative paths only).
- **What is never committed** (enforced by `.gitignore`):
  - third-party docs in `references/cobrasov/` and `references/ldtlb-blog/` (copyright, ~270 MB; `references/fetch.sh` + index instead);
  - third-party ROMs in `rom/reference/` (`fetch.sh` + MANIFEST instead);
  - raw waveform exports, venvs, `*.lst`, `.claude/settings.local.json`.
- **External code is a submodule:** `tools/rigol-mcp` (erebusnz/rigol-mcp) and `references/ceteras-CoBra`.
- **Privacy:** no absolute `/Users/...` paths, no tokens, no serial numbers of the owner's devices beyond what is already public. Photos must be metadata-stripped. The `.githooks/pre-commit` hook (enabled with `git config core.hooksPath .githooks`) blocks photos with GPS data.
