# CoBra repair

Restoring a **CoBra** (Brașov, Romania) Z80 / ZX Spectrum-compatible mainboard to working order.

**Symptom:** the board powers up from a home-made PSU, the screen initialises to blank characters, and nothing else happens.

**Before touching power, read [docs/safety.md](docs/safety.md).** The original board uses 4116 DRAMs, which need +12 V and −5 V.

**Current status:** see [docs/plan.md](docs/plan.md#status). Daily notes are in [journal/](journal/).

## Quick links

- [Agent guide / project layout](CLAUDE.md)
- [Repair plan](docs/plan.md)
- [Hardware reference](docs/hardware.md)
- [What we learned before](docs/history.md)
- [Equipment](docs/equipment.md) · [Safety](docs/safety.md) · [ROM programming](docs/procedures/programming.md)
- Original boot ROM dump: [rom/dumps/K573RF5_boot80k_original.bin](rom/dumps/K573RF5_boot80k_original.bin) ([gist](https://gist.github.com/galitianu/32a524e600a784fa2823dbd38377ee99))
- Main source: [cobrasov.com](https://cobrasov.com)

## Diagnostic ROMs

| Image | Needs RAM? | What you should see |
|---|---|---|
| `rom/custom/boot80k_rf5_fix0.bin` | yes | the original boot ROM with `LD A,83h` at 0000h. Should show the logo if hypothesis 1 is right |
| `rom/custom/diag01_border.bin` | no | border cycles black→blue→red→magenta→green→cyan→yellow→white, ~1 s each |
| `rom/custom/diag02_nop.bin` | no | nothing visible; address lines A7–A10 show square waves on the scope |

## Using this repo

```sh
git clone --recursive https://github.com/galitianu/cobra-repair
cd cobra-repair
git config core.hooksPath .githooks     # blocks photos with GPS metadata
rom/reference/fetch.sh                  # official CoBra ROMs (not redistributed here)
references/fetch.sh                     # core documentation (not redistributed here)
(cd tools && uv sync) && (cd tools/rigol-mcp && uv sync)
```

You also need `minipro` (XGecu T48), `sjasmplus` (Z80 assembler) and `uv`. The repair is driven by Claude Code with the Rigol MCP server in [.mcp.json](.mcp.json). [CLAUDE.md](CLAUDE.md) is its working guide.

## License

Code: MIT. Documentation, journal, photos and captures: CC BY 4.0. Third-party references are not included; see [LICENSE](LICENSE).
