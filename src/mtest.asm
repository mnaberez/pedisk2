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
    jsr l_048a
    pla
l_0488:
    and #$0F
l_048a:
    clc
    adc #'0'
    cmp #$3A
    bcc l_0493
    adc #$06
l_0493:
    jsr jmp_chrout
    rts

msg_out:
;Print the message at ($22).
;Message is terminated with $04 byte.
    ldy #$00
l_0499:
    lda ($22),y
    cmp #$04
    beq l_04a5
    jsr jmp_chrout
    iny
    bne l_0499
l_04a5:
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
    bcc l_04c8
    cmp #'9'+1
    bcc l_04d9
    cmp #'A'
    bcc l_04c8
    cmp #'F'+1
    bcc l_04d7
l_04c8:
    lda #'?'
    jsr jmp_chrout
    lda #$08
    jsr jmp_chrout
    jsr jmp_chrout
    bne input_nibble
l_04d7:
    adc #$09
l_04d9:
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

l_0521:
    ldx #$00
    stx $22
    jsr l_0545
    jsr cr_out
    lda #'1'
    jsr jmp_chrout
    jsr jsr_spc_out
    inc $22
    jsr l_0545
    lda #'2'
    jsr jmp_chrout
    clc
    bcc l_0521
l_0540:
    inc $23
    bne l_054b
    rts

l_0545:
    ldy #$00
    ldx #$00
    stx $23
l_054b:
    nop
    nop
    nop
    inc $8000
    ldy $23
    jsr l_05db
l_0556:
    tya
    sta ($28,x)
    nop
    nop
    nop
    lda ($28,x)
    sta $2A
    cpy $2A
    beq l_0567
    jsr l_05a9
l_0567:
    jsr l_0598
    beq l_0572
    jsr l_058c
    clc
    bcc l_0556
l_0572:
    ldy $23
    jsr l_05db
l_0577:
    lda ($28,x)
    sta $2A
    cpy $2A
    beq l_0582
    jsr l_05ae
l_0582:
    jsr l_058c
    jsr l_0598
    bne l_0577
    beq l_0540
l_058c:
    iny
    lda $22
    beq l_0597
    cpy #$F3
    bcc l_0597
    ldy #$00
l_0597:
    rts

l_0598:
    inc $28
    bne l_059e
    inc $29
l_059e:
    lda $26
    cmp $28
    bne l_05a8
    lda $27
    cmp $29
l_05a8:
    rts

l_05a9:
    pha
    lda #$49
    bne l_05b1
l_05ae:
    pha
    lda #'D'
l_05b1:
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

l_05db:
    lda $24
    sta $28
    lda $25
    sta $29
    rts

filler:
    !byte $0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d
    !byte $0d,$0d,$0d,$0d
    !text "CCRS/ASM "  ;not a typo: "CCGRS" not "CGRS"
