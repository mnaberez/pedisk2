L000D = $0D
L7A05 = $7A05
L7AD1 = $7AD1
LCF83 = $CF83
LEBA0 = $EBA0
LEC0D = $EC0D
LECCC = $ECCC
LED3A = $ED3A
LEF7B = $EF7B
puts = $EFE7
chrout = $FFD2

    *=$7c00

    jmp start

disk_format:
    !text $0d,$0d,"PEDISK II DISK FORMAT"
    !text $0d,"   DOUBLE DENSITY",$0d,0
are_you_sure:
    !text $0d,"SURE? (Y-YES)",0
enter_name:
    !text $0d,"NAME? ",$0d,0
finished:
    !text $0d,"FINISHED!",0
protected_disk:
    !text $0d,"PROTECTED DISK!!",$0d,0
error:
    !text " ERROR!",0
format_track:
    !text $0d,"FORMAT TRACK ",0

start:
    ;Print banner
    lda #<disk_format
    ldy #>disk_format
    jsr puts

    jsr L7AD1
    sta $7F91

    ;Print "SURE? (Y-YES)"
    lda #<are_you_sure
    ldy #>are_you_sure
    jsr puts

    jsr LEF7B
    cmp #$59
    bne L7CB5
    jsr LEBA0
    bne L7CB5
    lda #$03
    jsr LEC0D
    lda $E980
    and #$40
    bne L7CB8
    lda $E980
    and #$9D
    cmp #$04
    beq L7CC5
    lda #$F0
    jmp L7D6C
L7CB5:
    jmp L7A05
L7CB8:
    nop

    ;Print "PROTECTED DISK!!"
    lda #<protected_disk
    ldy #>protected_disk
    jsr puts

    lda #$F3
    jmp L7D6C
L7CC5:
    ldx #$00
    stx $7F92
    inx
    stx $7F93
    stx $E982
L7CD1:
    jsr L7D7D

    ;Print "FORMAT TRACK "
    lda #<format_track
    ldy #>format_track
    jsr puts

    lda #$00
    ldx $7F92
    jsr LCF83
    inc $7F92
    lda #$28            ;TODO 40/41 tracks?
    cmp $7F92
    bpl L7CD1
    lda #$00
    sta $B7
    lda #$7F
    sta $B8
    ldy #$7F
    lda #$FF
L7CF9:
    sta ($B7),y
    dey
    bpl L7CF9
    ldx #$00
    stx $7F92
    inx
    inx
    stx $7F93
L7D08:
    jsr LED3A
L7D0B:
    bne L7CB5
    lda $7F94
    beq L7D17
    lda #$F1
    jmp L7D6C
L7D17:
    ldx $7F93
    inx
    stx $7F93
    cpx #$09
    bmi L7D08
    lda #$01
    sta $7F93

    ;PRINT "NAME? "
    lda #<enter_name
    ldy #>enter_name
    jsr puts

    ldx #$00
L7D30:
    stx $26
    jsr LEF7B
    ldx $26
    sta $7F00,x
    inx
    cpx #$08
    bcc L7D30
    lda #$00
    sta $7F08
    sta $7F09
    lda #$09
    sta $7F0A
    lda #$20
    sta $7F0B
    sta $7F0C
    sta $7F0D
    sta $7F0E
    sta $7F0F
    jsr LED3A
    bne L7D0B

    ;Print "FINISHED!"
    lda #<finished
    ldy #>finished
    jsr puts

    jmp L7A05
L7D6C:
    pha
    lda L000D
    jsr chrout
    pla

    ;Print " ERROR!"
    lda #<error
    ldy #>error
    jsr puts

    jmp L7A05
L7D7D:
    lda $7F92
    sta $E983
    lda #$13
    jsr LEC0D
    lda #$00
    sta $7F90
    ldy #$01
    sei
    lda #$F4
    sta $E980
    ldx #$06
L7D97:
    dex
    bne L7D97
    ldx #$10
L7D9C:
    lda #$E6
L7D9E:
    bit $E980
    beq L7D9E
    lda #$4E
    sta $E983
    dex
    bne L7D9C
    ldx #$08
L7DAD:
    lda #$E6
L7DAF:
    bit $E980
    beq L7DAF
    lda #$00
    sta $E983
    dex
    bne L7DAD
    ldx #$03
L7DBE:
    lda #$E6
L7DC0:
    bit $E980
    beq L7DC0
    lda #$F6
    sta $E983
    dex
    bne L7DBE
    lda #$E6
L7DCF:
    bit $E980
    beq L7DCF
    lda #$FC
    sta $E983
    ldx #$20
L7DDB:
    lda #$E6
L7DDD:
    bit $E980
    beq L7DDD
    lda #$4E
    sta $E983
    dex
    bne L7DDB
L7DEA:
    ldx #$08
L7DEC:
    lda #$E6
L7DEE:
    bit $E980
    beq L7DEE
    lda #$00
    sta $E983
    dex
    bne L7DEC
    ldx #$03
L7DFD:
    lda #$E6
L7DFF:
    bit $E980
    beq L7DFF
    lda #$F5
    sta $E983
    dex
    bne L7DFD
    lda #$E6
L7E0E:
    bit $E980
    beq L7E0E
    lda #$FE
    sta $E983
    lda #$E6
L7E1A:
    bit $E980
    beq L7E1A
    lda $7F92
    sta $E983
    lda #$E6
L7E27:
    bit $E980
    beq L7E27
    lda #$00
    sta $E983
    lda #$E6
L7E33:
    bit $E980
    beq L7E33
    sty $E983
    iny
    lda #$E6
L7E3E:
    bit $E980
    beq L7E3E
    lda #$00
    sta $E983
    lda #$E6
L7E4A:
    bit $E980
    beq L7E4A
    lda #$F7
    sta $E983
    ldx #$16
L7E56:
    lda #$E6
L7E58:
    bit $E980
    beq L7E58
    lda #$4E
    sta $E983
    dex
    bne L7E56
    ldx #$0C
L7E67:
    lda #$E6
L7E69:
    bit $E980
    beq L7E69
    lda #$00
    sta $E983
    dex
    bne L7E67
    ldx #$03
L7E78:
    lda #$E6
L7E7A:
    bit $E980
    beq L7E7A
    lda #$F5
    sta $E983
    dex
    bne L7E78
    lda #$E6
L7E89:
    bit $E980
    beq L7E89
    lda #$FB
    sta $E983
    ldx #$80
L7E95:
    lda #$E6
L7E97:
    bit $E980
    beq L7E97
    lda #$E5
    sta $E983
    dex
    bne L7E95
    lda #$E6
L7EA6:
    bit $E980
    beq L7EA6
    lda #$F7
    sta $E983
    ldx #$1C            ;TODO 28 sectors per track?
L7EB2:
    lda #$E6
L7EB4:
    bit $E980
    beq L7EB4
    lda #$4E
    sta $E983
    dex
    bne L7EB2
    lda #$E6
L7EC3:
    bit $E980
    bne L7EC3
    lda #$4E
    sta $E983
    cpy #$1D            ;TODO Past last sector?  28 sectors per track on 5.25"
    bpl L7ED4
    jmp L7DEA
L7ED4:
    lda #$01
L7ED6:
    bit $E980
    bne L7ED6
    cli
    jsr LECCC
    rts

filler:
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
