; diag01_border — first-light test. Uses NO RAM and NO stack.
;
; Proves: Z80 runs, boot EPROM is read correctly, I/O decoding works,
; 8255 is programmed, and the border/video output path works.
;
; Expected: the border steps through all 8 colours, about one second each:
;   0 black, 1 blue, 2 red, 3 magenta, 4 green, 5 cyan, 6 yellow, 7 white
; The screen area shows whatever garbage is in video DRAM; ignore it.
; On the scope, the 8255 port C bit 0 pin (PC0) toggles every ~1 s.
;
; Port use copied from the CoBra boot ROM: 8255 control word 92h to port DFh,
; port C (border in bits 0-2, bit 6 set as the boot ROM does) at port FEh.

        OUTPUT  "diag01_border.bin"
        ORG     $0000

start:  di
        ld      a,$83           ; R bit 7 = 1 keeps the board in the startup memory config
        ld      r,a
        ld      bc,0            ; ~0.5 s settle delay before touching the 8255 (boot ROM does the same)
settle: dec     bc
        ld      a,b
        or      c
        jr      nz,settle
        ld      a,$92           ; 8255: A in, B in, C out (mode 0)
        out     ($DF),a
        ld      e,0             ; E = colour counter
next:   ld      a,e
        and     $07
        or      $40
        out     ($FE),a         ; border colour
        ld      d,2             ; 2 x 65536 x 26 T ~= 0.97 s at 3.5 MHz
d1:     ld      bc,0
d2:     dec     bc
        ld      a,b
        or      c
        jr      nz,d2
        dec     d
        jr      nz,d1
        inc     e
        jr      next

        OUTEND
