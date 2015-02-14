L7A47 = $7A47
LEF59 = $EF59
LFFD2 = $FFD2

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
    jsr $EFE7

L7CA0:
    jsr LEF59
    cmp #$31
    bmi L7CB5
    cmp #$35
    bpl L7CB5
    pha
    lda #$0D
    jsr LFFD2
    pla
    jmp L7A47

L7CB5:
    lda #$3F
    jsr LFFD2
    lda #$9D
    jsr LFFD2
    jsr LFFD2
    jmp L7CA0

filler:
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
