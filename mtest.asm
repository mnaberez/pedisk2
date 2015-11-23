chrin = $FFCF
chrout = $FFD2

    * = $0400

    jmp L04E2

jmp_chrin:
    jmp chrin

jmp_chrout:
    jmp chrout

banner:
    !byte $93
    !text " PET MEMORY TEST PROGRAM ",$0d
    !text " CGRS MICROTECH,INC. ",$0d
    !text " LANGHORNE,PA. 19047 ",$0d,$0a,$04
    !text " START ADDRESS ? ",$04
    !text " END ADDRESS   ? ",$04

jsr_spc_out:
    jsr spc_out

spc_out:
;Print a space character
    lda #' '
    jsr jmp_chrout
    rts

L047F:
    pha
    lsr ;a
    lsr ;a
    lsr ;a
    lsr ;a
    jsr L048A
    pla
L0488:
    and #$0F
L048A:
    clc
    adc #$30
    cmp #$3A
    bcc L0493
    adc #$06
L0493:
    jsr jmp_chrout
    rts

L0497:
    ldy #$00
L0499:
    lda ($22),y
    cmp #$04
    beq L04A5
    jsr jmp_chrout
    iny
    bne L0499
L04A5:
    rts

L04A6:
    jsr L04B5
    asl ;a
    asl ;a
    asl ;a
    asl ;a
    sta $22
    jsr L04B5
    ora $22
    rts

L04B5:
    jsr jmp_chrin
    cmp #$30
    bcc L04C8
    cmp #$3A
    bcc L04D9
    cmp #$41
    bcc L04C8
    cmp #$47
    bcc L04D7
L04C8:
    lda #'?'
    jsr jmp_chrout
    lda #$08
    jsr jmp_chrout
    jsr jmp_chrout
    bne L04B5
L04D7:
    adc #$09
L04D9:
    and #$0F
    rts

cr_out:
    lda #$0D
    jsr jmp_chrout
    rts

L04E2:
    cld
    lda #$09
    sta $22
    lda #$04
    sta $23
    jsr L0497
    jsr cr_out
    lda #$52
    sta $22
    lda #$04
    sta $23
    jsr L0497
    jsr L04A6
    sta $25
    jsr L04A6
    sta $24
    jsr cr_out
    lda #$64
    sta $22
    lda #$04
    sta $23
    jsr L0497
    jsr L04A6
    sta $27
    jsr L04A6
    sta $26
    jsr cr_out
L0521:
    ldx #$00
    stx $22
    jsr L0545
    jsr cr_out
    lda #'1'
    jsr jmp_chrout
    jsr jsr_spc_out
    inc $22
    jsr L0545
    lda #'2'
    jsr jmp_chrout
    clc
    bcc L0521
L0540:
    inc $23
    bne L054B
    rts

L0545:
    ldy #$00
    ldx #$00
    stx $23
L054B:
    nop
    nop
    nop
    inc $8000
    ldy $23
    jsr L05DB
L0556:
    tya
    sta ($28,x)
    nop
    nop
    nop
    lda ($28,x)
    sta $2A
    cpy $2A
    beq L0567
    jsr L05A9
L0567:
    jsr L0598
    beq L0572
    jsr L058C
    clc
    bcc L0556
L0572:
    ldy $23
    jsr L05DB
L0577:
    lda ($28,x)
    sta $2A
    cpy $2A
    beq L0582
    jsr L05AE
L0582:
    jsr L058C
    jsr L0598
    bne L0577
    beq L0540
L058C:
    iny
    lda $22
    beq L0597
    cpy #$F3
    bcc L0597
    ldy #$00
L0597:
    rts

L0598:
    inc $28
    bne L059E
    inc $29
L059E:
    lda $26
    cmp $28
    bne L05A8
    lda $27
    cmp $29
L05A8:
    rts

L05A9:
    pha
    lda #$49
    bne L05B1
L05AE:
    pha
    lda #'D'
L05B1:
    jsr jmp_chrout
    jsr jsr_spc_out
    lda $29
    jsr L047F
    lda $28
    jsr L047F
    jsr jsr_spc_out
    pla
    jsr L047F
    jsr jsr_spc_out
    tya
    jsr L047F
    jsr jsr_spc_out
    lda $22
    jsr L047F
    jsr cr_out
    rts

L05DB:
    lda $24
    sta $28
    lda $25
    sta $29
    rts

filler:
    !byte $0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d
    !byte $0d,$0d,$0d,$0d
    !text "CCRS/ASM "  ;not a typo: "CCGRS" not "CGRS"
