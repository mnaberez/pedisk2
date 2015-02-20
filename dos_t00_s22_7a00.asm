L0066 = $66
L0070 = $70
L7857 = $7857
L7C00 = $7C00
L7C11 = $7C11
LEAD1 = $EAD1
LEC0D = $EC0D
LED3A = $ED3A
LEE33 = $EE33
LEE9E = $EE9E
LEEE6 = $EEE6
LEEFB = $EEFB
LEF08 = $EF08
LEF59 = $EF59
LEF83 = $EF83
puts = $EFE7
chrin = $FFCF
chrout = $FFD2

        *=$7a00

    lda #$93
    jsr chrout
L7A05:
    ldx #$FF
    txs
    lda #$00
    sta $E900
    lda #$0D
    jsr chrout
    jsr chrout
    lda #$3E
    jsr chrout
    jsr LEF59
    cmp #$41
    bcc L7A25
    cmp #$5B
    bcc L7A2B
L7A25:
    jsr LEEE6
    jmp L7A05
L7A2B:
    cmp #'L'            ;L-LOAD DISK PROGRAM
    beq L7A53
    cmp #'S'            ;S-SAVE A PROGRAM
    beq L7A56
    cmp #'M'            ;M-MEMORY ALTER
    beq L7A59
    cmp #'R'            ;R-RE-ENTER BASIC
    beq L7A7D
    cmp #'G'            ;G-GO TO MEMORY
    beq L7A5C
    cmp #'X'            ;X-EXECUTE DISK FILE
    beq L7A5F
    cmp #'K'            ;K-KILL A FILE
    beq L7A50
    jsr L7A89
    txa
    bne L7A05
    jmp L7C00
L7A50:
    jmp L7B93
L7A53:
    jmp L7AEA
L7A56:
    jmp L7B2B
L7A59:
    jmp LEF83
L7A5C:
    jmp L7B1A
L7A5F:
    jmp L7B12

L7A62:
    !text $0d,"FILE? ",0
L7A6A:
    !text $0d,"DEVICE? ",0
L7A74:
    !text $0d,"ENTRY? ",0

L7A7D:
    jsr L0070
    lda #$EB
    pha
    lda #$5D
    pha
    jmp LEAD1
L7A89:
    pha
    lda #$2A
    ldy #$00
L7A8E:
    sta $7FA0,y
    iny
    cpy #$05
    bmi L7A8E
    pla
    sta $7FA5
    ldy #$01
    sty $7FB1
    jsr LEE9E
    rts
L7AA3:
    lda #<L7A62
    ldy #>L7A62
    jsr puts
    ldy #$00
L7AAC:
    jsr chrin
    cmp #$3A
    beq L7ABB
    sta $7FA0,y
    iny
    cpy #$07
    bmi L7AAC
L7ABB:
    lda #$20
L7ABD:
    cpy #$06
    bpl L7AC7
    sta $7FA0,y
    iny
    bne L7ABD
L7AC7:
    jsr chrin
    jsr L7ADB
    sta $7FB1
    rts
L7AD1:
    lda #<L7A6A
    ldy #>L7A6A
    jsr puts
    jsr LEF59
L7ADB:
    cmp #$30
    bmi L7AD1
    cmp #$33
    bpl L7AD1
    and #$03
    tax
    lda $EA2F,x
    rts
L7AEA:
    jsr L7AF0
    jmp L7A05
L7AF0:
    jsr L7AA3
    jsr LEE9E
    txa
    bne L7B11
    ldy #$0A
    lda ($22),y
    cmp #$05
    beq L7B04
    jmp L7A25
L7B04:
    ldy #$06
    lda ($22),y
    sta L0066
    iny
    lda ($22),y
    sta $67
    lda #$00
L7B11:
    rts
L7B12:
    jsr L7AF0
    bne L7B25
    jmp L7B22
L7B1A:
    lda #$0D
    jsr chrout
    jsr LEEFB
L7B22:
    jsr L7B28
L7B25:
    jmp L7A05
L7B28:
    jmp (L0066)
L7B2B:
    jsr L7AA3
    lda #$0D
    jsr chrout
    jsr LEEFB
    lda L0066
    sta $7FA8
    lda $67
    sta $7FA9
    lda #$2D
    jsr chrout
    jsr LEF08
    lda L0066
    clc
    adc #$7F
    php
    sec
    sbc $7FA8
    sta $26
    lda $67
    sbc $7FA9
    plp
    adc #$00
    asl $26
    rol ;a
    sta $7FAE
    lda #$00
    sta $7FAF
    lda #<L7A74
    ldy #>L7A74
    jsr puts
    jsr LEF08
    lda #$0D
    jsr chrout
    lda L0066
    sta $7FA6
    lda $67
    sta $7FA7
    lda #$05
    sta $7FAA
    jsr LEE33
    bmi L7B90
    tax
    beq L7BE2
    jsr L7857
L7B90:
    jmp L7A05
L7B93:
    lda #<L7BB4
    ldy #>L7BB4
    jsr puts
    jsr L7AA3
    jsr LEE33
    tax
    bmi L7BAE
    bne L7BB1
    lda #$FF
    ldy #$05
    sta ($22),y
    jsr LED3A
L7BAE:
    jmp L7A05
L7BB1:
    jmp L7A25

L7BB4:
    !text $0d,"** DELETE-",0
L7BC0:
    !text $0d,"DUPLICATE FILE NAME-CANNOT SAVE",$0d,0

L7BE2:
    lda #<L7BC0
    ldy #>L7BC0
    jsr puts
    jmp L7A05
    cmp $E981
    bne L7BF2
    rts
L7BF2:
    lda #$03
    jsr LEC0D
    dec $7F8C
    bne $7BD3
    lda #$10
    !byte $2C
    !byte $A9
