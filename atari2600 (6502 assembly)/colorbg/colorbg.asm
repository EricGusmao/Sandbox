    PROCESSOR 6502

    INCLUDE "vcs.h"
    INCLUDE "macro.h"

    SEG Code
    ORG $F000       ; Defines the origin of the ROM at $F000
START:
    CLEAN_START     ; Macro to safely clear the memory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set background luminosity color to yellow
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    LDA #$1E        ; Load color into A ($1E is NTSC yellow)
    STA COLUBK      ; Store A to BackgroundColor Address $09

    jmp START       ; Repeat from START
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fill ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ORG $FFFC       ; Defines origin to $FFFC
    .WORD START     ; Reset vector at $FFFC (where program starts)
    .WORD START     ; Interrupt vector at $FFFE (unused in the VCS)