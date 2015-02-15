L2052  = $2052
L4949  = $4949
L4E49  = $4E49
L4F43  = $4F43
L4F54  = $4F54
L5244  = $5244
L5246  = $5246
L524F  = $524F
L5257  = $5257
L5455  = $5455
L7931  = $7931
L7A05  = $7A05
L7AD1  = $7AD1
LECDF  = $ECDF
LECE4  = $ECE4
LED3A  = $ED3A
LED3F  = $ED3F
LEF7B  = $EF7B
LEFE7  = $EFE7

    *=$7c00

    jmp start

    !text $0d,"PEDISK II COPY UTILITY",$0d
    !text "COPY FROM DRIVE #",0
    !text $0d,"COPY TO DRIVE #",0
    !text $0d,"PUT ORIGINAL",0
    !text $0d,"PUT COPY IN DRIVE"
    !text $0d,"HIT R KEY",0
    !text $0d,"* WRONG DISK *",$0d,0

start:
    ldy #$7C
    lda #$03
    jsr LEFE7
    lda #$08
    sta $7F9C
    sta $5E
    lda #$00
    !byte $85
L7C8B:
    !byte $5F
    sta $61
    lda #$1C
    sta $60
    jsr L7931
    lda $62
    sta $7F9D
    sta $7F9B
    lda #$28
    sec
    sbc $7F9C
    sta $7F9E
    lda #$00
    sta $7F9A
    jsr L7AD1
L7CAE:
    sta $7F97
    ldy #$7C
    lda #$2D
    jsr LEFE7
    jsr L7AD1
    sta $7F98
    cmp $7F97
    bne L7CC8
    lda #$80
    sta $7F9A
L7CC8:
    jsr L7DCD
    lda $7F97
    sta $7F91
    lda #$00
    sta $7F99
    sta $7F92
    lda #$01
    sta $7F93
    lda #$00
    sta $B7
    lda #$7F
    sta $B8
    jsr LECDF
    beq L7CEE
L7CEB:
    jmp L7A05
L7CEE:
    lda $7F97
    jsr L7DE3
    jsr LECE4
    bne L7CEB
    bit $7F9A
    bpl L7D4D
L7CFE:
    ldy #$7C
    lda #$4C
    jsr LEFE7
    lda #$00
    sta $E900
    jsr L7DDB
    lda #$00
    sta $7F92
    lda #$01
    sta $7F93
    sta $7F96
    lda #$00
    sta $B7
    lda #$7E
    sta $B8
    jsr LECDF
    bne L7CEB
    lda $7F99
    bne L7D3C
    ldx #$07
L7D2E:
    lda $7E00,x
    sta $0400,x
    dex
    bpl L7D2E
    stx $040F
    bne L7D4D
L7D3C:
    lda $7E0F
    cmp #$FF
    beq L7D4D
    lda #$69
    ldy #$7C
    jsr LEFE7
    jmp L7CFE
L7D4D:
    lda $7F98
    jsr L7DE3
    jsr LED3F
L7D56:
    bne L7CEB
    lda $7F99
    clc
    adc $7F9C
    sta $7F99
    cmp $7F09
    beq L7D69
    bpl L7D95
L7D69:
    cmp $7F9E
    bmi L7D8A
    lda #$28
    sec
    sbc $7F99
    bcc L7D95
    sta $5E
    lda #$1C
    sta $60
    lda #$00
    sta $5F
    sta $61
    jsr L7931
    lda $62
    sta $7F9B
L7D8A:
    bit $7F9A
    bpl L7D92
    jsr L7DCD
L7D92:
    jmp L7CEE
L7D95:
    lda #$00
    sta $7F92
    lda #$01
    sta $7F93
    sta $7F96
    lda #$00
    sta $B7
    lda #$7E
    sta $B8
    jsr LECDF
    bne L7D56
    lda #$20
    sta $7E0F
    jsr LED3A
    bne L7D56
    lda #$04
    sta $2A
    sta $2B
    lda #$00
    sta $0400
    sta $0401
    sta $0402
    jmp L7A05
L7DCD:
    ldy #$7C
    lda #$3E
    jsr LEFE7
    lda #$55
    ldy #$7C
    jsr LEFE7
L7DDB:
    jsr LEF7B
    cmp #$52
    bne L7DDB
    rts
L7DE3:
    sta $7F91
    lda $7F99
    sta $7F92
    lda #$01
    sta $7F93
    lda $7F9B
    sta $7F96
    ldx #$00
    stx $B7
    lda #$04
    sta $B8
    rts
