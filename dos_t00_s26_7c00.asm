L7A05 = $7A05
L7D97 = $7D97
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
;The table uses these marker bytes:
;  $21 End of a left column item
;  $25 End of a right column item
;  $FF End of the menu
;
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
    cmp #$21            ;Is this the end of a left column menu item?
    beq finish_left     ;  Yes: branch to space over into the right side

    cmp #$25            ;Is this the end of a right column menu item?
    beq finish_right    ;  Yes: branch to go to the next line

    cmp #$FF            ;Is this the end of the menu?
    beq finish_menu     ;  Yes: branch to finish up

    ;Menu byte read is a normal character that should be displayed

    jsr chrout          ;Print the character
    dex                 ;Decrement count of chars remaining
    bne next_char       ;Branch to do the next character

finish_left:
;Handle menu character = #$21
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
;Handle menu character = #$25
;
;End of a right column menu item has been reached.  Print a newline
;so the next menu item is displayed at the beginning of the next line.
;
    lda #$0D            ;A = carriage return
    jsr chrout          ;Print it
    jmp next_item       ;Jump to next line

finish_menu:
;Handle menu character = #$FF
;
;End of the menu has been reached.  Print a newline to finish
;the current line, and then another newline to finish the menu.
;
    lda #$0D            ;A = carriage return
    jsr chrout          ;Print a CR to finish the current line
    jsr chrout          ;Print another CR to finish the menu

    jmp L7A05           ;Jump out to ? TODO ?
                        ;This seems to be the way that $7C00 overlays
                        ;return control to the $7A00 code.

filler:
;The bytes from here to the end of the file are not used by the code
;above.  They are likely part of another $7C00 overlay that happened
;to be in memory when this overlay was saved to disk.
;
    !text $45,"  TYPE TRK SCTR #SCTRS",0
    !text "SEQ",0
    !text "IND",0
    !text "ISM",0
    !text "BAS",0
    !text "ASM",0
    !text "LD ",0
    !text "TXT",0
    !byte $4f
