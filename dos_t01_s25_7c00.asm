L7A05 = $7A05
L7AD1 = $7AD1
LEB84 = $EB84
LECDF = $ECDF
LEEFB = $EEFB
LEF1B = $EF1B
LEF59 = $EF59
LEFE7 = $EFE7
LFFD2 = $FFD2
LFFE4 = $FFE4

    *=$7c00

    jmp L7C52

    !text $0d,"  PEDISK II DUMP UTILITY"
    !text $0d,"DISK OR MEMORY ( D OR M )?",0
    !text $0d,"TRACK? ",0
    !text $0d,"SECTOR? ",0
    !text "MORE..",0

L7C52:
    lda #$03
    ldy #$7C
    jsr LEFE7
    lda #$0A
    sta $27
    jsr LEF59
    pha
    lda #$0D
    jsr LFFD2
    pla
    cmp #$44
    beq L7C94
    cmp #$4D
    bne L7C52
    jsr LEEFB
    lda #$0D
    jsr LFFD2
L7C77:
    lda $67
    jsr LEB84
    lda $66
    jsr LEB84
    ldx #$01
    jsr L7CF1
    lda $66
    clc
    adc #$10
    sta $66
    bcc L7C77
    inc $67
    bne L7C77
    rts
L7C94:
    jsr L7AD1
    sta $7F91
    lda #$38
    ldy #$7C
    jsr LEFE7
    jsr LEF1B
    sta $7F92
    lda #$41
    ldy #$7C
    jsr LEFE7
    jsr LEF1B
    sta $7F93
    lda #$00
    sta $B7
    sta $66
    lda #$7F
    sta $B8
    sta $67
L7CC0:
    jsr LECDF
    bne L7CEE
    lda #$0D
    jsr LFFD2
    lda $7F92
    jsr LEB84
    lda $7F93
    jsr LEB84
    clc
    adc #$01
    cmp #$1D
    bmi L7CE3
    sec
    sbc #$1C
    inc $7F92
L7CE3:
    sta $7F93
    ldx #$08
    jsr L7CF1
    jmp L7CC0
L7CEE:
    jmp L7A05
L7CF1:
    stx $22
    ldy #$00
L7CF5:
    lda #$04
    sta $23
    sty $26
L7CFB:
    ldx #$04
    lda #$20
    jsr LFFD2
L7D02:
    lda ($66),y
    jsr LEB84
    iny
    dex
    bne L7D02
    dec $23
    bne L7CFB
    lda #$20
    jsr LFFD2
    jsr LFFD2
    jsr LFFD2
    jsr LFFD2
    ldy $26
    ldx #$10
L7D21:
    txa
    and #$03
    bne L7D2B
    lda #$20
    jsr LFFD2
L7D2B:
    lda #$20
    jsr LFFD2
    lda ($66),y
    cmp #$20
    bmi L7D3A
    cmp #$80
    bmi L7D3C
L7D3A:
    lda #$2E
L7D3C:
    jsr LFFD2
    iny
    dex
    bne L7D21
    jsr LFFE4
    cmp #$03
    bne L7D4D
    jmp L7A05
L7D4D:
    dec $27
    bpl L7D68
    tya
    pha
    lda #$4B
    ldy #$7C
    jsr LEFE7
    pla
    tay
    jsr LEF59
    lda #$0D
    jsr LFFD2
    lda #$0A
    sta $27
L7D68:
    dec $22
    beq L7D7D
    lda #$20
    jsr LFFD2
    jsr LFFD2
    jsr LFFD2
    jsr LFFD2
    jmp L7CF5
L7D7D:
    rts
    !byte $FF
    !byte $FF
