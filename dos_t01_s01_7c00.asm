L0020 = $0020
L2000 = $2000
L2020 = $2020
L4142 = $4142
L424F = $424F
L4353 = $4353
L454C = $454C
L4550 = $4550
L4553 = $4553
L4554 = $4554
L4944 = $4944
L4949 = $4949
L4E45 = $4E45
L4E49 = $4E49
L4F4C = $4F4C
L5323 = $5323
L5349 = $5349
L5420 = $5420
L7931 = $7931
L7A05 = $7A05
L7AD1 = $7AD1
LEB7F = $EB7F
LEB84 = $EB84
LECDF = $ECDF
LEF59 = $EF59
LEFE7 = $EFE7
LFFD2 = $FFD2

        *=$7c00

        jmp     L7CB4
        ora     $4D0A
        !byte   $4F
        !byte   $52
        eor     $2E
        rol     $2E2E
        brk
        !byte   $93
        jsr     L2020
        jsr     L4550
        !byte   $44
        eor     #$53
        !byte   $4B
        jsr     L4949
        jsr     L4944
        !byte   $53
        !byte   $4B
        jsr     L4944
        !byte   $52
        eor     $43
        !byte   $54
        !byte   $4F
        !byte   $52
        eor     $0A0D,y
        !byte   $44
        eor     #$53
        !byte   $4B
        lsr     $4D41
        eor     $3D
        jsr     L2000
        jsr     L4553
        !byte   $43
        !byte   $54
        !byte   $4F
        !byte   $52
        !byte   $53
        jsr     L454C
        lsr     $54
        and     L0020,x
        ora     $0A0D
        lsr     $4D41
        eor     L0020
        jsr     L5420
        eor     L4550,y
        jsr     L5420
        !byte   $52
        !byte   $4B
        jsr     L4353
        !byte   $54
        !byte   $52
        jsr     L5323
        !byte   $43
        !byte   $54
        !byte   $52
        !byte   $53
        jsr     L4F4C
        eor     ($44,x)
        jsr     L4E45
        !byte   $54
        !byte   $52
        eor     L2000,y
        !byte   $53
        eor     $51
        !byte   $54
        jmp     L0020
        jsr     L4E49
        !byte   $44
        cli
        jsr     L0020
        jsr     L5349
        eor     ($4D,x)
        jsr     L0020
        jsr     L4142
        !byte   $53
        eor     #$43
        jsr     L2000
        eor     ($53,x)
        !byte   $53
        eor     $2042
        brk
        jsr     L4F4C
        eor     ($44,x)
        jsr     L0020
        jsr     L4554
        cli
        !byte   $54
        jsr     L0020
        jsr     L424F
        lsr     ;a
        !byte   $43
        !byte   $54
        !byte   $20
        brk
L7CB4:  jsr     L7AD1
        sta     $7F91
        ldx     #$00
        stx     $7F92
        inx
        stx     $7F93
        lda     #$00
        sta     $B7
        sta     $22
        lda     #$7F
        sta     $B8
        sta     $23
        jsr     LECDF
        beq     L7CD7
        jmp     L7A05
L7CD7:  lda     #$0E
        ldy     #$7C
        jsr     LEFE7
        ldy     #$00
        ldx     #$08
L7CE2:  lda     ($22),y
        jsr     LFFD2
        iny
        dex
        bne     L7CE2
        lda     #$38
        ldy     #$7C
        jsr     LEFE7
        ldx     #$00
        stx     $59
        lda     $7F09
        sta     $5E
        lda     #$1C
        sta     $60
        lda     #$00
        sta     $5F
        sta     $61
        jsr     L7931
        lda     $7F0A
        clc
        adc     $62
        sta     $62
        bcc     L7D14
        inc     $63
L7D14:  lda     #$5F
        sec
        sbc     $62
        sta     $62
        lda     #$04
        sbc     $63
        jsr     LEB84
        lda     $62
        jsr     LEB84
        lda     #$49
        ldy     #$7C
        jsr     LEFE7
L7D2E:  lda     #$12
        sta     $27
        lda     #$0D
        jsr     LFFD2
L7D37:  lda     #$0A
        jsr     LFFD2
L7D3C:  lda     $22
        clc
        adc     #$10
        bpl     L7D50
        inc     $7F93
        jsr     LECDF
        beq     L7D4E
        jmp     L7A05
L7D4E:  lda     #$00
L7D50:  sta     $22
        ldy     #$00
        lda     ($22),y
        cmp     #$FF
        bne     L7D5D
        jmp     L7DEB
L7D5D:  ldy     #$05
        lda     ($22),y
        cmp     #$FF
        beq     L7D3C
        lda     #$0D
        jsr     LFFD2
        ldy     #$00
L7D6C:  lda     ($22),y
        jsr     LFFD2
        iny
        cpy     #$06
        bmi     L7D6C
        ldy     #$0A
        lda     ($22),y
        asl     ;a
        asl     ;a
        asl     ;a
        clc
        adc     #$74
        ldy     #$7C
        jsr     LEFE7
        ldy     #$0C
        lda     ($22),y
        jsr     LEB84
        lda     #$20
        jsr     LFFD2
        ldy     #$0D
        lda     ($22),y
        jsr     LEB7F
        lda     #$20
        jsr     LFFD2
        jsr     LFFD2
        ldy     #$0F
        lda     ($22),y
        jsr     LEB7F
        ldy     #$0E
        lda     ($22),y
        jsr     LEB84
        ldy     #$0A
        lda     ($22),y
        cmp     #$05
        bne     L7DD7
        lda     #$20
        jsr     LFFD2
        jsr     LFFD2
        ldy     #$09
        lda     ($22),y
        jsr     LEB7F
        dey
        lda     ($22),y
        jsr     LEB84
        dey
        lda     ($22),y
        jsr     LEB7F
        dey
        lda     ($22),y
        jsr     LEB84
L7DD7:  dec     $27
        bmi     L7DDE
        jmp     L7D37
L7DDE:  lda     #$03
        ldy     #$7C
        jsr     LEFE7
        jsr     LEF59
        jmp     L7D2E
L7DEB:  lda     #$0D
        jsr     LFFD2
        lda     #$00
        sta     $E900
        jmp     L7A05
        !byte   $07
        sta     $7FAA
        lda     #$02
        !byte   $8D
        !byte   $AE
