pdos_prompt = $7A05
chrout = $ffd2 ;KERNAL Send a char to the current output device

menu_ptr = $54 ;Pointer used to read bytes from the menu

    *=$7c00

    jmp start

menu:
;The menu consists of two columns of 20 characters each.
;It is displayed like this:
;
;  A-MACROASM/EDIT     N-RENAME A FILE
;  B-                  O-
;  C-                  P-PRINT DISK DIRECT
;  D-DUMP DISK OR MEM  Q-
;  E-                  R-RE-ENTER BASIC
;  F-                  S-SAVE A PROGRAM
;  G-GO TO MEMORY      T-
;  H-HELP              U-UTILITY DISK MENU
;  I-                  V-
;  J-                  W-
;  K-KILL A FILE       X-EXECUTE DISK FILE
;  L-LOAD DISK PROGRAM Y-
;  M-MEMORY ALTER      Z-
;
;The table uses 3 marker bytes:
;  '!' End of a left column item
;  '%' End of a right column item
;  $FF End of the menu
;
    !text "A-MACROASM/EDIT"     ,'!',   "N-RENAME A FILE"       ,'%'
    !text "B-"                  ,'!',   "O-"                    ,'%'
    !text "C-"                  ,'!',   "P-PRINT DISK DIRECT"   ,'%'
    !text "D-DUMP DISK OR MEM"  ,'!',   "Q-"                    ,'%'
    !text "E-"                  ,'!',   "R-RE-ENTER BASIC"      ,'%'
    !text "F-"                  ,'!',   "S-SAVE A PROGRAM"      ,'%'
    !text "G-GO TO MEMORY"      ,'!',   "T-"                    ,'%'
    !text "H-HELP"              ,'!',   "U-UTILITY DISK MENU"   ,'%'
    !text "I-"                  ,'!',   "V-"                    ,'%'
    !text "J-"                  ,'!',   "W-"                    ,'%'
    !text "K-KILL A FILE"       ,'!',   "X-EXECUTE DISK FILE"   ,'%'
    !text "L-LOAD DISK PROGRAM" ,'!',   "Y-"                    ,'%'
    !text "M-MEMORY ALTER"      ,'!',   "Z-"                    ,'%'
    !byte $ff

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

next_item:
;Read and display the next menu item
;
    ldx #20             ;X = 20 characters in this column

next_char:
;Read the next character of the current menu item
;
    lda (menu_ptr),y    ;Get a character from the menu
    inc menu_ptr        ;Increment pointer low byte
    bne eval_char       ;Branch if pointer high byte doesn't need to change
    inc menu_ptr+1      ;Increment pointer high byte

eval_char:
;Evaluate the character
;
    cmp #'!'            ;Is this the end of a left column menu item?
    beq finish_left     ;  Yes: branch to space over into the right side

    cmp #'%'            ;Is this the end of a right column menu item?
    beq finish_right    ;  Yes: branch to go to the next line

    cmp #$FF            ;Is this the end of the menu?
    beq finish_menu     ;  Yes: branch to finish up

    ;Menu byte read is a normal character that should be displayed

    jsr chrout          ;Print the character
    dex                 ;Decrement count of chars remaining
    bne next_char       ;Branch to do the next character

finish_left:
;Handle menu character '!'
;
;End of a left column menu item has been reached.  Space over
;until we are at the start of the right column.
;
    lda #' '            ;A = space character
left_loop:
    jsr chrout          ;Print a space
    dex                 ;Decrement count of chars remaining
    bne left_loop       ;Loop until all spaces are printed
    beq next_item       ;Branch always to next line

finish_right:
;Handle menu character '%'
;
;End of a right column menu item has been reached.  Print a newline
;so the next menu item is displayed at the beginning of the next line.
;
    lda #$0D            ;A = carriage return
    jsr chrout          ;Print it
    jmp next_item       ;Jump to next line

finish_menu:
;Handle menu character $FF
;
;End of the menu has been reached.  Print a newline to finish
;the current line, and then another newline to finish the menu.
;
    lda #$0D            ;A = carriage return
    jsr chrout          ;Print a CR to finish the current line
    jsr chrout          ;Print another CR to finish the menu

    jmp pdos_prompt     ;Jump out to the PDOS prompt

filler:
    !byte $45,$20,$20,$54,$59,$50,$45,$20,$54,$52,$4B,$20,$53,$43,$54,$52
    !byte $20,$23,$53,$43,$54,$52,$53,$00,$53,$45,$51,$00,$49,$4E,$44,$00
    !byte $49,$53,$4D,$00,$42,$41,$53,$00,$41,$53,$4D,$00,$4C,$44,$20,$00
    !byte $54,$58,$54,$00,$4F
