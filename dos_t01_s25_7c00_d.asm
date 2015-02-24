dir_ptr = $22
hex_save_a = $26
edit_pos = $27
edit_ptr = $66
target_ptr = $b7
pdos_prompt = $7A05
input_device = $7AD1
dir_sector = $7f00
drive_sel = $7f91
track = $7f92
sector = $7f93
put_hex_byte = $EB84
read_a_sector = $ECDF
input_hex_addr = $EEFB
input_hex_byte = $EF1B
get_char_w_stop = $EF59
puts = $EFE7
chrout = $ffd2
chrin = $ffe4

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
    jsr get_char_w_stop

    ;Save A, print a newline, restore A
    pha
    lda #$0D
    jsr chrout
    pla

    cmp #'D'
    beq L7C94
    cmp #'M'
    bne L7C52
    jsr input_hex_addr

    ;Print a newline
    lda #$0D
    jsr chrout

L7C77:
    lda edit_ptr+1
    jsr put_hex_byte
    lda edit_ptr
    jsr put_hex_byte
    ldx #$01
    jsr L7CF1
    lda edit_ptr
    clc
    adc #$10
    sta edit_ptr
    bcc L7C77
    inc edit_ptr+1
    bne L7C77
    rts
L7C94:
    jsr input_device
    sta drive_sel

    ;Print "TRACK? "
    lda #<enter_track
    ldy #>enter_track
    jsr puts

    jsr input_hex_byte
    sta track

    ;Print "SECTOR? "
    lda #<enter_sector
    ldy #>enter_sector
    jsr puts

    jsr input_hex_byte
    sta sector

    lda #<dir_sector
    sta target_ptr
    sta edit_ptr
    lda #>dir_sector
    sta target_ptr+1
    sta edit_ptr+1
L7CC0:
    jsr read_a_sector
    bne L7CEE           ;Branch if a disk error occurred

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
    jmp pdos_prompt
L7CF1:
    stx dir_ptr
    ldy #$00
L7CF5:
    lda #$04
    sta dir_ptr+1
    sty hex_save_a
L7CFB:
    ldx #$04

    ;Print a space
    lda #' '
    jsr chrout

L7D02:
    lda (edit_ptr),y
    jsr put_hex_byte
    iny
    dex
    bne L7D02
    dec dir_ptr+1
    bne L7CFB

    ;Print four spaces
    lda #' '
    jsr chrout
    jsr chrout
    jsr chrout
    jsr chrout

    ldy hex_save_a
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

    lda (edit_ptr),y
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
    jsr chrin
    cmp #$03
    bne L7D4D
    jmp pdos_prompt
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
    jsr get_char_w_stop
    lda #$0D
    jsr chrout
    lda #$0A
    sta edit_pos
L7D68:
    dec dir_ptr
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
