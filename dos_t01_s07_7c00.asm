L3D7D = $3D7D
L7A05 = $7A05
L7AD1 = $7AD1
LCF83 = $CF83
LECE4 = $ECE4
LED3F = $ED3F
LEEFB = $EEFB
LEF1B = $EF1B
LEF59 = $EF59
LEFE7 = $EFE7
LEFED = $EFED
LFFD2 = $FFD2

    *=$7c00

    jmp L7C5B

    !text $0d,"PEDISK II DISK UTILITY"
    !text $0d,"READ OR WRITE (HIT R OR W KEY)?",0
    !text $0d,"TRACK? ",0
    !text $0d,"SECTOR? ",0
    !text $0d,"# SECTORS? ",0

L7C5B:
    lda #$03
    ldy #$7C
    jsr LEFE7
    jsr LEF59
    sta $7F97
    cmp #$52
    beq L7C70
    cmp #$57
    bne L7C5B
L7C70:
    lda #$0D
    jsr LFFD2
    jsr L7AD1
    sta $7F91
    lda #$3B
    ldy #$7C
    jsr LEFE7
    jsr LEF1B
    sta $7F92
    lda #$44
    ldy #$7C
    jsr LEFE7
    jsr LEF1B
    sta $7F93
    lda #$4E
    ldy #$7C
    jsr LEFE7
    jsr LEF1B
    sta $7F96
    jsr LEEFB
    lda $66
    sta $B7
    lda $67
    sta $B8
    lda $7F97
    cmp #$57
    bne L7CBA
    jsr LED3F
    jmp L7A05
L7CBA:
    jsr LECE4
    jmp L7A05
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    stx $3F92
    inx
    stx $3F93
    stx $E982
L7CD2:
    jsr L3D7D
    lda #$6C
    ldy #$3C
    jsr LEFED
    lda #$00
    ldx $3F92
    jsr LCF83
    inc $3F92
    lda #$50
    cmp $3F92
    bpl L7CD2
    lda #$00
    sta $B7
    lda #$3F
    sta $B8
    ldy #$7F
    lda #$FF
L7CFA:
    sta ($B7),y
    dey
    bpl L7CFA
    !byte $A2
