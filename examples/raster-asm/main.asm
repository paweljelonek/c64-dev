; ============================================================
; Raster Color Bars — 6510 Assembly for Commodore 64
;
; Classic demo technique: read the VIC-II raster counter at
; $D012 and change the border color on each raster line.
; Uses busy-loop polling — no IRQ setup required.
;
; Build: make DIR=examples/raster-asm
; Run:   make run DIR=examples/raster-asm
; ============================================================

RASTER  = $d012         ; VIC-II: current raster line (bits 0-7)
BORDER  = $d020         ; VIC-II: border color (bits 0-3, values 0-15)
BGCOL   = $d021         ; VIC-II: background color 0

*= $0801

; BASIC: 10 SYS 2064
        !byte $0b,$08,$0a,$00,$9e,$20,$32,$30,$36,$34,$00,$00,$00

*= $0810

start:
        sei             ; disable IRQs — we poll VIC-II directly

frame:
        ; wait for raster line 0 (start of new frame)
vblank: lda RASTER
        bne vblank

        ; draw bars until bottom of visible area (line 200)
bars:
        ; derive color from raster line: shift right once → 0-15 range
        lda RASTER
        lsr
        and #$0f
        sta BORDER
        sta BGCOL

        ; busy-wait until raster advances to next line
        lda RASTER
wait:   cmp RASTER
        beq wait

        ; loop while above line 200
        lda RASTER
        cmp #200
        bcc bars

        jmp frame
