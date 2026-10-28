; diag02_nop — software "free-run" test. Uses NO RAM, NO I/O.
;
; The ROM is 2045 NOPs followed by JP 0000, so the CPU walks the whole 2 KB
; ROM address range forever. Address lines A0..A10 then show square-ish waves,
; each half the frequency of the one before. EPROM /CE and /OE pulse on every fetch.
;
; Caveat: during T3/T4 of every M1 cycle the Z80 puts the refresh address (R)
; on A0..A6, so those lines look busier than a pure counter. A7..A10 are clean:
;   A10 period = 2048 NOPs x 4 T = 8192 T  ~= 2.34 ms at 3.5 MHz
;   A9 1.17 ms, A8 585 us, A7 293 us.
; A11..A15 must stay LOW the whole time (we never leave 0000-07FF).
; /M1 must pulse every 4 T (~1.14 us). /IORQ and /WR must stay HIGH.

        OUTPUT  "diag02_nop.bin"
        ORG     $0000
        BLOCK   $07FD,$00       ; NOP x 2045
        jp      $0000

        OUTEND
