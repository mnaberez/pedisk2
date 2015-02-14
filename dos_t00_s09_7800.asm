L0070 = $70
L0076 = $76
L0D00 = $0D00
L2045 = $2045
L3400 = $3400
L3F45 = $3F45
L4153 = $4153
L4353 = $4353
L4544 = $4544
L5254 = $5254
L5323 = $5323
L5400 = $5400
L5445 = $5445
L5954 = $5954
L8091 = $8091
LB8F6 = $B8F6
LC12B = $C12B
LEA44 = $EA44
LEB0B = $EB0B
LEB5E = $EB5E
LEB7A = $EB7A
LEB7F = $EB7F
LEB84 = $EB84
LEC0D = $EC0D
LEC96 = $EC96
LECDF = $ECDF
LECE4 = $ECE4
LED3A = $ED3A
LED3F = $ED3F
LEE33 = $EE33
LEE9E = $EE9E
LEEE6 = $EEE6
LEF08 = $EF08
LEF59 = $EF59
LEF83 = $EF83
LEFE7 = $EFE7
LFFCF = $FFCF
LFFD2 = $FFD2

        *=$7800

        jmp     L7A04
        jmp     L7A37
        jmp     L7B76
        jmp     L7C6B
        jmp     L7CA5
        jmp     L7CE2
        jmp     L79D0
        jmp     L7D13
L7818:  lda     $2A
        sec
        sbc     $28
        sta     L7FA6
        sta     $58
        lda     $2B
        sbc     $29
        sta     $59
        sta     L7FA7
        lda     $28
        sta     L7FA8
        lda     $29
        sta     L7FA9
        jsr     L7891
        lda     L7F96
        sta     L7FAE
        lda     #$00
        sta     L7FAF
        lda     #$03
        sta     L7FAA
        jsr     LEE33
        tax
        bmi     L7890
        bne     L7857
        lda     #$05
L7852:  jsr     LEC96
        bne     L7890
L7857:  lda     #$00
        sta     L7FAB
        jsr     L78A2
        bne     L7890
        lda     L7FB5
        beq     L786A
        lda     #$06
        bne     L7852
L786A:  lda     L7FA8
        sta     $B7
        lda     L7FA9
        sta     $B8
        lda     $56
        sta     L7F92
        lda     $57
        sta     L7F93
        lda     L7FAE
        sta     L7F96
        jsr     LED3F
        bne     L7890
        lda     #$00
        sta     $E900
        lda     #$00
L7890:  rts
L7891:  lda     $58
        clc
        adc     #$7F
        bcc     L789A
        inc     $59
L789A:  asl     ;a
        lda     $59
        rol     ;a
        sta     L7F96
        rts
L78A2:  lda     #$00
        sta     L7FB5
        lda     $56
        sta     L7FAC
        lda     $57
        sta     L7FAD
        jsr     L78F1
        lda     $58
        cmp     #$51
        bmi     L78C0
        lda     #$2B
        sta     L7FB5
        rts
L78C0:  ldy     #$0F
L78C2:  lda     L7FA0,y
        sta     ($22),y
        dey
        bpl     L78C2
        lda     L7F93
        cmp     #$01
        beq     L78E0
        jsr     LED3A
        bne     L7890
        lda     #$01
        sta     L7F93
        jsr     LECDF
        bne     L7890
L78E0:  inc     L7F08
        lda     $58
        sta     L7F09
        lda     $59
        sta     L7F0A
        jsr     LED3A
        rts
L78F1:  jsr     L790D
        lda     L7FAD
        clc
        adc     $59
        cmp     #$1D
        bmi     L7902
        sbc     #$1C
        inc     $58
L7902:  sta     $59
        lda     L7FAC
        clc
        adc     $58
        sta     $58
        rts
L790D:  lda     L7FAE
        sec
        sbc     #$01
        sta     $5E
        lda     L7FAF
        sbc     #$00
        sta     $5F
        lda     #$1C
        sta     $60
        lda     #$00
        sta     $61
        jsr     L797B
        ldx     $5E
        inx
        stx     $59
        lda     $62
        sta     $58
        rts
        jsr     L7948
        ldx     #$10
L7936:  jsr     L7953
        bcc     L793E
        jsr     L7958
L793E:  dex
        beq     L7947
        jsr     L7972
        jmp     L7936
L7947:  rts
L7948:  lda     #$00
        sta     $62
        sta     $63
        sta     $64
        sta     $65
        rts
L7953:  asl     $5E
        rol     $5F
        rts
L7958:  lda     $60
        clc
        adc     $62
        sta     $62
        lda     $61
        adc     $63
        sta     $63
        lda     #$00
        adc     $64
        sta     $64
        lda     #$00
        adc     $65
        sta     $65
        rts
L7972:  asl     $62
        rol     $63
        rol     $64
        rol     $65
        rts
L797B:  ldx     #$00
        stx     $62
        stx     $63
        cpx     $60
        bne     L798E
        cpx     $61
        bne     L798E
        stx     $5E
        stx     $5F
L798D:  rts
L798E:  lda     $61
        cmp     $5F
        bcc     L799E
        bne     L79AB
        lda     $60
        cmp     $5E
        beq     L799E
        bcs     L79AB
L799E:  inx
        asl     $60
        rol     $61
        bcc     L798E
        dex
        ror     $61
        jmp     L79B0
L79AB:  dex
        bmi     L798D
        lsr     $61
L79B0:  ror     $60
        sec
        lda     $5E
        sbc     $60
        pha
        lda     $5F
        sbc     $61
        php
        rol     $62
        rol     $63
        plp
        bcs     L79C8
        pla
        jmp     L79AB
L79C8:  sta     $5F
        pla
        sta     $5E
        jmp     L79AB
L79D0:  lda     #$00
        sta     $B7
        lda     #$7A
        sta     $B8
        ldx     #$00
        stx     L7F92
        inx
        stx     L7F91
        lda     #$16
        sta     L7F93
        lda     #$04
        sta     L7F96
        jsr     LECE4
        bne     L79F3
        jmp     L7A00
L79F3:  jmp     LEB5E
        !byte   $B3
        !byte   $FA
        rti
        brk
        brk
        rti
        jsr     L3400
        !byte   $01
L7A00:  !byte   $46
L7A01:  eor     #$25
        brk
L7A04:  !byte   $20
L7A05:  clc
        sei
        jmp     LEB5E
L7A0A:  ldx     #$03
        lda     #$7E
        sta     $23
        lda     #$E0
L7A12:  sta     $22
        ldy     #$05
L7A16:  lda     ($22),y
        cmp     L7FA0,y
        bne     L7A2D
        dey
        bpl     L7A16
        ldy     #$11
        lda     ($22),y
        !byte   $CD
L7A25:  lda     ($7F),y
        bne     L7A2D
L7A29:  stx     L7F8F
        rts
L7A2D:  dex
        bmi     L7A29
        lda     $22
        sec
        sbc     #$20
        bne     L7A12
L7A37:  jsr     L7A0A
        inx
        beq     L7A41
        lda     #$30
        bne     L7A73
L7A41:  ldx     #$03
        ldy     #$60
L7A45:  lda     L7E80,y
        cmp     #$FF
        beq     L7A5B
        dex
        bpl     L7A53
        lda     #$31
        bne     L7A73
L7A53:  tya
        sec
        sbc     #$20
        tay
        jmp     L7A45
L7A5B:  stx     L7F8F
        jsr     LEE33
        bpl     L7A66
        jmp     LEB5E
L7A66:  pha
        jsr     L0076
        cmp     #$A2
        bne     L7AD6
        pla
        bne     L7A75
        lda     #$32
L7A73:  bne     L7ADB
L7A75:  lda     #$64
        sta     L7FAE
        lda     #$80
        sta     L7FA6
        sta     L7FA8
        lda     #$00
        sta     L7FA7
        !byte   $8D
        !byte   $A9
L7A89:  !byte   $7F
        sta     L7FAA
        sta     L7FAB
        sta     L7FAF
        jsr     L0070
        cmp     #$C3
        bne     L7AAC
        jsr     L0070
        bcs     L7AB3
        jsr     LB8F6
        !byte   $A5
L7AA3:  ora     ($8D),y
        ldx     $A57F
        !byte   $12
        sta     L7FAF
L7AAC:  jsr     L78A2
        bne     L7B2C
        beq     L7AE8
L7AB3:  jsr     LC12B
        lda     $07
        bne     L7AC2
        bit     $08
        bmi     L7AC6
        lda     #$34
        bne     L7ADB
L7AC2:  lda     #$35
        bne     L7ADB
L7AC6:  ldy     #$00
        lda     ($44),y
        sta     L7FAF
        iny
        lda     ($44),y
        sta     L7FAE
        jmp     L7AAC
L7AD6:  pla
        beq     L7ADE
        lda     #$32
L7ADB:  jmp     L7B3D
L7ADE:  ldy     #$0F
L7AE0:  lda     ($22),y
        sta     L7FA0,y
        dey
        bpl     L7AE0
L7AE8:  lda     #$00
L7AEA:  sta     L7FB2
        sta     L7FB3
L7AF0:  sta     L7FB5
        lda     L7FAC
        sta     L7FBA
        ldx     L7FAD
        dex
        stx     L7FBB
L7B00:  jsr     L7B55
        ldy     #$00
        lda     L7FB3
        sta     ($44),y
        iny
        lda     L7FB2
        sta     ($44),y
        !byte   $20
        !byte   $59
L7B12:  !byte   $7B
        ldy     #$00
        lda     #$00
        sta     ($44),y
        !byte   $AD
L7B1A:  lda     $7F,x
        iny
        sta     ($44),y
        jsr     L7B2F
L7B22:  lda     L7FA0,y
        sta     L7E80,x
        dex
        dey
        !byte   $10
L7B2B:  !byte   $F6
L7B2C:  jmp     LEB5E
L7B2F:  lda     L7F8F
        asl     ;a
        asl     ;a
        asl     ;a
        asl     ;a
        asl     ;a
        adc     #$1F
        tax
        ldy     #$1F
        rts
L7B3D:  sta     L7FB5
        ldy     #$00
        lda     ($77),y
L7B44:  cmp     #$00
        beq     L7B52
        cmp     #$3A
        beq     L7B52
        jsr     L0070
        jmp     L7B44
L7B52:  jmp     L7B00
L7B55:  lda     #$49
        bne     L7B5B
L7B59:  lda     #$43
L7B5B:  sta     L7A01
        lda     $77
        pha
        lda     $78
        pha
        lda     #$00
        sta     $77
        lda     #$7A
        sta     $78
        jsr     LC12B
        pla
        sta     $78
        pla
        sta     $77
        rts
L7B76:  jsr     L7BA6
        ldy     #$00
        lda     ($77),y
        cmp     #$80
        bne     L7B91
        jsr     L0070
        jsr     L7C22
        lda     #$FF
        sta     L7F00
        jsr     LED3A
        bne     L7BA3
L7B91:  lda     #$FF
L7B93:  sta     L7FA0
        sta     L7FB5
        lda     #$00
        sta     $E900
        lda     #$FF
        jmp     L7B00
L7BA3:  jmp     LEB5E
L7BA6:  jsr     L7A0A
        inx
        bne     L7BB1
        lda     #$07
        jmp     L7B3D
L7BB1:  jsr     L7B2F
L7BB4:  lda     L7E80,x
        sta     L7FA0,y
        dex
        dey
        bpl     L7BB4
        lda     #$00
        sta     L7FB5
        rts
L7BC4:  ldy     #$00
        lda     ($77),y
        cmp     #$B9
        bne     L7C22
        jsr     L0070
        jsr     L7B55
        ldy     #$00
        lda     ($44),y
        sta     L7FB3
        iny
        lda     ($44),y
        sta     L7FB2
        ora     L7FB3
        bne     L7BE9
        lda     #$08
        jmp     L7B3D
L7BE9:  lda     L7FB2
        sec
        sbc     #$01
        sta     $5E
        lda     L7FB3
        sbc     #$00
        sta     $5F
        lda     #$1C
        sta     $60
        lda     #$00
        sta     $61
L7C00:  jsr     L797B
        lda     $5E
        clc
        adc     L7FAD
        pha
        lda     $62
        adc     L7FAC
        sta     L7FBA
        pla
        cmp     #$1D
        bcc     L7C1C
        inc     L7FBA
        sbc     #$1C
L7C1C:  sta     L7FBB
        jmp     L7C3C
L7C22:  inc     L7FB2
        bne     L7C2A
        inc     L7FB3
L7C2A:  inc     L7FBB
        lda     L7FBB
        cmp     #$1D
        bcc     L7C3C
        inc     L7FBA
        lda     #$01
        sta     L7FBB
L7C3C:  lda     L7FBA
        sta     L7F92
        cmp     L7FBC
        bcc     L7C56
        bne     L7C51
        lda     L7FBB
        cmp     L7FBD
        bcc     L7C56
L7C51:  lda     #$08
        jmp     L7B3D
L7C56:  lda     L7FBB
        sta     L7F93
        lda     #$00
        sta     $B7
        lda     #$7F
        sta     $B8
        lda     L7FB1
        sta     L7F91
        rts
L7C6B:  jsr     L7BA6
        jsr     L7BC4
        jsr     LECDF
        bne     L7CA2
        jsr     LC12B
        bit     $07
        bmi     L7C82
        lda     #$09
L7C7F:  jmp     L7B3D
L7C82:  lda     L7F00
        cmp     #$FF
        beq     L7C7F
        cmp     #$80
        bcc     L7C91
        lda     #$0A
        bne     L7C7F
L7C91:  ldy     #$00
        sta     ($44),y
        iny
        lda     #$01
        sta     ($44),y
        iny
        lda     #$7F
        sta     ($44),y
        jmp     L7B00
L7CA2:  jmp     LEB5E
L7CA5:  jsr     L7BA6
        jsr     L7BC4
        jsr     LC12B
        bit     $07
        bmi     L7CB7
        lda     #$09
L7CB4:  jmp     L7B3D
L7CB7:  ldy     #$00
        lda     ($44),y
        cmp     #$80
        bcc     L7CC3
        lda     #$0A
        bne     L7CB4
L7CC3:  sta     L7F00
        iny
        lda     ($44),y
        sta     $22
        iny
        lda     ($44),y
        sta     $23
        ldy     #$7E
L7CD2:  lda     ($22),y
        sta     L7F01,y
        dey
        bpl     L7CD2
        jsr     LED3A
        bne     L7CA2
        jmp     L7B00
L7CE2:  jsr     LEE9E
        txa
        bne     L7D10
        lda     #$0C
        sta     $77
        lda     #$7D
        sta     $78
        ldx     #$1F
        sei
L7CF3:  lda     L7FE0,x
        sta     $01E0,x
        dex
        bpl     L7CF3
        ldx     L7F8B
        txs
        cli
        ldy     L7F8A
        ldx     L7F89
        lda     #$8A
        jmp     LEA44
        txa
        brk
        brk
        brk
L7D10:  jmp     LEB5E
L7D13:  lda     #$28
        ldy     #$7D
        jsr     LEFE7
        jsr     LEF59
        cmp     #$30
        bmi     L7D13
        cmp     #$34
        bpl     L7D13
        jmp     L7D83
        ora     $440D
        eor     $56
        eor     #$43
        eor     $3F
        brk
        ora     $4F4D
        !byte   $52
        eor     $2E
        rol     $9300
        !byte   $44
        eor     #$53
        !byte   $4B
        lsr     $4D41
        eor     $3D
        jsr     L0D00
        ora     $414E
        eor     L2045
        jsr     L5954
        bvc     L7D97
        jsr     L5254
        !byte   $4B
        jsr     L4353
        !byte   $54
        !byte   $52
        jsr     L5323
        !byte   $43
        !byte   $54
        !byte   $52
        !byte   $53
        brk
        !byte   $53
        eor     $51
        brk
        eor     #$4E
        !byte   $44
        brk
        eor     #$53
        eor     $4200
        eor     ($53,x)
        brk
        eor     ($53,x)
        eor     $4C00
        !byte   $44
        jsr     L5400
        cli
        !byte   $54
        brk
        !byte   $4F
        !byte   $42
        lsr     ;a
        brk
L7D83:  and     #$03
        tax
        sec
L7D87:  rol     ;a
        dex
        bpl     L7D87
        sta     L7F91
        ldx     #$00
        stx     L7F92
        inx
        stx     L7F93
L7D97:  lda     #$00
        sta     $B7
        sta     $22
        lda     #$7F
        sta     $B8
        sta     $23
        jsr     LECDF
        beq     L7DAB
        jmp     LEB5E
L7DAB:  lda     #$3A
        ldy     #$7D
        jsr     LEFE7
        ldy     #$00
        ldx     #$08
L7DB6:  lda     ($22),y
        jsr     LFFD2
        iny
        dex
        bne     L7DB6
        lda     #$46
        ldy     #$7D
        jsr     LEFE7
L7DC6:  lda     #$12
        sta     $27
        lda     #$0D
        jsr     LFFD2
L7DCF:  lda     $22
        clc
        adc     #$10
        bpl     L7DE3
        inc     L7F93
        jsr     LECDF
        beq     L7DE1
        jmp     LEB5E
L7DE1:  lda     #$00
L7DE3:  sta     $22
        ldy     #$00
        lda     ($22),y
        cmp     #$FF
        bne     L7DF0
        jmp     L7E56
L7DF0:  ldy     #$05
        lda     ($22),y
        cmp     #$FF
        beq     L7DCF
        lda     #$0D
        jsr     LFFD2
        ldy     #$00
L7DFF:  lda     ($22),y
        jsr     LFFD2
        iny
        cpy     #$06
        bmi     L7DFF
        jsr     LEB7A
        ldy     #$0A
        lda     ($22),y
        asl     ;a
        asl     ;a
        clc
        adc     #$63
        ldy     #$7D
        jsr     LEFE7
        jsr     LEB7A
        ldy     #$0C
        lda     ($22),y
        jsr     LEB84
        jsr     LEB7A
        ldy     #$0D
        lda     ($22),y
        jsr     LEB7F
        jsr     LEB7A
        jsr     LEB7A
        ldy     #$0F
        lda     ($22),y
        jsr     LEB7F
        ldy     #$0E
        lda     ($22),y
        jsr     LEB84
        dec     $27
        bmi     L7E49
        jmp     L7DCF
L7E49:  lda     #$32
        ldy     #$7D
        jsr     LEFE7
        jsr     LEF59
        jmp     L7DC6
L7E56:  lda     #$0D
        jsr     LFFD2
        jsr     LEB0B
        jsr     L0070
        jmp     LEB5E
        !byte   $8F
        sbc     $FFF4,x
        cpy     $8C
        !byte   $04
        sty     $1804
L7E6E:  txa
        bcc     L7E6E
        sbc     $FFFF,x
        sbc     $FFFF
        !byte   $FF
        php
        dex
        !byte   $1C
        !byte   $12
        !byte   $B2
        and     $B506,y
L7E80:  lda     #$93
        jsr     LFFD2
L7E85:  ldx     #$FF
        txs
        lda     #$00
        sta     $E900
        lda     #$0D
        jsr     LFFD2
        jsr     LFFD2
        lda     #$3E
        jsr     LFFD2
        jsr     LEF59
        cmp     #$41
        bcc     L7EA5
        cmp     #$5B
        bcc     L7EAB
L7EA5:  jsr     LEEE6
        jmp     L7A05
L7EAB:  cmp     #$4C
        beq     L7ED3
        cmp     #$53
        beq     L7ED6
        cmp     #$4D
        beq     L7ED9
        cmp     #$52
        beq     L7EFD
        cmp     #$47
        beq     L7EDC
        cmp     #$58
        beq     L7EDF
        cmp     #$4B
        beq     L7ED0
        jsr     L7A89
        txa
        bne     L7E85
        jmp     L7C00
L7ED0:  jmp     L7B93
L7ED3:  jmp     L7AEA
L7ED6:  jmp     L7B2B
L7ED9:  jmp     LEF83
L7EDC:  jmp     L7B1A
L7EDF:  jmp     L7B12
        ora     $4946
        jmp     L3F45
        jsr     L0D00
        !byte   $44
        eor     $56
        eor     #$43
        eor     $3F
        jsr     L0D00
        eor     $4E
        !byte   $54
        !byte   $52
        eor     $203F,y
        brk
L7EFD:  jsr     L0070
L7F00:  !byte   $A9
L7F01:  !byte   $EB
        pha
        lda     #$5D
        pha
        !byte   $4C
        !byte   $D1
L7F08:  nop
L7F09:  pha
L7F0A:  lda     #$2A
        ldy     #$00
L7F0E:  sta     L7FA0,y
        iny
        cpy     #$05
        bmi     L7F0E
        pla
        sta     L7FA5
        ldy     #$01
        sty     L7FB1
        jsr     LEE9E
        rts
        lda     #$62
        ldy     #$7A
        jsr     LEFE7
        ldy     #$00
L7F2C:  jsr     LFFCF
        cmp     #$3A
        beq     L7F3B
        sta     L7FA0,y
        iny
        cpy     #$07
        bmi     L7F2C
L7F3B:  lda     #$20
L7F3D:  cpy     #$06
        bpl     L7F47
        sta     L7FA0,y
        iny
        bne     L7F3D
L7F47:  jsr     LFFCF
        jsr     L7ADB
        sta     L7FB1
        rts
L7F51:  lda     #$6A
        ldy     #$7A
        jsr     LEFE7
        jsr     LEF59
        cmp     #$30
        bmi     L7F51
        cmp     #$33
        bpl     L7F51
        and     #$03
        tax
        lda     $EA2F,x
        rts
        jsr     L7AF0
        jmp     L7A05
        jsr     L7AA3
        jsr     LEE9E
        txa
        bne     L7F91
        ldy     #$0A
        lda     ($22),y
        cmp     #$05
        beq     L7F84
        jmp     L7A25
L7F84:  ldy     #$06
        lda     ($22),y
        !byte   $85
L7F89:  !byte   $66
L7F8A:  iny
L7F8B:  !byte   $B1
L7F8C:  !byte   $22
        sta     $67
L7F8F:  lda     #$00
L7F91:  rts
L7F92:  !byte   $20
L7F93:  beq     L800F
        !byte   $D0
L7F96:  asl     $224C
        !byte   $7B
        lda     #$0D
        jsr     LFFD2
        !byte   $20
L7FA0:  !byte   $FB
        inc     $2820
        !byte   $7B
L7FA5:  !byte   $4C
L7FA6:  !byte   $05
L7FA7:  !byte   $7A
L7FA8:  !byte   $6C
L7FA9:  !byte   $66
L7FAA:  brk
L7FAB:  !byte   $20
L7FAC:  !byte   $A3
L7FAD:  !byte   $7A
L7FAE:  !byte   $A9
L7FAF:  !byte   $0D
        !byte   $20
L7FB1:  !byte   $D2
L7FB2:  !byte   $FF
L7FB3:  !byte   $20
        !byte   $FB
L7FB5:  inc     $66A5
        !byte   $8D
        tay
L7FBA:  !byte   $7F
L7FBB:  !byte   $A5
L7FBC:  !byte   $67
L7FBD:  sta     L7FA9
        lda     #$2D
        jsr     LFFD2
        jsr     LEF08
        lda     $66
        clc
        adc     #$7F
        php
        sec
        sbc     L7FA8
        sta     $26
        lda     $67
        sbc     L7FA9
        plp
        adc     #$00
        asl     $26
        rol     ;a
        !byte   $8D
L7FE0:  ldx     $A97F
        brk
        sta     L7FAF
        lda     #$74
        ldy     #$7A
        jsr     LEFE7
        jsr     LEF08
        lda     #$0D
        jsr     LFFD2
        lda     $66
        sta     L7FA6
        lda     $67
        sta     L7FA7
        lda     #$05
        sta     L7FAA
        jsr     LEE33
        bmi     L8010
        tax
        beq     L8062
        !byte   $20
        !byte   $57
L800F:  sei
L8010:  jmp     L7A05
        lda     #$B4
        ldy     #$7B
        jsr     LEFE7
        jsr     L7AA3
        jsr     LEE33
        tax
        bmi     L802E
        bne     L8031
        lda     #$FF
        ldy     #$05
        sta     ($22),y
        jsr     LED3A
L802E:  jmp     L7A05
L8031:  jmp     L7A25
        ora     $2A2A
        jsr     L4544
        jmp     L5445
        eor     $2D
        brk
        ora     $5544
        bvc     L8091
        eor     #$43
        eor     ($54,x)
        eor     $20
        lsr     $49
        jmp     L2045
        lsr     $4D41
L8053:  eor     $2D
        !byte   $43
        eor     ($4E,x)
        lsr     $544F
        jsr     L4153
        lsr     $45,x
        !byte   $0D
        brk
L8062:  lda     #$C0
        ldy     #$7B
        jsr     LEFE7
        jmp     L7A05
        cmp     $E981
        bne     L8072
        rts
L8072:  lda     #$03
        jsr     LEC0D
        dec     L7F8C
        bne     L8053
        lda     #$10
        !byte   $2C
        !byte   $A9
