L2020 = $2020
L2045 = $2045
L4420 = $4420
L454B = $454B
L4552 = $4552
L4944 = $4944
L4C41 = $4C41
L4E49 = $4E49
L4F43 = $4F43
L4F4C = $4F4C
L5257 = $5257
L5445 = $5445
L790D = $790D
L7A05 = $7A05
L7A47 = $7A47
L7AD1 = $7AD1
LEC74 = $EC74
LECE4 = $ECE4
LED3F = $ED3F
LEFE7 = $EFE7
LFFD2 = $FFD2

    *=$7c00

    jmp start

L7C03:
    brk
L7C04:
    ora     #$0D
    rol     ;a
    rol     ;a
    jsr     L4944
    !byte   $53
    !byte   $4B
    jsr     L4F43
    eor     $5250
    eor     $53
    !byte   $53
    eor     #$4F
    lsr     $2A20
    rol     ;a
    ora     L2020
    jsr     L454B
    eor     $4F42,y
    eor     ($52,x)
    !byte   $44
    jsr     L4F4C
    !byte   $43
    !byte   $4B
    eor     $44
    brk
    ora     $4F4D
    lsr     $49,x
    lsr     $2047
    lsr     $49
    jmp     L2045
    brk
    ora     $4320
    eor     ($4E,x)
    lsr     $544F
    jsr     L4552
    eor     ($44,x)
    and     $4544
    jmp     L5445
    eor     $20
    lsr     $49
    jmp     L2045
    brk
    ora     $4320
    eor     ($4E,x)
    lsr     $544F
    jsr     L5257
    eor     #$54
    eor     $20
    lsr     $5745
    jsr     L4E49
    !byte   $44
    eor     $58
    and     L4552
    lsr     $4F
    !byte   $52
    eor     $5441
    jsr     L4944
    !byte   $53
    !byte   $4B
    ora     L2020
    jsr     L2020
    jsr     L2020
    jsr     L4C41
    jmp     L4420
    eor     ($54,x)
    eor     ($20,x)
    eor     #$53
    jsr     L4F4C
    !byte   $53
    !byte   $54
    and     ($00,x)
    ora     $4320
    eor     ($4E,x)
    lsr     $544F
    jsr     L5257
    eor     #$54
    eor     $20
    lsr     $49
    jmp     L2045
    brk

start:
    lda #$05
    ldy #$7C
    jsr LEFE7
    jsr L7AD1
    sta $7F91
    lda #$60
    sta $7F9A
    ldx #$00
    stx $7F92
    inx
    stx $7F93
    lda #$08
    sta $7F96
    lda #$00
    sta $B7
    sta $4B
    sta $4D
    lda #$04
    sta $B8
    sta $4C
    sta $4E
    jsr LECE4
    beq L7CE8
    jmp L7A05

L7CE8:
    lda #$00
    sta $0408

L7CED:
    lda $4D
    clc
    adc #$10
    sta $4D
    bcc L7CF8
    inc $4E

L7CF8:
    lda $4B
    clc
    adc #$10
    sta $4B
    bcc L7D03
    inc $4C
L7D03:
    ldy #$00
    lda ($4B),y
    cmp #$FF
    bne L7D0E
    jmp L7E36
L7D0E:
    ldy #$05
    lda ($4B),y
    cmp #$FF
    beq L7CF8
    inc $0408
    ldy #$0C
    lda ($4B),y
    sta $7F98
    iny
    lda ($4B),y
    sta $7F99
    iny
    lda ($4B),y
    sta ($4D),y
    sta $7F9B
    iny
    lda ($4B),y
    sta ($4D),y
    sta $7F9C
    ldy #$0C
    lda L7C03
    sta ($4D),y
    iny
    lda L7C04
    sta ($4D),y
    ldy #$0B
L7D45:
    lda ($4B),y
    sta ($4D),y
    dey
    bpl L7D45
    lda $7F99
    cmp L7C04
    bne L7D8A
    lda $7F98
    cmp L7C03
    bne L7D8A
    lda $7F9B
    sta $7FAE
    lda $7F9C
    sta $7FAF
    jsr L790D
    lda L7C04
    clc
    adc $59
    cmp #$1D
    bmi L7D7B
    sec
    sbc #$1C
    inc L7C03
L7D7B:
    sta L7C04
    lda L7C03
    clc
    adc $58
    sta L7C03
L7D87:
    jmp L7CED
L7D8A:
    lda $7F9B
    ora $7F9C
    beq L7D87
    lda $7F9B
    sta $7F96
    sec
    sbc $7F9A
    sta $7F9B
    bcs L7DB0
    dec $7F9C
    bpl L7DB0
    lda #$00
    sta $7F9B
    sta $7F9C
    beq L7DB6
L7DB0:
    lda $7F9A
    sta $7F96
L7DB6:
    lda $7F96
    sta $7F97
    lda $7F98
    sta $7F92
    lda $7F99
    sta $7F93
    lda #$00
    sta $B7
    lda #$08
    sta $B8
    jsr LECE4
    beq L7DE2
    lda #$3E
    ldy #$7C
    jsr LEFE7
    jsr L7EA0
    jmp L7E65
L7DE2:
    jsr LEC74
    bcc L7DEA
    jmp L7E65
L7DEA:
    lda $7F92
    sta $7F98
    lda $7F93
    sta $7F99
    lda $7F97
    sta $7F96
    lda L7C03
    sta $7F92
    lda L7C04
    sta $7F93
    lda #$30
    ldy #$7C
    jsr LEFE7
    jsr L7EA0
    lda #$00
    sta $B7
    lda #$08
    sta $B8
    jsr LED3F
    bne L7E5B
    jsr LEC74
    bcc L7E27
    jmp L7E65
L7E27:
    lda $7F92
    sta L7C03
    lda $7F93
    sta L7C04
    jmp L7D8A
L7E36:
    lda L7C03
    sta $0409
    lda L7C04
    sta $040A
    lda $4D
    tay
    lda #$00
    sta $4D
    lda #$FF
L7E4B:
    sta ($4D),y
    iny
    bne L7E4B
    ldx $4E
    inx
    stx $4E
    cpx #$08
    bmi L7E4B
    bpl L7E65
L7E5B:
    lda #$9B
    ldy #$7C
    jsr LEFE7
    jsr L7EA0
L7E65:
    lda #$08
    sta $7F96
    lda #$00
    sta $B7
    lda #$04
    sta $B8
    ldy #$00
    sty $7F92
    iny
    sty $7F93
    jsr LED3F
    beq L7E8A
    lda #$59
    ldy #$7C
    jsr LEFE7
    jmp L7A05
L7E8A:
    lda #$04
    sta $2A
    sta $2B
    lda #$00
    sta $0400
    sta $0401
    sta $0402
    lda #$50
    jmp L7A47
L7EA0:
    ldy #$00
L7EA2:
    lda ($4D),y
    jsr LFFD2
    iny
    cpy #$06
    bmi L7EA2
    rts

    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
    !byte $FF
