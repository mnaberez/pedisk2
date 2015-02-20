L7A47   = $7A47
l_ef59  = $EF59         ;Get a character and test for {STOP}
puts    = $EFE7         ;Print null terminated string
chrout  = $FFD2         ;KERNAL Send a char to the current output device

    *=$7c00

    jmp start

menu:
    !text $93,"     PEDISK II",$0d
    !text " DISK UTILITY SELECT",$0d,$0d
    !text "1 COMPRESS DISK FILES",$0d
    !text "2 COPY DISK OR FILE",$0d
    !text "3 INITIALIZE DISK",$0d
    !text "4 DISK SECTOR READ & WRITE",$0d
    !text $0d,"ENTER SELECTION NUMBER ",0

start:
    lda #<menu
    ldy #>menu
    jsr puts

get_num:
    jsr l_ef59

    ;Validate selection
    cmp #'1'            ;Compare to '1'
    bmi bad_num         ;Less than '1?  Branch to handle bad selection
    cmp #'5'            ;Compare to '5'
    bpl bad_num         ;Equal or greater?  Branch to handle bad selection

    ;Print a newline
    pha
    lda #$0D
    jsr chrout
    pla

    ;TODO load the overlay?
    jmp L7A47

bad_num:
    ;Print '?'
    lda #'?'
    jsr chrout

    ;Move cursor over selection
    lda #$9D            ;PETSCII Cursor left
    jsr chrout          ;Move cursor left, now over "?"
    jsr chrout          ;Move cursor left, now over selection

    ;Try again
    jmp get_num

filler:
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
