L000D = $0D
L2045 = $2045
L4944 = $4944
L4949 = $4949
L4F44 = $4F44
L4F46 = $4F46
L5254 = $5254
L5928 = $5928
L7A05 = $7A05
L7AD1 = $7AD1
LCF83 = $CF83
LEBA0 = $EBA0
LEC0D = $EC0D
LECCC = $ECCC
LED3A = $ED3A
LEF7B = $EF7B
LEFE7 = $EFE7
LFFD2 = $FFD2

    *=$7c00

    jmp     start

    ora     $500D
    eor     $44
    eor     #$53
    !byte   $4B
    jsr     L4949
    jsr     L4944
    !byte   $53
    !byte   $4B
    jsr     L4F46
    !byte   $52
    eor     $5441
    ora     $2020
    jsr     L4F44
    eor     $42,x
    jmp     L2045
    !byte   $44
    eor     $4E
    !byte   $53
    eor     #$54
    eor     L000D,y
    ora     $5553
    !byte   $52
    eor     $3F
    jsr     L5928
    and     $4559
    !byte   $53
    and     #$00
    ora     $414E
    eor     $3F45
    jsr     L000D
    ora     $4946
    lsr     $5349
    pha
    eor     $44
    and     ($00,x)
    ora     $5250
    !byte   $4F
    !byte   $54
    eor     $43
    !byte   $54
    eor     $44
    jsr     L4944
    !byte   $53
    !byte   $4B
    and     ($21,x)
    ora     $2000
    eor     $52
    !byte   $52
    !byte   $4F
    !byte   $52
    and     ($00,x)
    ora     L4F46
    !byte   $52
    eor     $5441
    jsr     L5254
    eor     ($43,x)
    !byte   $4B
    !byte   $20
    brk

start:
    lda #$03
    ldy #$7C
    jsr LEFE7
    jsr L7AD1
    sta $7F91
    lda #$2E
    ldy #$7C
    jsr LEFE7
    jsr LEF7B
    cmp #$59
    bne L7CB5
    jsr LEBA0
    bne L7CB5
    lda #$03
    jsr LEC0D
    lda $E980
    and #$40
    bne L7CB8
    lda $E980
    and #$9D
    cmp #$04
    beq L7CC5
    lda #$F0
    jmp L7D6C
L7CB5:
    jmp L7A05
L7CB8:
    nop
    lda #$51
    ldy #$7C
    jsr LEFE7
    lda #$F3
    jmp L7D6C
L7CC5:
    ldx #$00
    stx $7F92
    inx
    stx $7F93
    stx $E982
L7CD1:
    jsr L7D7D
    lda #$6C
    ldy #$7C
    jsr LEFE7
    lda #$00
    ldx $7F92
    jsr LCF83
    inc $7F92
    lda #$28
    cmp $7F92
    bpl L7CD1
    lda #$00
    sta $B7
    lda #$7F
    sta $B8
    ldy #$7F
    lda #$FF
L7CF9:
    sta ($B7),y
    dey
    bpl L7CF9
    ldx #$00
    stx $7F92
    inx
    inx
    stx $7F93
L7D08:
    jsr LED3A
L7D0B:
    bne L7CB5
    lda $7F94
    beq L7D17
    lda #$F1
    jmp L7D6C
L7D17:
    ldx $7F93
    inx
    stx $7F93
    cpx #$09
    bmi L7D08
    lda #$01
    sta $7F93
    lda #$3D
    ldy #$7C
    jsr LEFE7
    ldx #$00
L7D30:
    stx $26
    jsr LEF7B
    ldx $26
    sta $7F00,x
    inx
    cpx #$08
    bcc L7D30
    lda #$00
    sta $7F08
    sta $7F09
    lda #$09
    sta $7F0A
    lda #$20
    sta $7F0B
    sta $7F0C
    sta $7F0D
    sta $7F0E
    sta $7F0F
    jsr LED3A
    bne L7D0B
    lda #$46
    ldy #$7C
    jsr LEFE7
    jmp L7A05
L7D6C:
    pha
    lda L000D
    jsr LFFD2
    pla
    lda #$64
    ldy #$7C
    jsr LEFE7
    jmp L7A05
L7D7D:
    lda $7F92
    sta $E983
    lda #$13
    jsr LEC0D
    lda #$00
    sta $7F90
    ldy #$01
    sei
    lda #$F4
    sta $E980
    ldx #$06
L7D97:
    dex
    bne L7D97
    ldx #$10
L7D9C:
    lda #$E6
L7D9E:
    bit $E980
    beq L7D9E
    lda #$4E
    sta $E983
    dex
    bne L7D9C
    ldx #$08
L7DAD:
    lda #$E6
L7DAF:
    bit $E980
    beq L7DAF
    lda #$00
    sta $E983
    dex
    bne L7DAD
    ldx #$03
L7DBE:
    lda #$E6
L7DC0:
    bit $E980
    beq L7DC0
    lda #$F6
    sta $E983
    dex
    bne L7DBE
    lda #$E6
L7DCF:
    bit $E980
    beq L7DCF
    lda #$FC
    sta $E983
    ldx #$20
L7DDB:
    lda #$E6
L7DDD:
    bit $E980
    beq L7DDD
    lda #$4E
    sta $E983
    dex
    bne L7DDB
L7DEA:
    ldx #$08
L7DEC:
    lda #$E6
L7DEE:
    bit $E980
    beq L7DEE
    lda #$00
    sta $E983
    dex
    bne L7DEC
    ldx #$03
L7DFD:
    lda #$E6
L7DFF:
    bit $E980
    beq L7DFF
    lda #$F5
    sta $E983
    dex
    bne L7DFD
    lda #$E6
L7E0E:
    bit $E980
    beq L7E0E
    lda #$FE
    sta $E983
    lda #$E6
L7E1A:
    bit $E980
    beq L7E1A
    lda $7F92
    sta $E983
    lda #$E6
L7E27:
    bit $E980
    beq L7E27
    lda #$00
    sta $E983
    lda #$E6
L7E33:
    bit $E980
    beq L7E33
    sty $E983
    iny
    lda #$E6
L7E3E:
    bit $E980
    beq L7E3E
    lda #$00
    sta $E983
    lda #$E6
L7E4A:
    bit $E980
    beq L7E4A
    lda #$F7
    sta $E983
    ldx #$16
L7E56:
    lda #$E6
L7E58:
    bit $E980
    beq L7E58
    lda #$4E
    sta $E983
    dex
    bne L7E56
    ldx #$0C
L7E67:
    lda #$E6
L7E69:
    bit $E980
    beq L7E69
    lda #$00
    sta $E983
    dex
    bne L7E67
    ldx #$03
L7E78:
    lda #$E6
L7E7A:
    bit $E980
    beq L7E7A
    lda #$F5
    sta $E983
    dex
    bne L7E78
    lda #$E6
L7E89:
    bit $E980
    beq L7E89
    lda #$FB
    sta $E983
    ldx #$80
L7E95:
    lda #$E6
L7E97:
    bit $E980
    beq L7E97
    lda #$E5
    sta $E983
    dex
    bne L7E95
    lda #$E6
L7EA6:
    bit $E980
    beq L7EA6
    lda #$F7
    sta $E983
    ldx #$1C
L7EB2:
    lda #$E6
L7EB4:
    bit $E980
    beq L7EB4
    lda #$4E
    sta $E983
    dex
    bne L7EB2
    lda #$E6
L7EC3:
    bit $E980
    bne L7EC3
    lda #$4E
    sta $E983
    cpy #$1D
    bpl L7ED4
    jmp L7DEA
L7ED4:
    lda #$01
L7ED6:
    bit $E980
    bne L7ED6
    cli
    jsr LECCC
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
