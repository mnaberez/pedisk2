edit_pos = $27
target_ptr = $b7
L7A05 = $7A05
L7AD1 = $7AD1
dir_sector = $7f00
drive_sel = $7f91
track = $7f92
sector = $7f93
put_hex_byte = $EB84
read_a_sector = $ECDF
l_eefb = $EEFB
l_ef1b = $EF1B
l_ef59 = $EF59
puts = $EFE7
chrout = $ffd2 ;KERNAL Send a char to the current output device
LFFE4 = $FFE4

    *=$7c00

    jmp L7C52

disk_or_mem:
    !text $0d,"  PEDISK II DUMP UTILITY"
    !text $0d,"DISK OR MEMORY ( D OR M )?",0
enter_track:
    !text $0d,"TRACK? ",0
enter_sector:
    !text $0d,"SECTOR? ",0
more:
    !text "MORE..",0

L7C52:
    ;Print banner and "DISK OR MEMORY ( D OR M )?"
    lda #<disk_or_mem
    ldy #>disk_or_mem
    jsr puts

    lda #$0A
    sta edit_pos
    jsr l_ef59

    ;Save A, print a newline, restore A
    pha
    lda #$0D
    jsr chrout
    pla

    cmp #'D'
    beq L7C94
    cmp #'M'
    bne L7C52
    jsr l_eefb

    ;Print a newline
    lda #$0D
    jsr chrout

L7C77:
    lda $67
    jsr put_hex_byte
    lda $66
    jsr put_hex_byte
    ldx #$01
    jsr L7CF1
    lda $66
    clc
    adc #$10
    sta $66
    bcc L7C77
    inc $67
    bne L7C77
    rts
L7C94:
    jsr L7AD1
    sta drive_sel

    ;Print "TRACK? "
    lda #<enter_track
    ldy #>enter_track
    jsr puts

    jsr l_ef1b
    sta track

    ;Print "SECTOR? "
    lda #<enter_sector
    ldy #>enter_sector
    jsr puts

    jsr l_ef1b
    sta sector

    lda #<dir_sector
    sta target_ptr
    sta $66
    lda #>dir_sector
    sta target_ptr+1
    sta $67
L7CC0:
    jsr read_a_sector
    bne L7CEE

    ;Print a newline
    lda #$0D
    jsr chrout

    lda track
    jsr put_hex_byte
    lda sector
    jsr put_hex_byte
    clc
    adc #$01
    cmp #$1D            ;TODO Past last sector?  28 sectors per track on 5.25"
    bmi L7CE3
    sec
    sbc #$1C            ;TODO 28 sectors per track?
    inc track
L7CE3:
    sta sector
    ldx #$08
    jsr L7CF1
    jmp L7CC0
L7CEE:
    jmp L7A05
L7CF1:
    stx $22
    ldy #$00
L7CF5:
    lda #$04
    sta $23
    sty $26
L7CFB:
    ldx #$04

    ;Print a space
    lda #' '
    jsr chrout

L7D02:
    lda ($66),y
    jsr put_hex_byte
    iny
    dex
    bne L7D02
    dec $23
    bne L7CFB

    ;Print four spaces
    lda #' '
    jsr chrout
    jsr chrout
    jsr chrout
    jsr chrout

    ldy $26
    ldx #$10
L7D21:
    txa
    and #$03
    bne L7D2B

    ;Print a space
    lda #' '
    jsr chrout

L7D2B:
    ;Print a space
    lda #' '
    jsr chrout

    lda ($66),y
    cmp #' '
    bmi L7D3A
    cmp #$80
    bmi L7D3C
L7D3A:
    lda #'.'
L7D3C:
    jsr chrout
    iny
    dex
    bne L7D21
    jsr LFFE4
    cmp #$03
    bne L7D4D
    jmp L7A05
L7D4D:
    dec edit_pos
    bpl L7D68
    tya
    pha

    ;Print "MORE.."
    lda #<more
    ldy #>more
    jsr puts

    pla
    tay
    jsr l_ef59
    lda #$0D
    jsr chrout
    lda #$0A
    sta edit_pos
L7D68:
    dec $22
    beq L7D7D

    ;Print four spaces
    lda #' '
    jsr chrout
    jsr chrout
    jsr chrout
    jsr chrout

    jmp L7CF5
L7D7D:
    rts
    !byte $FF
    !byte $FF
