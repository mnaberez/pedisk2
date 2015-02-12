L2041 = $2041
L204C = $204C
L2145 = $2145
L2150 = $2150
L2545 = $2545
L4142 = $4142
L4353 = $4353
L454D = $454D
L4554 = $4554
L4944 = $4944
L4946 = $4946
L4C2D = $4C2D
L4F54 = $4F54
L524F = $524F
L5250 = $5250
L5254 = $5254
L5323 = $5323
L5400 = $5400
L5954 = $5954
L7A05 = $7A05
L7D97 = $7D97
LFFD2 = $FFD2

    *=$7c00

    jmp L7D03

    eor ($2D,x)
    eor $4341
    !byte $52
    !byte $4F
    eor ($53,x)
    eor $452F
    !byte $44
    eor #$54
    and ($4E,x)
    and $4552
    lsr $4D41
    eor $20
    eor ($20,x)
    lsr $49
    jmp L2545
    !byte $42
    and $4F21
    and $4325
    and $5021
    and L5250
    eor #$4E
    !byte $54
    jsr L4944
    !byte $53
    !byte $4B
    jsr L4944
    !byte $52
    eor $43
    !byte $54
    and $44
    and $5544
    eor $2050
    !byte $44
    eor #$53
    !byte $4B
    jsr L524F
    jsr L454D
    eor $5121
    and $4525
    and $5221
    and $4552
    and $4E45
    !byte $54
    eor $52
    jsr L4142
    !byte $53
    eor #$43
    and $46
    and $5321
    and $4153
    lsr $45,x
    jsr L2041
    bvc L7CCA
    !byte $4F
    !byte $47
    !byte $52
    eor ($4D,x)
    and $47
    and $4F47
    jsr L4F54
    jsr L454D
    eor L524F
    eor $5421,y
    and $4825
    and $4548
    jmp L2150
    eor $2D,x
    eor $54,x
    eor #$4C
    eor #$54
    eor $4420,y
    eor #$53
    !byte $4B
    jsr L454D
    lsr $2555
    eor #$2D
    and ($56,x)
    and $4A25
    and $5721
    and $4B25
    and $494B
    jmp L204C
    eor ($20,x)
    lsr $49
    jmp L2145
    cli
    and $5845
    !byte $45

L7CCA:
    !byte $43
    eor $54,x
    eor $20
    !byte $44
    eor #$53
    !byte $4B
    jsr L4946
    jmp L2545
    jmp L4C2D
    !byte $4F
    eor ($44,x)
    jsr L4944
    !byte $53
    !byte $4B
    jsr L5250
    !byte $4F
    !byte $47
    !byte $52
    eor ($4D,x)
    and ($59,x)
    and $4D25
    and L454D
    eor L524F
    eor $4120,y
    jmp L4554
    !byte $52
    and ($5A,x)
    and $FF25
L7D03:
    lda #$03
    sta $54
    lda #$7C
    sta $55
    lda #$93
    jsr LFFD2
    ldy #$00
L7D12:
    ldx #$14
L7D14:
    lda ($54),y
    inc $54
    bne L7D1C
    inc $55
L7D1C:
    cmp #$21
    beq L7D2E
    cmp #$25
    beq L7D38
    cmp #$FF
    beq L7D40
    jsr LFFD2
    dex
    bne L7D14
L7D2E:
    lda #$20
L7D30:
    jsr LFFD2
    dex
    bne L7D30
    beq L7D12
L7D38:
    lda #$0D
    jsr LFFD2
    jmp L7D12
L7D40:
    lda #$0D
    jsr LFFD2
    jsr LFFD2
    jmp L7A05
    eor $20
    jsr L5954
    bvc L7D97
    jsr L5254
    !byte $4B
    jsr L4353
    !byte $54
    !byte $52
    jsr L5323
    !byte $43
    !byte $54
    !byte $52
    !byte $53
    brk
    !byte $53
    eor $51
    brk
    eor #$4E
    !byte $44
    brk
    eor #$53
    eor $4200
    eor ($53,x)
    brk
    eor ($53,x)
    eor $4C00
    !byte $44
    jsr L5400
    cli
    !byte $54
    brk
    !byte $4F
