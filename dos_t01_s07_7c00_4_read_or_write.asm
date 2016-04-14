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

    ;Get drive select pattern
    jsr input_device    ;Print "DEVICE? ", get num, returns drv sel pat in A
    sta drive_sel       ;Save the drive select pattern in drive_sel

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
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$8E,$92,$3F,$E8,$8E,$93,$3F,$8E
    !byte $82,$E9,$20,$7D,$3D,$A9,$6C,$A0,$3C,$20,$ED,$EF,$A9,$00,$AE,$92
    !byte $3F,$20,$83,$CF,$EE,$92,$3F,$A9,$50,$CD,$92,$3F,$10,$E4,$A9,$00
    !byte $85,$B7,$A9,$3F,$85,$B8,$A0,$7F,$A9,$FF,$91,$B7,$88,$10,$FB,$A2
