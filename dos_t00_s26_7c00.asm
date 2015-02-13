L7A05 = $7A05
L7D97 = $7D97
chrout = $ffd2 ;KERNAL Send a char to the current output device

menu_ptr = $54 ;Pointer used to read bytes from the menu

    *=$7c00

    jmp start

menu:
    !text "A-MACROASM/EDIT",$21
    !text "N-RENAME A FILE",$25
    !text "B-",$21
    !text "O-",$25
    !text "C-",$21
    !text "P-PRINT DISK DIRECT",$25
    !text "D-DUMP DISK OR MEM",$21
    !text "Q-",$25
    !text "E-",$21
    !text "R-RE-ENTER BASIC",$25
    !text "F-",$21
    !text "S-SAVE A PROGRAM",$25
    !text "G-GO TO MEMORY",$21
    !text "T-",$25
    !text "H-HELP",$21
    !text "U-UTILITY DISK MENU",$25
    !text "I-",$21
    !text "V-",$25
    !text "J-",$21
    !text "W-",$25
    !text "K-KILL A FILE",$21
    !text "X-EXECUTE DISK FILE",$25
    !text "L-LOAD DISK PROGRAM",$21
    !text "Y-",$25
    !text "M-MEMORY ALTER",$21
    !text "Z-",$25
    !byte $ff ;Signals end of menu

start:
    ;Initialize pointer to menu
    lda #<menu
    sta menu_ptr        ;Set pointer low byte
    lda #>menu
    sta menu_ptr+1      ;Set pointer high byte

    ;Clear the screen
    lda #$93            ;A = clear screen
    jsr chrout          ;Print it

    ldy #0              ;Init Y for use with LDA (ptr),Y.  Y never changes.

next_line:
;Read the next line in the menu
;
    ldx #20             ;X = 33 characters in a line

next_char:
;Read the next character on the line
;
    lda (menu_ptr),y    ;Get a character from the menu
    inc menu_ptr        ;Increment pointer low byte
    bne eval_char       ;Branch if pointer high byte doesn't need to change
    inc menu_ptr+1      ;Increment pointer high byte

eval_char:
;Evaluate the character
;
    cmp #$21
    beq handle_21

    cmp #$25
    beq handle_25

    cmp #$FF
    beq handle_ff

    jsr chrout          ;Print the character
    dex                 ;Decrement count of chars remaining
    bne next_char       ;Branch to do the next character

handle_21:
;Handle menu character = #$21
;
    lda #' '            ;A = space character
h21_loop:
    jsr chrout          ;Print a space
    dex                 ;Decrement count of chars remaining
    bne h21_loop        ;Loop until all spaces are printed
    beq next_line       ;Branch always to next line

handle_25:
;Handle menu character = #$25
;
    lda #$0D            ;A = carriage return
    jsr chrout          ;Print it
    jmp next_line       ;Jump to next line

handle_ff:
;Handle menu character = #$FF
;
    lda #$0D            ;A = carriage return
    jsr chrout          ;Print it
    jsr chrout          ;Print another one

    jmp L7A05           ;Jump out to ? TODO ?
                        ;This seems to be the way that $7C00 overlays
                        ;return control to the $7A00 code.

    eor $20
    jsr $5954
    bvc L7D97
    jsr $5254
    !byte $4B
    jsr $4353
    !byte $54
    !byte $52
    jsr $5323
    !byte $43
    !byte $54
    !byte $52
    !byte $53
    brk
    !byte $53
    eor $51
    brk
    eor #$4E
    !byte $44
    brk
    eor #$53
    eor $4200
    eor ($53,x)
    brk
    eor ($53,x)
    eor $4C00
    !byte $44
    jsr $5400
    cli
    !byte $54
    brk
    !byte $4F
