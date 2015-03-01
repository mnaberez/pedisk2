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

    jmp start

disk_or_mem:
    !text $0d,"  PEDISK II DUMP UTILITY"
    !text $0d,"DISK OR MEMORY ( D OR M )?",0
enter_track:
    !text $0d,"TRACK? ",0
enter_sector:
    !text $0d,"SECTOR? ",0
more:
    !text "MORE..",0

start:
    ;Print banner and "DISK OR MEMORY ( D OR M )?"
    lda #<disk_or_mem
    ldy #>disk_or_mem
    jsr puts

    ;Set line count for screen pause
    lda #$0A
    sta edit_pos

    ;Get a character from the user
    jsr get_char_w_stop

    ;Save A, print a newline, restore A
    pha
    lda #$0D
    jsr chrout
    pla

    cmp #'D'
    beq dump_disk

    cmp #'M'
    bne start

    ;Print "ADDR"? and get a valid address into edit_ptr
    jsr input_hex_addr

    ;Print a newline
    lda #$0D
    jsr chrout

dump_memory:
    ;Print the address in hex
    lda edit_ptr+1
    jsr put_hex_byte
    lda edit_ptr
    jsr put_hex_byte

    ;Dump 16 bytes to the screen
    ldx #1              ;X=1 time
    jsr dump_16_x_times ;Dump 16 bytes 1 time

    ;Move edit_ptr forward 16 bytes, keep dumping until end of memory
    lda edit_ptr
    clc
    adc #16
    sta edit_ptr
    bcc dump_memory
    inc edit_ptr+1
    bne dump_memory

    ;Return to PDOS prompt
    rts

dump_disk:
    ;Get drive select pattern
    jsr input_device    ;Print "DEVICE? ", get num, returns drv sel pat in A
    sta drive_sel       ;Save the drive select pattern in drive_sel

    ;Get track
    lda #<enter_track
    ldy #>enter_track
    jsr puts            ;Print "TRACK? "
    jsr input_hex_byte  ;Get a hex byte from the user
    sta track           ;Save it track

    ;Get sector
    lda #<enter_sector
    ldy #>enter_sector
    jsr puts            ;Print "SECTOR? "
    jsr input_hex_byte  ;Get a hex byte from the user
    sta sector          ;Save it sector

    lda #<dir_sector
    sta target_ptr
    sta edit_ptr
    lda #>dir_sector
    sta target_ptr+1
    sta edit_ptr+1

sector_loop:
    ;Read sector from disk
    jsr read_a_sector
    bne disk_error       ;Branch if a disk error occurred

    ;Print a newline
    lda #$0D
    jsr chrout

    ;Print track and sector in hex like "TTSS"
    lda track
    jsr put_hex_byte    ;Print track in hex
    lda sector
    jsr put_hex_byte    ;Print sector in hex

    ;Increment the next sector for the next time around
    clc
    adc #$01
    cmp #$1D            ;TODO Past last sector?  28 sectors per track on 5.25"
    bmi skip_trk_inc
    sec
    sbc #$1C            ;TODO 28 sectors per track?
    inc track
skip_trk_inc:
    sta sector

    ;Dump the sector (128 bytes) to the screen
    ldx #8              ;X=8 times
    jsr dump_16_x_times ;Dump 16 bytes to the screen 8 times

    jmp sector_loop

disk_error:
    jmp pdos_prompt

dump_16_x_times:
    stx dir_ptr

    ldy #$00
loop:
    lda #$04
    sta dir_ptr+1
    sty hex_save_a
L7CFB:
    ldx #$04

    ;Print a space
    lda #' '
    jsr chrout

hex_loop:
    lda (edit_ptr),y
    jsr put_hex_byte
    iny
    dex
    bne hex_loop

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

    ;Print the byte in PETSCII or "." if unprintable
    lda (edit_ptr),y
    cmp #' '
    bmi unprintable
    cmp #$80
    bmi printable
unprintable:
    lda #'.'
printable:
    jsr chrout

    iny
    dex
    bne L7D21

    ;Check if STOP key was pressed, return to prompt if so
    jsr chrin           ;Get key, or 0 if none
    cmp #$03            ;Was the STOP key pressed?
    bne not_stop        ;  No: keep going
    jmp pdos_prompt     ;  Yes: jump to the PDOS prompt

not_stop:
    dec edit_pos
    bpl skip_pause

    ;Print "MORE.." while preserving Y
    tya
    pha
    lda #<more
    ldy #>more
    jsr puts
    pla
    tay

    ;Wait for a key
    jsr get_char_w_stop

    ;Print a newline
    lda #$0D
    jsr chrout

    ;Reset line count for screen pause
    lda #$0A
    sta edit_pos

skip_pause:
    dec dir_ptr
    beq L7D7D

    ;Print four spaces
    lda #' '
    jsr chrout
    jsr chrout
    jsr chrout
    jsr chrout

    jmp loop
L7D7D:
    rts                 ;Return to PDOS prompt

filler:
    !byte $FF,$FF
