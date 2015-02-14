L0D45 = $0D45
L2020 = $2020
L2026 = $2026
L4345 = $4345
L4552 = $4552
L4553 = $4553
L4944 = $4944
L4946 = $4946
L4949 = $4949
L4E49 = $4E49
L4F43 = $4F43
L5020 = $5020
L524F = $524F
L5345 = $5345
L5455 = $5455
L5A49 = $5A49
L7A47 = $7A47
LEF59 = $EF59
LFFD2 = $FFD2

    *=$7c00

    jmp L7C99

    !byte   $93
    jsr     L2020
    jsr     L5020
    eor     $44
    eor     #$53
    !byte   $4B
    jsr     L4949
    ora     $4420
    eor     #$53
    !byte   $4B
    jsr     L5455
    eor     #$4C
    eor     #$54
    eor     $5320,y
    eor     $4C
    eor     $43
    !byte   $54
    ora     $310D
    jsr     L4F43
    eor     $5250
    eor     $53
    !byte   $53
    jsr     L4944
    !byte   $53
    !byte   $4B
    jsr     L4946
    jmp     L5345
    ora     $2032
    !byte   $43
    !byte   $4F
    bvc     L7C9E
    jsr     L4944
    !byte   $53
    !byte   $4B
    jsr     L524F
    jsr     L4946
    jmp     L0D45
    !byte   $33
    jsr     L4E49
    eor     #$54
    eor     #$41
    jmp     L5A49
    eor     $20
    !byte   $44
    eor     #$53
    !byte   $4B
    ora     $2034
    !byte   $44
    eor     #$53
    !byte   $4B
    jsr     L4553
    !byte   $43
    !byte   $54
    !byte   $4F
    !byte   $52
    jsr     L4552
    eor     ($44,x)
    jsr     L2026
    !byte   $57
    !byte   $52
    eor     #$54
    eor     $0D
    ora     $4E45
    !byte   $54
    eor     $52
    jsr     L4553
    jmp     L4345
    !byte   $54
    eor     #$4F
    lsr     $4E20
    eor     $4D,x
    !byte   $42
    eor     $52
    !byte   $20
    brk

L7C99:
    lda #$03
    ldy #$7C
    !byte $20

L7C9E:
    !byte $E7
    !byte $EF

L7CA0:
    jsr LEF59
    cmp #$31
    bmi L7CB5
    cmp #$35
    bpl L7CB5
    pha
    lda #$0D
    jsr LFFD2
    pla
    jmp L7A47

L7CB5:
    lda #$3F
    jsr LFFD2
    lda #$9D
    jsr LFFD2
    jsr LFFD2
    jmp L7CA0

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
