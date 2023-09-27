    PROCESSOR 6502
    SEG Code        ; Define a new segment named "Code"
    ORG $F000       ; Define the origin of the ROM code at memory address $F000
Start:
    LDA #15         ; Load the A register with the literal decimal value 15
    TAX             ; Transfer the value from A to X
    TAY             ; Transfer the value from A to Y
    TXA             ; Transfer the value from X to A
    TYA             ; Transfer the value from Y to A
    LDX #6          ; Load X with the decimal value 6
    TXA             ; Transfer X to A
    TAY             ; Transfer A to Y

    ORG $FFFC       ; End the ROM by adding required values to memory position $FFFC
    .WORD Start     ; Put 2 bytes with the reset address at memory position $FFFC
    .WORD Start     ; Put 2 bytes with the break address at memory position $FFFE