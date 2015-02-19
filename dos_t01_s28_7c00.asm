L7A05 = $7A05
L7AA3 = $7AA3
write_a_sector = $ED3A
find_file = $EE33
puts = $EFE7

    *=$7c00

    jmp L7C6F

old_file:
    !text $0d,"PEDISK II FILE RENAME UTILITY",$0d
    !text "OLD FILE-",0
new_file:
    !text $0d,"NEW FILE-",0
already_in_file:
    !text $0d,"****NAME ALREADY IN FILE****",0
not_in_dir:
    !text $0d,"****NOT IN DIRECTORY****",0

L7C6F:
    ;Print banner and "OLD FILE-"
    lda #<old_file
    ldy #>old_file
    jsr puts

    jsr L7AA3
    ldx #$05
L7C7B:
    lda $7FA0,x
    sta L7CD2,x
    dex
    bpl L7C7B
    lda $7FB1
    sta L7CD8

    ;Print "NEW FILE-"
    lda #<new_file
    ldy #>new_file
    jsr puts

    jsr L7AA3
    jsr find_file
    tax
    bmi L7CAF
    beq L7CC3
    ldx #$05
L7C9E:
    lda $7FA0,x
    pha
    lda L7CD2,x
    sta $7FA0,x
    dex
    bpl L7C9E
    jsr find_file
    tax
L7CAF:
    bmi L7CC0
    bne L7CCD
    ldy #$00
L7CB5:
    pla
    sta ($22),y
    iny
    cpy #$06
    bmi L7CB5
    jsr write_a_sector
L7CC0:
    jmp L7A05

L7CC3:
    ;Print "****NAME ALREADY IN FILE****"
    lda #<already_in_file
L7CC5:
    ldy #>already_in_file
    jsr puts
    jmp L7A05

L7CCD:
    ;"****NOT IN DIRECTORY****"
    lda #<not_in_dir
    jmp L7CC5

L7CD2:
    !byte 0,0,0,0,0,0
L7CD8:
    !byte 0

filler:
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF
