    PROCESSOR 6502

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Include required files with VCS register memory mapping and macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    INCLUDE "vcs.h"
    INCLUDE "macro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Declare the variables starting from memory address $80
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    SEG.U Variables
    ORG $80

JetXPos         BYTE        ; player0 x-position
JetYPos         BYTE        ; player0 x-position
BomberXPos      BYTE        ; Enemy X-Position
BomberYPos      BYTE        ; Enemy Y-Position
MissileXPos     BYTE        ; missile x-position
MissileYPos     BYTE        ; missile y-position
Score           BYTE        ; 2-digit score stored as BCD
Timer           BYTE        ; 2-digit timer stored as BCD
Temp            BYTE        ; auxiliary variable to store temporary score values
OnesDigitOffset WORD        ; lookup table offset for the score 1's digit
TensDigitOffset WORD        ; lookup table offset for the score 10's digit
JetSpritePtr    WORD        ; pointer to player0 sprite lookup table
JetColorPtr     WORD        ; pointer to player0 color lookup table
BomberSpritePtr WORD        ; pointer to player1 sprite lookup table
BomberColorPtr  WORD        ; pointer to player1 color lookup table
JetAnimOffset   BYTE        ; player sprite frame offset for animation
Random          BYTE        ; random number generated to set enemy position
ScoreSprite     BYTE        ; store the sprite bit pattern for the score
TimerSprite     BYTE        ; store the sprite bit pattern for the timer
TerrainColor    BYTE        ; store the color of the terrain
RiverColor      BYTE        ; store the color of the river

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
JET_HEIGHT = 9              ; player0 sprite height (# rows in lookup table)
BOMBER_HEIGHT = 9           ; player1 sprite height (# rows in lookup table)
DIGITS_HEIGHT = 5           ; scoreboard digit height (#rows in lookup table)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start our ROM code at memory address $F000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    SEG Code
    ORG $F000

Reset:
    CLEAN_START             ; Reset memory and address

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialize RAM variables and TIA registers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    LDA #10
    STA JetYPos             ; JetYPos = 10

    LDA #60
    STA JetXPos             ; JetXPos = 60

    LDA #83
    STA BomberYPos          ; BomberYPos = 83

    LDA #54
    STA BomberXPos          ; BomberXPos = 54

    LDA #%11010100
    STA Random              ; Random = $D4

    LDA #0
    STA Score
    STA Timer               ; Score = Timer = 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Declare a MACRO to check if we should display the missile 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    MAC DRAW_MISSILE
        LDA #%00000000
        CPX MissileYPos     ; compare X (current scanline) with missile Y pos
        BNE .SkipMissileDraw ; if (X != missile Y position), then skip draw
.DrawMissile:                ; else:
        LDA #%00000010       ;   enable missile 0 display
        INC MissileYPos      ;   MissileYPos++
.SkipMissileDraw:
        STA ENAM0            ; store the correct value in the TIA missile register
    ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialize the pointers to the correct lookup table addresses
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    LDA #<JetSprite
    STA JetSpritePtr        ; lo-byte pointer for jet sprite lookup table
    LDA #>JetSprite
    STA JetSpritePtr+1      ; hi-byte pointer for jet sprite lookup table

    LDA #<JetColor
    STA JetColorPtr         ; lo-byte pointer for jet color lookup table
    LDA #>JetColor
    STA JetColorPtr+1       ; hi-byte pointer for jet color lookup table

    LDA #<BomberSprite
    STA BomberSpritePtr        ; lo-byte pointer for bomber sprite lookup table
    LDA #>BomberSprite
    STA BomberSpritePtr+1      ; hi-byte pointer for bomber sprite lookup table

    LDA #<BomberColor
    STA BomberColorPtr        ; lo-byte pointer for bomber color lookup table
    LDA #>BomberColor
    STA BomberColorPtr+1      ; hi-byte pointer for bomber color lookup table

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start the main display loop and frame rendering
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display VSYNC and VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    LDA #2
    STA VBLANK              ; turn on VBLANK
    STA VSYNC               ; turn on VSYNC
    REPEAT 3
        STA WSYNC           ; Display 3 recommended lines of VSYNC
    REPEND
    LDA #0
    STA VSYNC               ; turn off vsync
    REPEAT 33
        STA WSYNC           ; Display the recommended lines of VBLANK
    REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Calculations and tasks performed in the VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    LDA JetXPos
    LDY #0
    JSR SetObjectXPos       ; set player0 horizontal position

    LDA BomberXPos
    LDY #1
    JSR SetObjectXPos       ; set player1 horizontal position

    LDA MissileXPos
    LDY #2
    JSR SetObjectXPos       ; set misssile horizontal position

    JSR CalculateDigitOffset ; calculate the scoreboard digits lookup table offset

    JSR GenerateJetSound     ; configure  and anable our jet engine audio

    STA WSYNC
    STA HMOVE               ; apply the horizontal offsets previously set

    LDA #0
    STA VBLANK              ; turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display the scoreboard lines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    LDA #0
    STA PF0
    STA PF1
    STA PF2
    STA GRP0
    STA GRP1
    STA CTRLPF
    STA COLUBK              ; reset TIA registers before displaying the score

    LDA #$1E
    STA COLUPF              ; set the scoreboard playfield color with yellow

    LDX #DIGITS_HEIGHT      ; start X counter with 5 (height of the digits)

.ScoreDigitLoop:
    LDY TensDigitOffset     ; get the tens digit offset for the Score
    LDA Digits,Y            ; load the bit pattern from lookup table
    AND #$F0                ; mask/remove the graphics for the ones digit
    STA ScoreSprite         ; save the score tens digit pattern in a variable

    LDY OnesDigitOffset     ; get the ones digit offset for the Score
    LDA Digits,Y            ; load the digit bit pattern from lookup table
    AND #$0F                ; mask/remove the graphics for the tens digit
    ORA ScoreSprite         ; merge it with the saved tens digit sprite
    STA ScoreSprite         ; and save it
    STA WSYNC               ; wait for the end of scanline
    STA PF1                 ; update the playfield to display the Score Sprite

    LDY TensDigitOffset+1   ; get the left digit offset for the Timer
    LDA Digits,Y            ; load the digit pattern from lookup table
    AND #$F0                ; mask/remove the graphics for the ones digit
    STA TimerSprite         ; save the timer tens digit pattern in a variable

    LDY OnesDigitOffset+1   ; get the ones digit offset for the Timer
    LDA Digits,Y            ; load digit pattern from the lookup table
    AND #$0F                ; mask/remove the graphics for the tens digit
    ORA TimerSprite         ; merge with the saved tens digit graphics
    STA TimerSprite         ; and save it

    JSR Sleep12Cycles       ; wastes some cycles

    STA PF1                 ; update the playfield for timer display

    LDY ScoreSprite         ; preload for the next scanline
    STA WSYNC               ; wait for next scanline

    STY PF1                 ; update playfield for the score display
    INC TensDigitOffset
    INC TensDigitOffset+1
    INC OnesDigitOffset
    INC OnesDigitOffset+1   ; increment all digits for the next line of data

    JSR Sleep12Cycles       ; waste some cycles

    DEX                     ; X--
    STA PF1                 ; update the playfield for timer display
    BNE .ScoreDigitLoop     ; if dex != 0, then branch to ScoreDigitloop

    STA WSYNC

    LDA #0
    STA PF0
    STA PF1
    STA PF2
    STA WSYNC
    STA WSYNC
    STA WSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display the 96 visibles scanlines of our main game (because 2-line kernel)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameVisibleLine:
    LDA TerrainColor
    STA COLUPF              ; set the terrain background color

    LDA RiverColor
    STA COLUBK              ; set the river background color

    LDA #%00000001
    STA CTRLPF              ; Enable playfield reflection

    LDA #$F0
    STA PF0                 ; setting PF0 bit pattern

    LDA #$FC
    STA PF1                 ; setting PF1 bit pattern

    LDA #0
    STA PF2                 ; setting PF2 bit pattern

    LDX #85                 ; X counts the number of remaining scanlines
.GameLineLoop:
    DRAW_MISSILE            ; macro to check if we should draw the missile

.AreWeInsideJetSprite:
    TXA                     ; transfer X to A
    SEC                     ; make sure the carry flag is set before subtraction
    SBC JetYPos             ; subtract sprite Y-coordinate
    CMP #JET_HEIGHT          ; are we inside the sprite height bounds?
    BCC .DrawSpriteP0       ; if result < SpriteHeight, call the draw routine
    LDA #0                  ; else, set the lookup index to zero
.DrawSpriteP0:
    CLC                     ; clear carry flag before addition
    ADC JetAnimOffset       ; jump to the correct sprite frame address in memory
    TAY                     ; load Y so we can work with the pointer
    LDA (JetSpritePtr),Y    ; load player0 bitmap data from lookup table
    STA WSYNC               ; wait for scanline
    STA GRP0                ; set graphics for player 0
    LDA (JetColorPtr),Y     ; load player color from lookup table
    STA COLUP0              ; set color of player 0

.AreWeInsideBomberSprite:
    TXA                     ; transfer X to A
    SEC                     ; make sure the carry flag is set before subtraction
    SBC BomberYPos          ; subtract sprite Y-coordinate
    CMP #BOMBER_HEIGHT       ; are we inside the sprite height bounds?
    BCC .DrawSpriteP1       ; if result < SpriteHeight, call the draw routine
    LDA #0                  ; else, set the lookup index to zero
.DrawSpriteP1:
    TAY                     ; load Y so we can work with the pointer
    LDA (BomberSpritePtr),Y ; load player1 bitmap data from lookup table
    STA WSYNC               ; wait for scanline
    STA GRP1                ; set graphics for player 1
    LDA (BomberColorPtr),Y  ; load player color from lookup table
    STA COLUP1              ; set color of player 1

    DEX                     ; X--
    BNE .GameLineLoop       ; repeat next main game scanline until finished

    LDA #0
    STA JetAnimOffset       ; reset jet animation frame to zero each frame

    STA WSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display Overscan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    LDA #2
    STA VBLANK              ; turn VBLANK on again
    REPEAT 30
        STA WSYNC           ; display 30 recommended lines of VBLANK Overscan
    REPEND
    LDA #0
    STA VBLANK              ; turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Process joystick input for player0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckP0Up:
    LDA #%00010000          ; player0 joystick up
    BIT SWCHA
    BNE CheckP0Down         ; if bit pattern doesnt match, bypass UP
    LDA #0
    STA JetAnimOffset       ; reset sprite animation to first frame
    LDA JetYPos
    CMP #70                 ; if (player0 Y position > 70)
    BPL CheckP0Down         ;   then: skip increment
    INC JetYPos             ;   else: increment Y position

CheckP0Down:
    LDA #%00100000          ; player0 joystick down
    BIT SWCHA
    BNE CheckP0Left         ; if bit doesnt match bypass Down block
    LDA #0
    STA JetAnimOffset       ; reset sprite animation to first frame
    LDA JetYPos
    CMP #5                  ; if (player Y position < 5)
    BMI CheckP0Left         ;   then: skip decrement
    DEC JetYPos             ;   else: decrement Y position

CheckP0Left:
    LDA #%01000000          ; player0 joystick left
    BIT SWCHA
    BNE CheckP0Right        ; if bit doesnt match bypass Left block
    LDA #18
    STA JetAnimOffset       ; set animation offset to the third frame
    LDA JetXPos
    CMP #35                 ; if (player0 X position < 35)
    BMI CheckP0Right        ;   then: skip decrement
    DEC JetXPos             ;   else: decrement x position

CheckP0Right:
    LDA #%10000000          ; player0 joystick right
    BIT SWCHA
    BNE CheckButtonPressed
    LDA #9
    STA JetAnimOffset       ; set animation offset to the second frame
    LDA JetXPos
    CMP #100                ; if (player0 X position > 100)
    BPL CheckButtonPressed  ;   then: skip increment
    INC JetXPos             ;   else: increment X position

CheckButtonPressed:
    LDA #%10000000          ; if button is pressed
    BIT INPT4
    BNE EndInputCheck
.SetMissilePos:
    LDA JetXPos
    CLC
    ADC #5
    STA MissileXPos         ; set the missile X position equal to the player 0
    LDA JetYPos
    CLC
    ADC #8
    STA MissileYPos         ; set the missile Y position equal to the player 0

EndInputCheck:              ; fallback when no input was perfomed

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Calculations to update position for next frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UpdateBomberPosition:
    LDA BomberYPos
    CLC
    CMP #0                   ; compare bomber y-position with 0
    BMI .ResetBomberPosition ; if it is < 0, then reset y-position to the top
    DEC BomberYPos           ; else, decrement enemy y-position for the next frame
    JMP EndPositionUpdate
.ResetBomberPosition
    JSR GetRandomBomberPos   ; call subroutine for random x-position

.SetScoreValues:
    SED                      ; set BCD for score and timer values
    LDA Timer
    CLC
    ADC #1
    STA Timer                ; add 1 to the Timer (BCD does not like INC)
    CLD                      ; disable BCD after updating Score and Timer

EndPositionUpdate:           ; fallback for the position update code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Check for object collision
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckCollisionP0P1:
    LDA #%10000000           ; CXPPMM bit 7 detects P0 and P1 collision
    BIT CXPPMM               ; check CXPPMM bit 7 with the above pattern
    BNE .P0P1Collided       ; if collision P0 and P1 happened, game over
    JSR SetTerrainRiverColor ; else, set playfield color to green/blue
    JMP CheckCollisionM0P1   ; else, skip to next check
.P0P1Collided:
    JSR GameOver             ; call GameOver subroutine

CheckCollisionM0P1:
    LDA #%10000000           ; CXM0P bit 7 detects M0 and P1 collision
    BIT CXM0P                ; check CXM0P bit 7 with the above pattern
    BNE .M0P1Collided        ; collision missile 0 and player 1 happened
    JMP EndCollisionCheck
.M0P1Collided:
    SED
    LDA Score
    CLC
    ADC #1
    STA Score                ; adds 1 to the Score using BCD
    CLD
    LDA #0
    STA MissileYPos          ; reset the missile position

EndCollisionCheck:           ; fallback
    STA CXCLR                ; clear all collision flags before the next frame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loop back to start a brand new frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    JMP StartFrame          ; continue to display next frame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate audio for the jet engine sound based on the jet y position
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GenerateJetSound SUBROUTINE
    LDA #3
    STA AUDV0               ; set the new audio volume register

    LDA JetYPos             ; loads the accumulator with the jet y-position
    LSR
    LSR
    LSR                     ; divide the accumulator by 8 (using right-shifts)
    STA Temp                ; save the Y/8 value in a temp variable
    LDA #31
    SEC
    SBC Temp                ; subtract 31-(Y/8)
    STA AUDF0               ; set the new audio frequency/pitch register

    LDA #8
    STA AUDC0               ; set the new audio tone type register

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set the colors for the terrain and river to green & blue
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetTerrainRiverColor SUBROUTINE
    LDA #$C2
    STA TerrainColor        ; set terrain color to green
    LDA #$84
    STA RiverColor          ; set river color to blue

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subroutine to handle object horizontal position with fine offset
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A is the target x-coordinate positon in pixels of our object
;; Y is the object type (0: player0, 1:player1, 2:missile0, 3:missile1, 4:ball)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetObjectXPos SUBROUTINE
    STA WSYNC               ; start a fresh new scanline
    SEC                     ; make sure carry-flag is set before subtraction
.Div15Loop
    SBC #15                 ; subtract 15 from accumulator
    BCS .Div15Loop          ; loop unitl carry-flag is clear
    EOR #7                  ; handle offset range from -8 to 7
    ASL
    ASL
    ASL
    ASL                     ; four shift lefts to get only the top 4 bits
    STA HMP0,Y              ; store the fine offset to the correct HMxx
    STA RESP0,Y             ; fix object position in 15-step increment
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Game Over subroutine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameOver SUBROUTINE
    LDA #$30
    STA TerrainColor        ; set terrain color to red
    STA RiverColor          ; set river color to red
    LDA #0
    STA Score               ; Score = 0

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subroutine to generate a Linear-Feedback Shift Register random number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate a LFSR random number
;; Divide the random value by 4 to limit the size of the result to match river.
;; Add 30 to compensate for the left green playfield
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetRandomBomberPos SUBROUTINE
    LDA Random
    ASL
    ASL
    EOR Random
    EOR Random
    ASL
    ASL
    EOR Random
    ASL
    ROL Random              ; performs a series of shifts and bit operations

    LSR
    LSR                     ; divide the value by 4 with 2 right shifts
    STA BomberXPos          ; save it to the variable BomberXPos
    LDA #30
    ADC BomberXPos          ; adds 30 + BomberXPos to comepensate for left PF
    STA BomberXPos          ; and sets the new value to the bomber x-position

    LDA #96
    STA BomberYPos          ; set the y-position to the top of the screen
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subroutine to handle scoreboard digits to be displayed on the screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Convert the high and low nibbles of the variable Score and Timer
;; into the offsets of digits lookup table so the values can be displayed.
;; Each digit has a height of 5 bytes in the lookup table.
;;
;; For the low nibble we need to multiply by 5
;;  - we can use left shifts to perform multiplication by 2
;;  - for any number N, the value of N*5 = (N*2*2)+N
;;
;; For the upper nibble, since its already times 16, we need to divide it
;; and then multiply by 5:
;;  - we can use right shifts to perform division by 2
;;  - for any number N, the value of (N/16)*5 = (N/2/2)+(N//2/2/2/2)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CalculateDigitOffset SUBROUTINE
    LDX #1                  ; X register is the loop counter
.PrepareScoreLoop           ; this will loop twice, first X=1, and then X=0

    LDA Score,X             ; load A with Timer (X=1) or Score (X=1)
    AND #$0F                ; remove the tens digit by masking 4 bits 00001111
    STA Temp                ; save the value of A into Temp
    ASL                     ; shift left (it is now N*2)
    ASL                     ; shift left (it is now N*4)
    ADC Temp                ; add the value saved in Temp (+N)
    STA OnesDigitOffset,X   ; save A in OnesDigitOffset+1 or OnesDigitOffset

    LDA Score,X             ; load A with Timer (X=1) or Score (X=0)
    AND #$F0                ; remove the ones digits by masking 4 bits 11110000
    LSR                     ; shift right (it is now N/2)
    LSR                     ; shift right (it is now N/4)
    STA Temp                ; save the value of A into Temp
    LSR                     ; shift right (it is now N/8)
    LSR                     ; shift right (it is now N/16)
    ADC Temp                ; add the value saved in Temp (N/16+N/4)
    STA TensDigitOffset,X   ; store A in TensDigitOffset+1 or TensDigitOffset

    DEX                     ; X--
    BPL .PrepareScoreLoop   ; while X >=0, loop to pass a second time

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subroutine to waste 12 cycles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; jsr takes 6 cycles
;; rts takes 6 cycles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Sleep12Cycles SUBROUTINE
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Declare ROM lookup table
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Digits:
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###

    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #

    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %00110011          ;  ##  ##
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###

    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #

    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###

    .byte %00100010          ;  #   #
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #

    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01100110          ; ##  ##
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01000100          ; #   #
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###

    .byte %01100110          ; ##  ##
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01100110          ; ##  ##

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###

    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01100110          ; ##  ##
    .byte %01000100          ; #   #
    .byte %01000100          ; #   #

JetSprite:
    .byte #%00000000
    .byte #%00011000;$40
    .byte #%00011000;$40
    .byte #%01011010;$1E
    .byte #%01111110;$1C
    .byte #%01111110;$1A
    .byte #%00100100;$16
    .byte #%00011000;$16
    .byte #%00011000;$14

JetSpriteRight:
    .byte #%00000000
    .byte #%00000010;$40
    .byte #%00000010;$40
    .byte #%01011010;$1E
    .byte #%01111110;$1C
    .byte #%01111110;$1A
    .byte #%00100100;$16
    .byte #%00011000;$16
    .byte #%00011000;$14

JetSpriteLeft:
    .byte #%00000000
    .byte #%01000000;$40
    .byte #%01000000;$40
    .byte #%01011010;$1E
    .byte #%01111110;$1C
    .byte #%01111110;$1A
    .byte #%00100100;$16
    .byte #%00011000;$16
    .byte #%00011000;$14

BomberSprite:
    .byte #%00000000
    .byte #%00011000;$42
    .byte #%10100101;$42
    .byte #%11111111;$42
    .byte #%11111111;$42
    .byte #%11111111;$42
    .byte #%01111110;$42
    .byte #%01100110;$42
    .byte #%01100110;$42

JetColor:
    .byte #$00
    .byte #$40;
    .byte #$40;
    .byte #$1E;
    .byte #$1C;
    .byte #$1A;
    .byte #$16;
    .byte #$16;
    .byte #$14;

JetColorRight:
    .byte #$00
    .byte #$40;
    .byte #$40;
    .byte #$1E;
    .byte #$1C;
    .byte #$1A;
    .byte #$16;
    .byte #$16;
    .byte #$14;

JetColorLeft:
    .byte #$00
    .byte #$40;
    .byte #$40;
    .byte #$1E;
    .byte #$1C;
    .byte #$1A;
    .byte #$16;
    .byte #$16;
    .byte #$14;

BomberColor:
    .byte #$00
    .byte #$42;
    .byte #$42;
    .byte #$42;
    .byte #$42;
    .byte #$42;
    .byte #$42;
    .byte #$42;
    .byte #$42;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Complete ROM size with exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ORG $FFFC               ; move to position $FFFC
    WORD Reset              ; write 2 bytes with the program reset address
    WORD Reset              ; write 2 bytes with the interruption vector
