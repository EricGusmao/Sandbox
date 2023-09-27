    PROCESSOR 6502
    SEG Code        ; Define a new segment named "Code"
    ORG $F000       ; Define the origin of the ROM code at memory address $F000
Start:
    LDA #10		    ; Load the A register with the decimal value 10
    STA $80         ; Store the value from A into memory position $80
    INC $80         ; Increment the value inside a (zero page) memory position $80
    DEC $80         ; Decrement the value inside a (zero page) memory position $80

    ORG $FFFC       ; End the ROM by adding required values to memory position $FFFC
    .WORD Start     ; Put 2 bytes with the reset address at memory position $FFFC
    .WORD Start     ; Put 2 bytes with the break address at memory position $FFFE