    PROCESSOR 6502
    SEG Code        ; Define a new segment named "Code"
    ORG $F000       ; Define the origin of the ROM code at memory address $F000
Start:

    LDA #100        ; Load the A register with the literal decimal value 100

    CLC             ; ALWAYS clear the carry flag before calling ADC
    ADC #5          ; Add the decimal value 5 to the accumulator

    SEC             ; ALWAYS set the carry flag before calling SBC
    SBC #10         ; Subtract the decimal value 10 from the accumulator
                    ; Register A should now contain the decimal 95 (or $5F in hexadecimal)

    ORG $FFFC       ; End the ROM by adding required values to memory position $FFFC
    .WORD Start     ; Put 2 bytes with the reset address at memory position $FFFC
    .WORD Start     ; Put 2 bytes with the break address at memory position $FFFE