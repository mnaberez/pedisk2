L0D00 = $0D00
L2052 = $2052
L2057 = $2057
L3D7D = $3D7D
L4553 = $4553
L4944 = $4944
L4949 = $4949
L524F = $524F
L5257 = $5257
L5455 = $5455
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

    ora     $4550
    !byte   $44
    eor     #$53
    !byte   $4B
    jsr     L4949
    jsr     L4944
    !byte   $53
    !byte   $4B
    jsr     L5455
    eor     #$4C
    eor     #$54
    eor     $520D,y
    eor     $41
    !byte   $44
    jsr     L524F
    jsr     L5257
    eor     #$54
    eor     $20
    plp
    pha
    eor     #$54
    jsr     L2052
    !byte   $4F
    !byte   $52
    jsr     L2057
    !byte   $4B
    eor     $59
    and     #$3F
    brk
    ora     $5254
    eor     ($43,x)
    !byte   $4B
    !byte   $3F
    jsr     L0D00
    !byte   $53
    eor     $43
    !byte   $54
    !byte   $4F
    !byte   $52
    !byte   $3F
    jsr     L0D00
    !byte   $23
    jsr     L4553
    !byte   $43
    !byte   $54
    !byte   $4F
    !byte   $52
    !byte   $53
    !byte   $3F
    !byte   $20
    brk

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
