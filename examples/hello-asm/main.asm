; ============================================================
; Hello World — 6510 Assembly for Commodore 64
;
; Prints "HELLO, WORLD!" using the KERNAL CHROUT routine at
; $FFD2, which sends one PETSCII character in register A to
; the current output device (screen by default).
;
; Build: make DIR=examples/hello-asm
; Run:   make run DIR=examples/hello-asm
; ============================================================

CHROUT = $ffd2          ; KERNAL: output character in A

*= $0801                ; BASIC program start address

; BASIC line: 10 SYS 2064  ($0810 decimal = start of machine code)
        !byte $0b,$08   ; pointer to next BASIC line ($080B)
        !byte $0a,$00   ; line number 10
        !byte $9e       ; BASIC token: SYS
        !text " 2064"   ; SYS argument as ASCII digits
        !byte $00       ; end of BASIC line
        !byte $00,$00   ; end of BASIC program

*= $0810                ; machine code at decimal 2064

start:
        lda #147        ; PETSCII $93 = CLR/HOME — clears screen
        jsr CHROUT

        ldx #0
print:  lda msg,x       ; load next character from message
        beq done        ; null terminator — stop
        jsr CHROUT      ; print the character
        inx
        bne print

done:   rts             ; return to BASIC

msg:    !text "HELLO, WORLD!"
        !byte 13        ; PETSCII carriage return
        !byte 0         ; null terminator
