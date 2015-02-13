L7A05 = $7A05
L7AD1 = $7AD1
LECE4 = $ECE4
LED3F = $ED3F
LEEFB = $EEFB
LEF1B = $EF1B
LEF59 = $EF59
LEFE7 = $EFE7
LFFD2 = $FFD2

    *=$7c00

    jmp L7C5B

read_or_write:
    !text $0d,"PEDISK II DISK UTILITY"
    !text $0d,"READ OR WRITE (HIT R OR W KEY)?",0
enter_track:
    !text $0d,"TRACK? ",0
enter_sector:
    !text $0d,"SECTOR? ",0
enter_count:
    !text $0d,"# SECTORS? ",0

L7C5B:
    ;Print "PEDISK II DISK UTILITY"
    ;and "READ OR WRITE (HIT R OR W KEY)?"
    lda #<read_or_write
    ldy #>read_or_write
    jsr LEFE7

    jsr LEF59
    sta $7F97
    cmp #$52
    beq L7C70
    cmp #$57
    bne L7C5B
L7C70:
    ;Print newline
    lda #$0D
    jsr LFFD2

    jsr L7AD1
    sta $7F91

    ;Print "TRACK? "
    lda #<enter_track
    ldy #>enter_track
    jsr LEFE7

    jsr LEF1B
    sta $7F92

    ;Print "SECTOR? "
    lda #<enter_sector
    ldy #>enter_sector
    jsr LEFE7

    jsr LEF1B
    sta $7F93

    ;Print "# SECTORS?"
    lda #<enter_count
    ldy #>enter_count
    jsr LEFE7

    jsr LEF1B
    sta $7F96
    jsr LEEFB

    lda $66
    sta $B7
    lda $67
    sta $B8

    lda $7F97
    cmp #$57
    bne L7CBA
    jsr LED3F
    jmp L7A05
L7CBA:
    jsr LECE4
    jmp L7A05

filler:
;The bytes from here to the end of the file are not used by the code
;above.  They are likely part of another $7C00 overlay that happened
;to be in memory when this overlay was saved to disk.
;
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    stx $3F92
    inx
    stx $3F93
    stx $E982
fill_1:
    jsr $3D7D
    lda #$6C
    ldy #$3C
    jsr $EFED
    lda #$00
    ldx $3F92
    jsr $CF83
    inc $3F92
    lda #$50
    cmp $3F92
    bpl fill_1
    lda #$00
    sta $B7
    lda #$3F
    sta $B8
    ldy #$7F
    lda #$FF
fill_2:
    sta ($B7),y
    dey
    bpl fill_2
    !byte $A2
