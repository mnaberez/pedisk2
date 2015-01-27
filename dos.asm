
    *=$7800

    jmp $7A04
    jmp $7A37
    jmp $7B76
    jmp $7C6B
    jmp $7CA5
    jmp $7CE2
    jmp $79D0
    jmp $7D13
    lda $2A
    sec
    sbc $28
    sta $7FA6
    sta $58
    lda $2B
    sbc $29
    sta $59
    sta $7FA7
    lda $28
    sta $7FA8
    lda $29
    sta $7FA9
    jsr $7891
    lda $7F96
    sta $7FAE
    lda #$00
    sta $7FAF
    lda #$03
    sta $7FAA
    jsr $EE33
    tax
    bmi $7890
    bne $7857
    lda #$05
    jsr $EC96
    bne $7890
    lda #$00
    sta $7FAB
    jsr $78A2
    bne $7890
    lda $7FB5
    beq $786A
    lda #$06
    bne $7852
    lda $7FA8
    sta $B7
    lda $7FA9
    sta $B8
    lda $56
    sta $7F92
    lda $57
    sta $7F93
    lda $7FAE
    sta $7F96
    jsr $ED3F
    bne $7890
    lda #$00
    sta $E900
    lda #$00
    rts
    lda $58
    clc
    adc #$7F
    bcc $789A
    inc $59
    asl
    lda $59
    rol
    sta $7F96
    rts
    lda #$00
    sta $7FB5
    lda $56
    sta $7FAC
    lda $57
    sta $7FAD
    jsr $78F1
    lda $58
    cmp #$51
    bmi $78C0
    lda #$2B
    sta $7FB5
    rts
    ldy #$0F
    lda $7FA0,y
    sta ($22),y
    dey
    bpl $78C2
    lda $7F93
    cmp #$01
    beq $78E0
    jsr $ED3A
    bne $7890
    lda #$01
    sta $7F93
    jsr $ECDF
    bne $7890
    inc $7F08
    lda $58
    sta $7F09
    lda $59
    sta $7F0A
    jsr $ED3A
    rts
    jsr $790D
    lda $7FAD
    clc
    adc $59
    cmp #$1D
    bmi $7902
    sbc #$1C
    inc $58
    sta $59
    lda $7FAC
    clc
    adc $58
    sta $58
    rts
    lda $7FAE
    sec
    sbc #$01
    sta $5E
    lda $7FAF
    sbc #$00
    sta $5F
    lda #$1C
    sta $60
    lda #$00
    sta $61
    jsr $797B
    ldx $5E
    inx
    stx $59
    lda $62
    sta $58
    rts
    jsr $7948
    ldx #$10
    jsr $7953
    bcc $793E
    jsr $7958
    dex
    beq $7947
    jsr $7972
    jmp $7936
    rts
    lda #$00
    sta $62
    sta $63
    sta $64
    sta $65
    rts
    asl $5E
    rol $5F
    rts
    lda $60
    clc
    adc $62
    sta $62
    lda $61
    adc $63
    sta $63
    lda #$00
    adc $64
    sta $64
    lda #$00
    adc $65
    sta $65
    rts
    asl $62
    rol $63
    rol $64
    rol $65
    rts
    ldx #$00
    stx $62
    stx $63
    cpx $60
    bne $798E
    cpx $61
    bne $798E
    stx $5E
    stx $5F
    rts
    lda $61
    cmp $5F
    bcc $799E
    bne $79AB
    lda $60
    cmp $5E
    beq $799E
    bcs $79AB
    inx
    asl $60
    rol $61
    bcc $798E
    dex
    ror $61
    jmp $79B0
    dex
    bmi $798D
    lsr $61
    ror $60
    sec
    lda $5E
    sbc $60
    pha
    lda $5F
    sbc $61
    php
    rol $62
    rol $63
    plp
    bcs $79C8
    pla
    jmp $79AB
    sta $5F
    pla
    sta $5E
    jmp $79AB
    lda #$00
    sta $B7
    lda #$7A
    sta $B8
    ldx #$00
    stx $7F92
    inx
    stx $7F91
    lda #$16
    sta $7F93
    lda #$04
    sta $7F96
    jsr $ECE4
    bne $79F3
    jmp $7A00
    jmp $EB5E
    !byte $B3		; <invalid opcode>
    !byte $FA		; <invalid opcode>
    rti
    brk
    brk
    rti
    jsr $3400
    ora ($46,x)
    eor #$25
    brk
    jsr $7818
    jmp $EB5E
    ldx #$03
    lda #$7E
    sta $23
    lda #$E0
    sta $22
    ldy #$05
    lda ($22),y
    cmp $7FA0,y
    bne $7A2D
    dey
    bpl $7A16
    ldy #$11
    lda ($22),y
    cmp $7FB1
    bne $7A2D
    stx $7F8F
    rts
    dex
    bmi $7A29
    lda $22
    sec
    sbc #$20
    bne $7A12
    jsr $7A0A
    inx
    beq $7A41
    lda #$30
    bne $7A73
    ldx #$03
    ldy #$60
    lda $7E80,y
    cmp #$FF
    beq $7A5B
    dex
    bpl $7A53
    lda #$31
    bne $7A73
    tya
    sec
    sbc #$20
    tay
    jmp $7A45
    stx $7F8F
    jsr $EE33
    bpl $7A66
    jmp $EB5E
    pha
    jsr $0076
    cmp #$A2
    bne $7AD6
    pla
    bne $7A75
    lda #$32
    bne $7ADB
    lda #$64
    sta $7FAE
    lda #$80
    sta $7FA6
    sta $7FA8
    lda #$00
    sta $7FA7
    sta $7FA9
    sta $7FAA
    sta $7FAB
    sta $7FAF
    jsr $0070
    cmp #$C3
    bne $7AAC
    jsr $0070
    bcs $7AB3
    jsr $C873
    lda $11
    sta $7FAE
    lda $12
    sta $7FAF
    jsr $78A2
    bne $7B2C
    beq $7AE8
    jsr $CF6D
    lda $07
    bne $7AC2
    bit $08
    bmi $7AC6
    lda #$34
    bne $7ADB
    lda #$35
    bne $7ADB
    ldy #$00
    lda ($44),y
    sta $7FAF
    iny
    lda ($44),y
    sta $7FAE
    jmp $7AAC
    pla
    beq $7ADE
    lda #$32
    jmp $7B3D
    ldy #$0F
    lda ($22),y
    sta $7FA0,y
    dey
    bpl $7AE0
    lda #$00
    sta $7FB2
    sta $7FB3
    sta $7FB5
    lda $7FAC
    sta $7FBA
    ldx $7FAD
    dex
    stx $7FBB
    jsr $7B55
    ldy #$00
    lda $7FB3
    sta ($44),y
    iny
    lda $7FB2
    sta ($44),y
    jsr $7B59
    ldy #$00
    lda #$00
    sta ($44),y
    lda $7FB5
    iny
    sta ($44),y
    jsr $7B2F
    lda $7FA0,y
    sta $7E80,x
    dex
    dey
    bpl $7B22
    jmp $EB5E
    lda $7F8F
    asl
    asl
    asl
    asl
    asl
    adc #$1F
    tax
    ldy #$1F
    rts
    sta $7FB5
    ldy #$00
    lda ($77),y
    cmp #$00
    beq $7B52
    cmp #$3A
    beq $7B52
    jsr $0070
    jmp $7B44
    jmp $7B00
    lda #$49
    bne $7B5B
    lda #$43
    sta $7A01
    lda $77
    pha
    lda $78
    pha
    lda #$00
    sta $77
    lda #$7A
    sta $78
    jsr $CF6D
    pla
    sta $78
    pla
    sta $77
    rts
    jsr $7BA6
    ldy #$00
    lda ($77),y
    cmp #$80
    bne $7B91
    jsr $0070
    jsr $7C22
    lda #$FF
    sta $7F00
    jsr $ED3A
    bne $7BA3
    lda #$FF
    sta $7FA0
    sta $7FB5
    lda #$00
    sta $E900
    lda #$FF
    jmp $7B00
    jmp $EB5E
    jsr $7A0A
    inx
    bne $7BB1
    lda #$07
    jmp $7B3D
    jsr $7B2F
    lda $7E80,x
    sta $7FA0,y
    dex
    dey
    bpl $7BB4
    lda #$00
    sta $7FB5
    rts
    ldy #$00
    lda ($77),y
    cmp #$B9
    bne $7C22
    jsr $0070
    jsr $7B55
    ldy #$00
    lda ($44),y
    sta $7FB3
    iny
    lda ($44),y
    sta $7FB2
    ora $7FB3
    bne $7BE9
    lda #$08
    jmp $7B3D
    lda $7FB2
    sec
    sbc #$01
    sta $5E
    lda $7FB3
    sbc #$00
    sta $5F
    lda #$1C
    sta $60
    lda #$00
    sta $61
    jsr $797B
    lda $5E
    clc
    adc $7FAD
    pha
    lda $62
    adc $7FAC
    sta $7FBA
    pla
    cmp #$1D
    bcc $7C1C
    inc $7FBA
    sbc #$1C
    sta $7FBB
    jmp $7C3C
    inc $7FB2
    bne $7C2A
    inc $7FB3
    inc $7FBB
    lda $7FBB
    cmp #$1D
    bcc $7C3C
    inc $7FBA
    lda #$01
    sta $7FBB
    lda $7FBA
    sta $7F92
    cmp $7FBC
    bcc $7C56
    bne $7C51
    lda $7FBB
    cmp $7FBD
    bcc $7C56
    lda #$08
    jmp $7B3D
    lda $7FBB
    sta $7F93
    lda #$00
    sta $B7
    lda #$7F
    sta $B8
    lda $7FB1
    sta $7F91
    rts
    jsr $7BA6
    jsr $7BC4
    jsr $ECDF
    bne $7CA2
    jsr $CF6D
    bit $07
    bmi $7C82
    lda #$09
    jmp $7B3D
    lda $7F00
    cmp #$FF
    beq $7C7F
    cmp #$80
    bcc $7C91
    lda #$0A
    bne $7C7F
    ldy #$00
    sta ($44),y
    iny
    lda #$01
    sta ($44),y
    iny
    lda #$7F
    sta ($44),y
    jmp $7B00
    jmp $EB5E
    jsr $7BA6
    jsr $7BC4
    jsr $CF6D
    bit $07
    bmi $7CB7
    lda #$09
    jmp $7B3D
    ldy #$00
    lda ($44),y
    cmp #$80
    bcc $7CC3
    lda #$0A
    bne $7CB4
    sta $7F00
    iny
    lda ($44),y
    sta $22
    iny
    lda ($44),y
    sta $23
    ldy #$7E
    lda ($22),y
    sta $7F01,y
    dey
    bpl $7CD2
    jsr $ED3A
    bne $7CA2
    jmp $7B00
    jsr $EE9E
    txa
    bne $7D10
    lda #$0C
    sta $77
    lda #$7D
    sta $78
    ldx #$1F
    sei
    lda $7FE0,x
    sta $01E0,x
    dex
    bpl $7CF3
    ldx $7F8B
    txs
    cli
    ldy $7F8A
    ldx $7F89
    lda #$8A
    jmp $EA44
    txa
    brk
    brk
    brk
    jmp $EB5E
    lda #$28
    ldy #$7D
    jsr $EFE7
    jsr $EF59
    cmp #$30
    bmi $7D13
    cmp #$34
    bpl $7D13
    jmp $7D83
    ora $440D
    eor $56
    eor #$43
    eor $3F
    brk
    ora $4F4D
    !byte $52		; <invalid opcode>
    eor $2E
    rol $9300
    !byte $44		; <invalid opcode>
    eor #$53
    !byte $4B		; <invalid opcode>
    lsr $4D41
    eor $3D
    jsr $0D00
    ora $414E
    eor $2045
    jsr $5954
    bvc $7D97
    jsr $5254
    !byte $4B		; <invalid opcode>
    jsr $4353
    !byte $54		; <invalid opcode>
    !byte $52		; <invalid opcode>
    jsr $5323
    !byte $43		; <invalid opcode>
    !byte $54		; <invalid opcode>
    !byte $52		; <invalid opcode>
    !byte $53		; <invalid opcode>
    brk
    !byte $53		; <invalid opcode>
    eor $51
    brk
    eor #$4E
    !byte $44		; <invalid opcode>
    brk
    eor #$53
    eor $4200
    eor ($53,x)
    brk
    eor ($53,x)
    eor $4C00
    !byte $44		; <invalid opcode>
    jsr $5400
    cli
    !byte $54		; <invalid opcode>
    brk
    !byte $4F		; <invalid opcode>
    !byte $42		; <invalid opcode>
    lsr
    brk
    and #$03
    tax
    sec
    rol
    dex
    bpl $7D87
    sta $7F91
    ldx #$00
    stx $7F92
    inx
    stx $7F93
    lda #$00
    sta $B7
    sta $22
    lda #$7F
    sta $B8
    sta $23
    jsr $ECDF
    beq $7DAB
    jmp $EB5E
    lda #$3A
    ldy #$7D
    jsr $EFE7
    ldy #$00
    ldx #$08
    lda ($22),y
    jsr $FFD2
    iny
    dex
    bne $7DB6
    lda #$46
    ldy #$7D
    jsr $EFE7
    lda #$12
    sta $27
    lda #$0D
    jsr $FFD2
    lda $22
    clc
    adc #$10
    bpl $7DE3
    inc $7F93
    jsr $ECDF
    beq $7DE1
    jmp $EB5E
    lda #$00
    sta $22
    ldy #$00
    lda ($22),y
    cmp #$FF
    bne $7DF0
    jmp $7E56
    ldy #$05
    lda ($22),y
    cmp #$FF
    beq $7DCF
    lda #$0D
    jsr $FFD2
    ldy #$00
    lda ($22),y
    jsr $FFD2
    iny
    cpy #$06
    bmi $7DFF
    jsr $EB7A
    ldy #$0A
    lda ($22),y
    asl
    asl
    clc
    adc #$63
    ldy #$7D
    jsr $EFE7
    jsr $EB7A
    ldy #$0C
    lda ($22),y
    jsr $EB84
    jsr $EB7A
    ldy #$0D
    lda ($22),y
    jsr $EB7F
    jsr $EB7A
    jsr $EB7A
    ldy #$0F
    lda ($22),y
    jsr $EB7F
    ldy #$0E
    lda ($22),y
    jsr $EB84
    dec $27
    bmi $7E49
    jmp $7DCF
    lda #$32
    ldy #$7D
    jsr $EFE7
    jsr $EF59
    jmp $7DC6
    lda #$0D
    jsr $FFD2
    jsr $EB0B
    jsr $0070
    jmp $EB5E
    !byte $CF		; <invalid opcode>
    sbc $FFF4,x
    cpy $8C
    !byte $04		; <invalid opcode>
    sty $1804
    txa
    bcc $7E6E
    sbc $FFFF,x
    !byte $FF		; <invalid opcode>
    !byte $1C		; <invalid opcode>
    brk
    brk
    brk
    brk
    brk
    brk
    brk
    brk
    brk
    brk
