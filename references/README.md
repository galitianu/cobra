# References

Third-party documentation used for this repair. **Only this index, `fetch.sh` and the `ceteras-CoBra` submodule are committed.** The rest (~270 MB) is copyrighted material from the sites below. It stays out of the public repo and is kept locally under the same paths, so citations like `references/cobrasov/...` in [docs/hardware.md](../docs/hardware.md) resolve on the owner's machine.

| Path | Source | In git? |
|---|---|---|
| `ceteras-CoBra/` | https://github.com/ceteras/CoBra: KiCad re-creation of the original mainboard with the original U-numbers (MIT) | yes, as a submodule |
| `cobrasov/` | https://cobrasov.com, "CoBra Project" section: manuals, schematics, PCB layouts, mods, period documents, page snapshots | no |
| `ldtlb-blog/` | https://blog.ldtlb.com/2022/09/27/cobra-about.html and the gallery post | no |

To rebuild the local copy, run `references/fetch.sh` for the main documents. The site's own download pages cover everything else; the filenames below were shortened from the originals.

## Local inventory (`cobrasov/`)

**(top level)**
- CoBra_Basic_Manual.pdf
- CoBra_CPM_Manual_v1.0.pdf
- CoBra_Hardware_Manual_rev.1.0.pdf
- boot.html
- rev0.2.html

**schematics**
- Codor-PAL_PROM_PCB-VERDE.pdf
- FDC_Scheme_interfata_floppy_disk_v0_original.pdf
- FDC_Scheme_interfata_floppy_disk_v1.0.pdf
- FDC_Scheme_interfata_floppy_disk_v1.1.pdf
- FDC_Scheme_interfata_floppy_disk_v1.2.pdf
- Jumper_settings_main_board_v0.2-ro.pdf
- Jumper_settings_main_board_v0.2.pdf
- Keyboard_Schema_tastaturii_CoBra_v0_original.pdf
- Keyboard_Schema_tastaturii_CoBra_v1.0.pdf
- PAL_coder_Schema_codor_PAL_rev0.5.pdf
- Refresh_DRAM_pe_8_biti_sch3.16a_mod0.4.pdf
- Scheme_microcalculator_CoBra_v0.2_sch3.16a_mod0.4.pdf
- Scheme_microcalculator_CoBra_v0.2_sch3.17e_mod0.4a.pdf
- Scheme_microcalculator_CoBra_v0_original.pdf
- Scheme_microcalculator_CoBra_v1.2_64K_rom_bugfix.pdf
- Scheme_microcalculator_CoBra_v1.3_80K.pdf
- main_board_add-ons_Modificari.pdf

**pcb**
- fdc_board_rev.2.42.pdf
- fdd_board-2.0_original.pdf
- main_board_Add-on1.pdf
- main_board_Add-on2.pdf
- main_board_rev.3.0_original.pdf
- main_board_rev.3.16a.pdf
- main_board_rev.3.16a_gerber.zip
- main_board_rev.3.17e.pdf
- main_board_rev.3.17e_gerber.zip
- main_board_v4.27_v1.2.pdf
- main_board_v4.34_v1.3_80K.pdf
- modif_board_rev.0.4.pdf
- modif_board_rev.0.4_gerber.zip
- modif_board_rev.0.4a.pdf
- modif_board_rev.0.4a_gerber.zip

**mods**
- Mainboard_Modifications_Connection_changes.pdf
- Modificari_conexiuni_placa_de_baza-ro.pdf

**docs**
- Forum_2828_Interfata_FDD_cobra.pdf
- ITCBrasov.pdf
- Keyboard_layout_v1.0.pdf
- Prezentare_CoBra.pdf
- Prezentare_CoBra_sistemul_CPM.pdf

**datasheets**
- 8255A_(Intel).pdf
- 8272A_(Intel).pdf
- Am8212_(AMD).pdf
- Z80CPU.pdf
- Z80_CPU_Peripherals.pdf

**original_manual_scans:** `pag01.jpg`–`pag70.jpg`, the 1988 Romanian manual. pag70 is the mainboard component placement.

**pages:** text and HTML snapshots of the cobrasov.com hardware and software pages, plus their images.
