L0070 = $0070
L0076 = $0076
L0D00 = $0D00
L3400 = $3400
L4353 = $4353
L5254 = $5254
L5323 = $5323
L5400 = $5400
L5954 = $5954
LC873 = $C873
LCF6D = $CF6D
LEA44 = $EA44
LEB0B = $EB0B
LEB5E = $EB5E
LEB7A = $EB7A
LEB7F = $EB7F
LEB84 = $EB84
LEC96 = $EC96
LECDF = $ECDF
LECE4 = $ECE4
LED3A = $ED3A
LED3F = $ED3F
LEE33 = $EE33
LEE9E = $EE9E
LEF59 = $EF59
LEFE7 = $EFE7
LFFD2 = $FFD2

        *=$7800


dos_save:
        jmp     _dos_save
dos_open:
        jmp     _dos_open
dos_close:
        jmp     _dos_close
dos_input:
        jmp     _dos_input
dos_print:
        jmp     _dos_print
dos_run:
        jmp     _dos_run
dos_sys:
        jmp     _dos_sys
dos_list:
        jmp     _dos_list

dos_stop:
        ;fall through

_dos_stop:
        lda     $2A
        sec
        sbc     $28
        sta     $7FA6
        sta     $58
        lda     $2B
        sbc     $29
        sta     $59
        sta     $7FA7
        lda     $28
        sta     $7FA8
        lda     $29
        sta     $7FA9
        jsr     L7891
        lda     $7F96
        sta     $7FAE
        lda     #$00
        sta     $7FAF
        lda     #$03
        sta     $7FAA
        jsr     LEE33
        tax
        bmi     L7890
        bne     L7857
        lda     #$05
L7852:  jsr     LEC96
        bne     L7890
L7857:  lda     #$00
        sta     $7FAB
        jsr     L78A2
        bne     L7890
        lda     $7FB5
        beq     L786A
        lda     #$06
        bne     L7852
L786A:  lda     $7FA8
        sta     $B7
        lda     $7FA9
        sta     $B8
        lda     $56
        sta     $7F92
        lda     $57
        sta     $7F93
        lda     $7FAE
        sta     $7F96
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
        sta     $7F96
        rts
L78A2:  lda     #$00
        sta     $7FB5
        lda     $56
        sta     $7FAC
        lda     $57
        sta     $7FAD
        jsr     L78F1
        lda     $58
        cmp     #$51
        bmi     L78C0
        lda     #$2B
        sta     $7FB5
        rts
L78C0:  ldy     #$0F
L78C2:  lda     $7FA0,y
        sta     ($22),y
        dey
        bpl     L78C2
        lda     $7F93
        cmp     #$01
        beq     L78E0
        jsr     LED3A
        bne     L7890
        lda     #$01
        sta     $7F93
        jsr     LECDF
        bne     L7890
L78E0:  inc     $7F08
        lda     $58
        sta     $7F09
        lda     $59
        sta     $7F0A
        jsr     LED3A
        rts
L78F1:  jsr     L790D
        lda     $7FAD
        clc
        adc     $59
        cmp     #$1D
        bmi     L7902
        sbc     #$1C
        inc     $58
L7902:  sta     $59
        lda     $7FAC
        clc
        adc     $58
        sta     $58
        rts
L790D:  lda     $7FAE
        sec
        sbc     #$01
        sta     $5E
        lda     $7FAF
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

_dos_sys:
        lda     #$00
        sta     $B7
        lda     #$7A
        sta     $B8
        ldx     #$00
        stx     $7F92
        inx
        stx     $7F91
        lda     #$16
        sta     $7F93
        lda     #$04
        sta     $7F96
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

_dos_save:
        jsr     _dos_stop
        jmp     LEB5E
L7A0A:  ldx     #$03
        lda     #$7E
        sta     $23
        lda     #$E0
L7A12:  sta     $22
        ldy     #$05
L7A16:  lda     ($22),y
        cmp     $7FA0,y
        bne     L7A2D
        dey
        bpl     L7A16
        ldy     #$11
        lda     ($22),y
        cmp     $7FB1
        bne     L7A2D
L7A29:  stx     $7F8F
        rts
L7A2D:  dex
        bmi     L7A29
        lda     $22
        sec
        sbc     #$20
        bne     L7A12

_dos_open:
        jsr     L7A0A
        inx
        beq     L7A41
        lda     #$30
        bne     L7A73
L7A41:  ldx     #$03
        ldy     #$60
L7A45:  lda     $7E80,y
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
L7A5B:  stx     $7F8F
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
        sta     $7FAE
        lda     #$80
        sta     $7FA6
        sta     $7FA8
        lda     #$00
        sta     $7FA7
        sta     $7FA9
        sta     $7FAA
        sta     $7FAB
        sta     $7FAF
        jsr     L0070
        cmp     #$C3
        bne     L7AAC
        jsr     L0070
        bcs     L7AB3
        jsr     LC873
        lda     $11
        sta     $7FAE
        lda     $12
        sta     $7FAF
L7AAC:  jsr     L78A2
        bne     L7B2C
        beq     L7AE8
L7AB3:  jsr     LCF6D
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
        sta     $7FAF
        iny
        lda     ($44),y
        sta     $7FAE
        jmp     L7AAC
L7AD6:  pla
        beq     L7ADE
        lda     #$32
L7ADB:  jmp     L7B3D
L7ADE:  ldy     #$0F
L7AE0:  lda     ($22),y
        sta     $7FA0,y
        dey
        bpl     L7AE0
L7AE8:  lda     #$00
        sta     $7FB2
        sta     $7FB3
        sta     $7FB5
        lda     $7FAC
        sta     $7FBA
        ldx     $7FAD
        dex
        stx     $7FBB
L7B00:  jsr     L7B55
        ldy     #$00
        lda     $7FB3
        sta     ($44),y
        iny
        lda     $7FB2
        sta     ($44),y
        jsr     L7B59
        ldy     #$00
        lda     #$00
        sta     ($44),y
        lda     $7FB5
        iny
        sta     ($44),y
        jsr     L7B2F
L7B22:  lda     $7FA0,y
        sta     $7E80,x
        dex
        dey
        bpl     L7B22
L7B2C:  jmp     LEB5E
L7B2F:  lda     $7F8F
        asl     ;a
        asl     ;a
        asl     ;a
        asl     ;a
        asl     ;a
        adc     #$1F
        tax
        ldy     #$1F
        rts
L7B3D:  sta     $7FB5
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
        jsr     LCF6D
        pla
        sta     $78
        pla
        sta     $77
        rts

_dos_close:
        jsr     L7BA6
        ldy     #$00
        lda     ($77),y
        cmp     #$80
        bne     L7B91
        jsr     L0070
        jsr     L7C22
        lda     #$FF
        sta     $7F00
        jsr     LED3A
        bne     L7BA3
L7B91:  lda     #$FF
        sta     $7FA0
        sta     $7FB5
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
L7BB4:  lda     $7E80,x
        sta     $7FA0,y
        dex
        dey
        bpl     L7BB4
        lda     #$00
        sta     $7FB5
        rts
L7BC4:  ldy     #$00
        lda     ($77),y
        cmp     #$B9
        bne     L7C22
        jsr     L0070
        jsr     L7B55
        ldy     #$00
        lda     ($44),y
        sta     $7FB3
        iny
        lda     ($44),y
        sta     $7FB2
        ora     $7FB3
        bne     L7BE9
        lda     #$08
        jmp     L7B3D
L7BE9:  lda     $7FB2
        sec
        sbc     #$01
        sta     $5E
        lda     $7FB3
        sbc     #$00
        sta     $5F
        lda     #$1C
        sta     $60
        lda     #$00
        sta     $61
        jsr     L797B
        lda     $5E
        clc
        adc     $7FAD
        pha
        lda     $62
        adc     $7FAC
        sta     $7FBA
        pla
        cmp     #$1D
        bcc     L7C1C
        inc     $7FBA
        sbc     #$1C
L7C1C:  sta     $7FBB
        jmp     L7C3C
L7C22:  inc     $7FB2
        bne     L7C2A
        inc     $7FB3
L7C2A:  inc     $7FBB
        lda     $7FBB
        cmp     #$1D
        bcc     L7C3C
        inc     $7FBA
        lda     #$01
        sta     $7FBB
L7C3C:  lda     $7FBA
        sta     $7F92
        cmp     $7FBC
        bcc     L7C56
        bne     L7C51
        lda     $7FBB
        cmp     $7FBD
        bcc     L7C56
L7C51:  lda     #$08
        jmp     L7B3D
L7C56:  lda     $7FBB
        sta     $7F93
        lda     #$00
        sta     $B7
        lda     #$7F
        sta     $B8
        lda     $7FB1
        sta     $7F91
        rts

_dos_input:
        jsr     L7BA6
        jsr     L7BC4
        jsr     LECDF
        bne     L7CA2
        jsr     LCF6D
        bit     $07
        bmi     L7C82
        lda     #$09
L7C7F:  jmp     L7B3D
L7C82:  lda     $7F00
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

_dos_print:
        jsr     L7BA6
        jsr     L7BC4
        jsr     LCF6D
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
L7CC3:  sta     $7F00
        iny
        lda     ($44),y
        sta     $22
        iny
        lda     ($44),y
        sta     $23
        ldy     #$7E
L7CD2:  lda     ($22),y
        sta     $7F01,y
        dey
        bpl     L7CD2
        jsr     LED3A
        bne     L7CA2
        jmp     L7B00

_dos_run:
        jsr     LEE9E
        txa
        bne     L7D10
        lda     #$0C
        sta     $77
        lda     #$7D
        sta     $78
        ldx     #$1F
        sei
L7CF3:  lda     $7FE0,x
        sta     $01E0,x
        dex
        bpl     L7CF3
        ldx     $7F8B
        txs
        cli
        ldy     $7F8A
        ldx     $7F89
        lda     #$8A
        jmp     LEA44
        txa
        brk
        brk
        brk
L7D10:  jmp     LEB5E

_dos_list:
        lda     #$28
        ldy     #$7D
        jsr     LEFE7
        jsr     LEF59
        cmp     #$30
        bmi     _dos_list
        cmp     #$34
        bpl     _dos_list
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
        eor     $2045
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
        sta     $7F91
        ldx     #$00
        stx     $7F92
        inx
        stx     $7F93
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
        inc     $7F93
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
        !byte   $CF
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
        !byte   $92
        and     $BD03,y
