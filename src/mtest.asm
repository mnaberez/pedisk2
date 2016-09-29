chrin = $FFCF
chrout = $FFD2

    * = $0400

    jmp start

jmp_chrin:
    jmp chrin

jmp_chrout:
    jmp chrout

banner:
    !byte $93
    !text " PET MEMORY TEST PROGRAM ",$0d
    !text " CGRS MICROTECH,INC. ",$0d
    !text " LANGHORNE,PA. 19047 ",$0d,$0a,$04
ask_start_addr:
    !text " START ADDRESS ? ",$04
ask_end_addr:
    !text " END ADDRESS   ? ",$04

jsr_spc_out:
    jsr spc_out

spc_out:
;Print a space character
    lda #' '
    jsr jmp_chrout
    rts

hex_byte_out:
;Print the byte in A as a two-digit hex number
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
    adc #'0'
    cmp #$3A
    bcc L0493
    adc #$06
L0493:
    jsr jmp_chrout
    rts

msg_out:
;Print the message at ($22).
;Message is terminated with $04 byte.
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

input_byte:
;Get a byte from the user as two hex digits.
;Stores the byte in $22
    jsr input_nibble
    asl ;a
    asl ;a
    asl ;a
    asl ;a
    sta $22
    jsr input_nibble
    ora $22
    rts

input_nibble:
;Get a nibble from the user as one hex digit.
;Keeps prompting until it gets a char 0-F.
;Stores the nibble in $22.
    jsr jmp_chrin
    cmp #'0'
    bcc L04C8
    cmp #'9'+1
    bcc L04D9
    cmp #'A'
    bcc L04C8
    cmp #'F'+1
    bcc L04D7
L04C8:
    lda #'?'
    jsr jmp_chrout
    lda #$08
    jsr jmp_chrout
    jsr jmp_chrout
    bne input_nibble
L04D7:
    adc #$09
L04D9:
    and #$0F
    rts

cr_out:
;Print a carriage return character
    lda #$0D
    jsr jmp_chrout
    rts

start:
    cld

    ;Print " PET MEMORY TEST " banner
    lda #<banner
    sta $22
    lda #>banner
    sta $23
    jsr msg_out
    jsr cr_out

    ;Print " START ADDRESS ? " prompt
    lda #<ask_start_addr
    sta $22
    lda #>ask_start_addr
    sta $23
    jsr msg_out

    ;Input start address from user, save in $24-25
    jsr input_byte
    sta $25
    jsr input_byte
    sta $24
    jsr cr_out

    ;Print " END ADDRESS   ? " prompt
    lda #<ask_end_addr
    sta $22
    lda #>ask_end_addr
    sta $23
    jsr msg_out

    ;Input end address from user, save in $26-27
    jsr input_byte
    sta $27
    jsr input_byte
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
    jsr hex_byte_out
    lda $28
    jsr hex_byte_out
    jsr jsr_spc_out
    pla
    jsr hex_byte_out
    jsr jsr_spc_out
    tya
    jsr hex_byte_out
    jsr jsr_spc_out
    lda $22
    jsr hex_byte_out
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
