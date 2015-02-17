L2044 = $2044
L2045 = $2045
L2D45 = $2D45
L4944 = $4944
L4946 = $4946
L4949 = $4949
L4E49 = $4E49
L7A05 = $7A05
L7AA3 = $7AA3
LED3A = $ED3A
LEE33 = $EE33
LEFE7 = $EFE7

    *=$7c00

    jmp L7C6F

rename_utility:
    !text $0d,"PEDISK II FILE RENAME UTILITY",$0d
old_file:
    !text "OLD FILE-",0
new_file:
    !text $0d,"NEW FILE-",0
already_in_file:
    !text $0d,"****NAME ALREADY IN FILE****",0
not_in_dir:
    !text $0d,"****NOT IN DIRECTORY****",0

L7C6F:
    lda #<rename_utility
    ldy #>rename_utility
    jsr LEFE7
    jsr L7AA3
    ldx #$05
L7C7B:
    lda $7FA0,x
    sta L7CD2,x
    dex
    bpl L7C7B
    lda $7FB1
    sta L7CD8
    lda #<new_file
    ldy #>new_file
    jsr LEFE7
    jsr L7AA3
    jsr LEE33
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
    jsr LEE33
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
    jsr LED3A
L7CC0:
    jmp L7A05
L7CC3:
    lda #<already_in_file
L7CC5:
    ldy #>already_in_file
    jsr LEFE7
    jmp L7A05
L7CCD:
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
