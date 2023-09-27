    PROCESSOR 6502

    SEG Code
    ORG $F000       ; Define the code origin at $F000

Start:
    SEI             ; Disable interrupts
    CLD             ; Disable the BCD decimal math mode
    LDX #$FF        ; Loads the X register with #$FF
    TXS             ; Transfer the X register to the (S)tack pointer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clear the Page Zero region ($00 to $FF)
; Meaning the entire RAM space and also the entire TIA registers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    LDA #0          ; A = 0
    LDX #$FF        ; X = #$FF
    STA $FF         ; make sure $FF is set to 0 (zero) before the loop starts
MemLoop:
    DEX             ; X-- (decrementing)
    STA $0,X        ; Store the value of A inside memory address $0 + X
    BNE MemLoop     ; Loop until X is equal to zero (z-flag is set)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ORG $FFFC       ; Define the code origin at $FFFC
    .WORD Start     ; Reset vector at $FFFC (where the program starts)
    .WORD Start     ; Interrupt vector at $FFFE (unused in the VCS)