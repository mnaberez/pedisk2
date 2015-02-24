vartab = $2a
old_dir_ptr = $4b
new_dir_ptr = $4d
target_ptr = $b7
L790D = $790D
pdos_prompt = $7A05
try_extrnl_cmd = $7A47
input_device = $7AD1
drive_sel = $7f91
track = $7f92
sector = $7f93
num_sectors = $7f96
old_track = $7f98  ;Old track number of file
old_sector = $7f99 ;Old sector number of file
old_count = $7f9b  ;2 bytes for old file sector count
next_incr = $EC74
read_sectors = $ECE4
write_sectors = $ED3F
puts = $EFE7
chrout = $FFD2

    *=$7c00

    jmp start

new_track:
;Temp byte to store a file's new track number
    !byte 0             ;0 = First track on disk

new_sector:
;Temp byte to store a file's new sector number
    !byte $09           ;9 = First sector after the dir on track 0

disk_compression:
    !text $0d,"** DISK COMPRESSION **",$0d
    !text "   KEYBOARD LOCKED",0
moving_file:
    !text $0d,"MOVING FILE ",0
cant_read_file:
    !text $0d," CANNOT READ-DELETE FILE ",0
cant_write_index:
    !text $0d," CANNOT WRITE NEW INDEX-REFORMAT DISK",$0d
    !text "         ALL DATA IS LOST!",0
cant_write_file:
    !text $0d," CANNOT WRITE FILE ",0

start:
    ;Print banner and "KEYBOARD LOCKED"
    lda #<disk_compression
    ldy #>disk_compression
    jsr puts

    ;Print "DEVICE?" and get a valid drive number from the user
    ;  Sets drive_sel with the drive select pattern
    jsr input_device
    sta drive_sel

    lda #$60
    sta $7F9A
    ldx #$00
    stx track
    inx
    stx sector
    lda #$08
    sta num_sectors
    lda #$00
    sta target_ptr
    sta old_dir_ptr
    sta new_dir_ptr
    lda #$04
    sta target_ptr+1
    sta old_dir_ptr+1
    sta new_dir_ptr+1
    jsr read_sectors
    beq L7CE8           ;Branch if read succeeded
    jmp pdos_prompt

L7CE8:
    lda #$00
    sta $0408

next_new:
    ;Advance to the next directory entry in the new directory
    lda new_dir_ptr
    clc
    adc #$10
    sta new_dir_ptr
    bcc next_old
    inc new_dir_ptr+1

next_old:
    ;Advance to the next directory entry in the old directory
    lda old_dir_ptr
    clc
    adc #$10
    sta old_dir_ptr
    bcc check_end_dir
    inc old_dir_ptr+1

check_end_dir:
    ;Check for end of directory
    ldy #$00            ;Y=$00 index to first byte of filename
    lda (old_dir_ptr),y ;Get first byte of filename
    cmp #$FF            ;Is it equal to $FF (end of directory)?
    bne check_deleted   ;  No: branch to handle this entry
    jmp L7E36           ;  Yes: done with all entries, jump to finish up

check_deleted:
    ;Check if file was deleted
    ldy #$05            ;Y=$05 index to last byte of filename
    lda (old_dir_ptr),y ;Get last byte of filename
    cmp #$FF            ;Is it equal to $FF (file deleted)?
    beq next_old        ;Yes: advance to the next entry in the old directory
                        ;     but the new directory stays as it is
                        ;No: continue to handle the file

    inc $0408

    ;Old dir: Get track number of the file
    ldy #$0C            ;Y=$0c index to file track number
    lda (old_dir_ptr),y
    sta old_track

    ;Old dir: Get sector number of the file
    iny                 ;Y=$0d index to file sector number
    lda (old_dir_ptr),y
    sta old_sector

    ;Old dir: Get sector count of file (low byte)
    iny                 ;Y=$0e index to file sector count low byte
    lda (old_dir_ptr),y
    sta (new_dir_ptr),y
    sta old_count

    ;Old dir: Get sector count of file (high byte)
    iny                 ;Y=$0f index to file sector count high byte
    lda (old_dir_ptr),y
    sta (new_dir_ptr),y
    sta old_count+1

    ;New dir: Set track number of file
    ldy #$0C            ;Y=$0c index to file track number
    lda new_track
    sta (new_dir_ptr),y

    ;New dir: Set sector number of file
    iny                 ;Y=$0d index to file sector number
    lda new_sector
    sta (new_dir_ptr),y

    ;Copy bytes $00-$0B from old dir entry into new entry
    ;These bytes are the filename, type, size, and load address
    ldy #$0B            ;Y=$0b index to unknown byte
L7D45:
    lda (old_dir_ptr),y
    sta (new_dir_ptr),y
    dey
    bpl L7D45

    lda old_sector
    cmp new_sector
    bne L7D8A

    lda old_track
    cmp new_track
    bne L7D8A

    lda old_count
    sta $7FAE
    lda old_count+1
    sta $7FAF

    jsr L790D

    lda new_sector
    clc
    adc $59
    cmp #$1D            ;TODO Past last sector?  28 sectors per track on 5.25"
    bmi L7D7B
    sec
    sbc #$1C            ;TODO 28 sectors per track?
    inc new_track
L7D7B:
    sta new_sector
    lda new_track
    clc
    adc $58
    sta new_track
L7D87:
    jmp next_new
L7D8A:
    lda old_count
    ora old_count+1
    beq L7D87

    lda old_count
    sta num_sectors
    sec
    sbc $7F9A
    sta old_count
    bcs L7DB0
    dec old_count+1
    bpl L7DB0
    lda #$00
    sta old_count
    sta old_count+1
    beq L7DB6
L7DB0:
    lda $7F9A
    sta num_sectors
L7DB6:
    lda num_sectors
    sta $7F97
    lda old_track
    sta track
    lda old_sector
    sta sector
    lda #$00
    sta target_ptr
    lda #$08
    sta target_ptr+1
    jsr read_sectors
    beq L7DE2           ;Branch if read succeeded

    ;Print " CANNOT READ-DELETE FILE "
    lda #<cant_read_file
    ldy #>cant_read_file
    jsr puts

    ;Print the filename at (new_dir_ptr)
    jsr put_filename

    jmp L7E65
L7DE2:
    jsr next_incr
    bcc L7DEA
    jmp L7E65
L7DEA:
    lda track
    sta old_track
    lda sector
    sta old_sector
    lda $7F97
    sta num_sectors
    lda new_track
    sta track
    lda new_sector
    sta sector

    ;Print "MOVING FILE "
    lda #<moving_file
    ldy #>moving_file
    jsr puts

    ;Print the filename at (new_dir_ptr)
    jsr put_filename

    lda #$00
    sta target_ptr
    lda #$08
    sta target_ptr+1
    jsr write_sectors
    bne L7E5B           ;Branch if a disk error occurred
    jsr next_incr
    bcc L7E27
    jmp L7E65
L7E27:
    lda track
    sta new_track
    lda sector
    sta new_sector
    jmp L7D8A
L7E36:
    lda new_track
    sta $0409
    lda new_sector
    sta $040A
    lda new_dir_ptr
    tay
    lda #$00
    sta new_dir_ptr
    lda #$FF
L7E4B:
    sta (new_dir_ptr),y
    iny
    bne L7E4B
    ldx new_dir_ptr+1
    inx
    stx new_dir_ptr+1
    cpx #$08
    bmi L7E4B
    bpl L7E65
L7E5B:
    ;Print "CANNOT WRITE FILE "
    lda #<cant_write_file
    ldy #>cant_write_file
    jsr puts

    ;Print the filename at (new_dir_ptr)
    jsr put_filename

L7E65:
    lda #$08
    sta num_sectors
    lda #$00
    sta target_ptr
    lda #$04
    sta target_ptr+1
    ldy #$00
    sty track
    iny
    sty sector
    jsr write_sectors
    beq L7E8A           ;Branch if write succeeded

    ;Print "CANNOT WRITE NEW INDEX-REFORMAT DISK"
    ;  and "ALL DATA IS LOST!"
    lda #<cant_write_index
    ldy #>cant_write_index
    jsr puts

    jmp pdos_prompt
L7E8A:
    lda #$04
    sta vartab
    sta vartab+1
    lda #$00
    sta $0400
    sta $0401
    sta $0402
    lda #'P'            ;P-PRINT DISK DIRECTORY
    jmp try_extrnl_cmd

put_filename:
;Print the filename at (new_dir_ptr)
;
    ldy #$00
pdbf1:
    lda (new_dir_ptr),y
    jsr chrout
    iny
    cpy #$06
    bmi pdbf1
    rts

filler:
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    !byte $FF,$FF,$FF
