    PROCESSOR 6502
    SEG Code        ; Define a new segment named "Code"
    ORG $F000       ; Define the origin of the ROM code at memory address $F000
Start:
    LDA #$82        ; Load the A register with the literal hexadecimal value $82
    LDX #82         ; Load the X register with the literal decimal value 82
    LDY $82         ; Load the Y register with the value that is inside memory position $82

    ORG $FFFC       ; End the ROM by adding required values to memory position $FFFC
    .WORD Start     ; Put 2 bytes with the reset address at memory position $FFFC
    .WORD Start     ; Put 2 bytes with the break address at memory position $FFFE