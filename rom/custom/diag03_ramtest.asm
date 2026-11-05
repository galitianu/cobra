; diag03_ramtest: RAM test that uses NO RAM itself (no stack, no variables).
; Only documented Z80 instructions (the MMN 80CPU is a clone; avoid undocumented ones).
;
; Startup memory map (80K and 64K-mod boards), with 8255 PC6 = O6 = 1:
;   C000-DAFF  video RAM, screen + attributes                        -> region 1
;   8000-BFFF  RAM0 (4164 bank; on 64K maps 1/2 bank 0 + video upper) -> region 2
;   DB00-FFFF  rest of the C000 window                                -> region 3
;
; Each region: fill+verify 00h, FFh, 55h, AAh, then an address pattern (byte = L xor H)
; that catches address-line faults. Region 1 is video RAM, so the LCD shows the
; patterns being written (solid paper, solid ink, stripes, noise).
;
; Border (LCD is mono, only dark/bright matter):
;   BLACK  while testing region 1 (video RAM)
;   WHITE  while testing regions 2 and 3
;   after a full pass: 3 quick black/white flashes, then the test repeats forever.
;   Border frozen black or white forever = the CPU crashed while testing that region.
;
; On a failure it loops forever (all on the border):
;   ~4.8 s black | region: N short white flashes | ~2.4 s black |
;   8 bits of the bad-bit mask, then 8 bits of the failing address high byte, MSB first:
;     long white (~1.2 s) = 1, short white (~0.3 s) = 0, ~0.6 s black after each bit.
;   Film it; the agent decodes it.
;
; Registers in the fail loop: D = region, E = bad-bit mask, H = failing address high byte.

        OUTPUT  "diag03_ramtest.bin"
        ORG     $0000

PORTC   EQU     $FE
CTRL    EQU     $DF
O6      EQU     $40             ; keep PC6 = 1: video RAM mapped at C000 in the startup config
BLACK   EQU     O6 | 0
WHITE   EQU     O6 | 7

; ~0.3 s per unit at 3.5 MHz. Uses A, C, L only.
        MACRO   DELAY units
        ld      c,units
.o:     ld      l,0
.m:     xor     a
.i:     dec     a
        jr      nz,.i
        dec     l
        jr      nz,.m
        dec     c
        jr      nz,.o
        ENDM

        MACRO   BORDER col
        ld      a,col
        out     (PORTC),a
        ENDM

; fill [base, base+len) with constant pat, verify, jump to fail on mismatch
        MACRO   FILLTEST base, len, pat, code
        ld      hl,base
        ld      bc,len
.w:     ld      (hl),pat
        inc     hl
        dec     bc
        ld      a,b
        or      c
        jr      nz,.w
        ld      hl,base
        ld      bc,len
.r:     ld      a,(hl)
        cp      pat
        jr      nz,.bad
        inc     hl
        dec     bc
        ld      a,b
        or      c
        jr      nz,.r
        jr      .ok
.bad:   xor     pat
        ld      e,a
        ld      d,code
        jp      fail
.ok:
        ENDM

; fill with (L xor H), verify
        MACRO   ADDRTEST base, len, code
        ld      hl,base
        ld      bc,len
.w:     ld      a,l
        xor     h
        ld      (hl),a
        inc     hl
        dec     bc
        ld      a,b
        or      c
        jr      nz,.w
        ld      hl,base
        ld      bc,len
.r:     ld      a,l
        xor     h
        ld      e,a
        ld      a,(hl)
        cp      e
        jr      nz,.bad
        inc     hl
        dec     bc
        ld      a,b
        or      c
        jr      nz,.r
        jr      .ok
.bad:   xor     e
        ld      e,a
        ld      d,code
        jp      fail
.ok:
        ENDM

        MACRO   REGION base, len, code
        FILLTEST base, len, $00, code
        FILLTEST base, len, $FF, code
        FILLTEST base, len, $55, code
        FILLTEST base, len, $AA, code
        ADDRTEST base, len, code
        ENDM

; show register r (8 bits, MSB first); keeps r intact (8 rotations). Uses A, B, C, L.
        MACRO   SHOWBYTE r
        ld      b,8
.bit:   BORDER  WHITE
        rlc     r
        jr      c,.one
        DELAY   1
        jr      .gap
.one:   DELAY   4
.gap:   BORDER  BLACK
        DELAY   2
        djnz    .bit
        ENDM

start:  di
        ld      a,$83           ; R bit 7 = 1: keep the startup memory map (don't rely on A at reset)
        ld      r,a
        ld      bc,0            ; ~0.5 s settle before touching the 8255 (as the boot ROM does)
settle: dec     bc
        ld      a,b
        or      c
        jr      nz,settle
        ld      a,$92           ; 8255: A in, B in, C out
        out     (CTRL),a

pass:   BORDER  BLACK
        REGION  $C000, $1B00, 1
        BORDER  WHITE
        REGION  $8000, $4000, 2
        REGION  $DB00, $2500, 3
        ld      b,3             ; pass marker: 3 quick flashes
flash:  BORDER  BLACK
        DELAY   1
        BORDER  WHITE
        DELAY   1
        djnz    flash
        jp      pass

fail:   ; D = region, E = bad-bit mask, H = failing address high byte
show:   BORDER  BLACK
        DELAY   16
        ld      b,d
rflash: BORDER  WHITE
        DELAY   1
        BORDER  BLACK
        DELAY   2
        djnz    rflash
        DELAY   8
        SHOWBYTE e
        DELAY   4
        SHOWBYTE h
        jp      show

        OUTEND
