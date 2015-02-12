L2044 = $2044
L2045 = $2045
L2D45 = $2D45
L4944 = $4944
L4946 = $4946
L4949 = $4949
L4E49 = $4E49
L7A05 = $7A05
L7AA3 = $7AA3
LED3A = $ED3A
LEE33 = $EE33
LEFE7 = $EFE7

    *=$7c00

    jmp L7C6F
    ora $4550
    !byte $44
    eor #$53
    !byte $4B
    jsr L4949
    jsr L4946
    jmp L2045
    !byte $52
    eor $4E
    eor ($4D,x)
    eor $20
    eor $54,x
    eor #$4C
    eor #$54
    eor $4F0D,y
    jmp L2044
    lsr $49
    jmp L2D45
    brk
    ora $454E
    !byte $57
    jsr L4946
    jmp L2D45
    brk
    ora $2A2A
    rol ;a
    rol ;a
    lsr $4D41
    eor $20
    eor ($4C,x)
    !byte $52
    eor $41
    !byte $44
    eor $4920,y
    lsr $4620
    eor #$4C
    eor $2A
    rol ;a
    rol ;a
    rol ;a
    brk
    ora $2A2A
    rol ;a
    rol ;a
    lsr $544F
    jsr L4E49
    jsr L4944
    !byte $52
    eor $43
    !byte $54
    !byte $4F
    !byte $52
    eor $2A2A,y
    rol ;a
    rol ;a
    brk
L7C6F:
    lda #$03
    ldy #$7C
    jsr LEFE7
    jsr L7AA3
    ldx #$05
L7C7B:
    lda $7FA0,x
    sta L7CD2,x
    dex
    bpl L7C7B
    lda $7FB1
    sta L7CD8
    lda #$2C
    ldy #$7C
    jsr LEFE7
    jsr L7AA3
    jsr LEE33
    tax
    bmi L7CAF
    beq L7CC3
    ldx #$05
L7C9E:
    lda $7FA0,x
    pha
    lda L7CD2,x
    sta $7FA0,x
    dex
    bpl L7C9E
    jsr LEE33
    tax
L7CAF:
    bmi L7CC0
    bne L7CCD
    ldy #$00
L7CB5:
    pla
    sta ($22),y
    iny
    cpy #$06
    bmi L7CB5
    jsr LED3A
L7CC0:
    jmp L7A05
L7CC3:
    lda #$37
L7CC5:
    ldy #$7C
    jsr LEFE7
    jmp L7A05
L7CCD:
    lda #$55
    jmp L7CC5
L7CD2:
    brk
    brk
    brk
    brk
    brk
    brk
L7CD8:
    brk
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
