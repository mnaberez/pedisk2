edit_ptr = $66
target_ptr = $b7
pdos_prompt = $7A05
input_device = $7AD1
drive_sel = $7f91
track = $7f92
sector = $7f93
tmp_7f97 = $7f97 ;Temp storage for "R" or "W" menu choice
num_sectors = $7f96
read_sectors = $ECE4
write_sectors = $ED3F
input_hex_addr = $EEFB
input_hex_byte = $EF1B
get_char_w_stop = $EF59
puts = $EFE7
chrout = $FFD2

    *=$7c00

    jmp start

read_or_write:
    !text $0d,"PEDISK II DISK UTILITY"
    !text $0d,"READ OR WRITE (HIT R OR W KEY)?",0
enter_track:
    !text $0d,"TRACK? ",0
enter_sector:
    !text $0d,"SECTOR? ",0
enter_count:
    !text $0d,"# SECTORS? ",0

start:
    ;Print "PEDISK II DISK UTILITY"
    ;and "READ OR WRITE (HIT R OR W KEY)?"
    lda #<read_or_write
    ldy #>read_or_write
    jsr puts

    ;Get a character from the user and save it.
    jsr get_char_w_stop
    sta tmp_7f97

    ;Validate char is "R" or "W", ask again until it is.
    cmp #'R'
    beq ask_trk_sec
    cmp #'W'
    bne start

ask_trk_sec:
    ;Print newline
    lda #$0D
    jsr chrout

    ;Print "DEVICE?", input a valid drive number, and save it
    jsr input_device
    sta drive_sel

    ;Print "TRACK? "
    lda #<enter_track
    ldy #>enter_track
    jsr puts

    ;Input track number in hex and save it
    jsr input_hex_byte
    sta track

    ;Print "SECTOR? "
    lda #<enter_sector
    ldy #>enter_sector
    jsr puts

    ;Input sector number in hex and save it
    jsr input_hex_byte
    sta sector

    ;Print "# SECTORS?"
    lda #<enter_count
    ldy #>enter_count
    jsr puts

    ;Input sector count in hex and save it
    jsr input_hex_byte
    sta num_sectors

    ;Print "ADDR?", input a valid memory address in hex, and save it
    jsr input_hex_addr
    lda edit_ptr
    sta target_ptr
    lda edit_ptr+1
    sta target_ptr+1

    ;Get the "R" or "W" character, branch if it's "R" for read
    lda tmp_7f97
    cmp #'W'
    bne do_read

    ;Write the sectors and return to the PDOS prompt
    jsr write_sectors
    jmp pdos_prompt

do_read:
    ;Read the sectors and return to the PDOS prompt
    jsr read_sectors
    jmp pdos_prompt

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
