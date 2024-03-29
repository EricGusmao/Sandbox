    PROCESSOR 6502
    SEG Code        ; Define a new segment named "Code"
    ORG $F000       ; Define the origin of the ROM code at memory address $F000
Start:
	LDY #10         ; Initialize the Y register with the decimal value 10
Loop:
	TYA		        ; Transfer Y to A
    STA $80,Y       ; Store the value in A inside memory position $80+Y
    DEY             ; Decrement Y
    BPL Loop	    ; Branch back to "Loop" until we are done

    ORG $FFFC       ; End the ROM by adding required values to memory position $FFFC
    .WORD Start     ; Put 2 bytes with the reset address at memory position $FFFC
    .WORD Start     ; Put 2 bytes with the break address at memory position $FFFE