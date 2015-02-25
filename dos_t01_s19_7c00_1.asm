vartab = $2a
old_dir_ptr = $4b
new_dir_ptr = $4d
target_ptr = $b7
dir_buffer = $0400  ;1024 byte buffer for all directory sectors
file_buffer = $0800 ;TODO ??? byte buffer for file data
L790D = $790D
pdos_prompt = $7A05
try_extrnl_cmd = $7A47
input_device = $7AD1
drive_sel = $7f91
track = $7f92
sector = $7f93
num_sectors = $7f96
tmp_7f97 = $7f97   ;Temp storage for sector count
old_track = $7f98  ;Old track number of file
old_sector = $7f99 ;Old sector number of file
tmp_7f9a = $7f9a   ;Temp storage for TODO ??
old_count = $7f9b  ;2 bytes for old file sector count
dir_entry = $7fa0
next_sector = $EC74
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

    ;TODO ???
    lda #$60
    sta tmp_7f9a

    ;Set track/sector for read_sectors (beginning of directory)
    ldx #$00
    stx track           ;Set track 0
    inx
    stx sector          ;Set sector 1

    ;Set sector count for read_sectors (entire directory)
    lda #$08
    sta num_sectors

    ;Set all three pointers to dir_buffer:
    ;  target_ptr: used by read_sectors
    ;  old_dir_ptr: used to read old directory entries
    ;  new_dir_ptr: used to write new directory entries
    lda #<dir_buffer
    sta target_ptr
    sta old_dir_ptr
    sta new_dir_ptr
    lda #>dir_buffer
    sta target_ptr+1
    sta old_dir_ptr+1
    sta new_dir_ptr+1

    ;Read all of the directory sectors into dir_buffer
    jsr read_sectors
    beq L7CE8           ;Branch if read succeeded

    ;Read failed, just return to the prompt
    jmp pdos_prompt

L7CE8:
    ;Set number of used directory entries to 0
    lda #$00
    sta dir_buffer+$08  ;$08 = index to used directory entries count

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
    jmp finish_dir      ;  Yes: done with all entries, jump to set end of dir

check_deleted:
    ;Check if file was deleted
    ldy #$05            ;Y=$05 index to last byte of filename
    lda (old_dir_ptr),y ;Get last byte of filename
    cmp #$FF            ;Is it equal to $FF (file deleted)?
    beq next_old        ;Yes: advance to the next entry in the old directory
                        ;     but the new directory stays as it is
                        ;No: continue to handle the file

    ;Increment number of used directory entries
    inc dir_buffer+$08  ;$08 = index to used directory entries count

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
copy_entry_loop:
    lda (old_dir_ptr),y
    sta (new_dir_ptr),y
    dey
    bpl copy_entry_loop

    ;If the starting track or sector of the file has changed in the
    ;new dir entry, branch to start moving the file data.

    lda old_sector
    cmp new_sector
    bne move_file_loop ;Branch if new sector is different

    lda old_track
    cmp new_track
    bne move_file_loop ;Branch if new track is different

    ;The file has not moved.

    lda old_count
    sta dir_entry+$0e   ;File sector count low byte
    lda old_count+1
    sta dir_entry+$0f   ;File sector count high byte

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
jmp_next_new:
    jmp next_new

move_file_loop:
    ;If no sectors are left to move in the file, branch to do the next entry.
    lda old_count
    ora old_count+1
    beq jmp_next_new

    lda old_count
    sta num_sectors
    sec
    sbc tmp_7f9a
    sta old_count
    bcs L7DB0
    dec old_count+1
    bpl L7DB0

    lda #$00
    sta old_count
    sta old_count+1
    beq L7DB6

L7DB0:
    lda tmp_7f9a
    sta num_sectors
L7DB6:
    lda num_sectors
    sta tmp_7f97

    ;Set track/sector for read_sectors
    lda old_track
    sta track           ;Set track
    lda old_sector
    sta sector          ;Set sector

    ;Set target_ptr for read_sectors (beginning of file)
    lda #<file_buffer
    sta target_ptr      ;Low byte
    lda #>file_buffer
    sta target_ptr+1    ;High byte

    jsr read_sectors
    beq L7DE2           ;Branch if read succeeded

    ;Read file failed, print error and jump to write new dir

    ;Print " CANNOT READ-DELETE FILE "
    lda #<cant_read_file
    ldy #>cant_read_file
    jsr puts

    ;Print the filename at (new_dir_ptr)
    jsr put_filename

    jmp write_new_dir

L7DE2:
    jsr next_sector     ;Increment to next sector, don't change target_ptr
    bcc L7DEA           ;Branch if success
    jmp write_new_dir   ;Jump out if failed to increment (end of disk)

L7DEA:
    lda track
    sta old_track
    lda sector
    sta old_sector

    lda tmp_7f97
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

    lda #<file_buffer
    sta target_ptr
    lda #>file_buffer
    sta target_ptr+1

    jsr write_sectors
    bne write_file_err  ;Branch if a disk error occurred

    jsr next_sector     ;Increment to next sector, don't change target_ptr
    bcc L7E27           ;Branch if success
    jmp write_new_dir   ;Jump out if failed to increment (end of disk)

L7E27:
    lda track
    sta new_track
    lda sector
    sta new_sector
    jmp move_file_loop

finish_dir:
    ;All entries have been written to the new directory.
    ;Set the next open track and sector, then fill any
    ;remaining space in the directory with $FF.

    ;Set next open track and sector to after this file
    lda new_track
    sta dir_buffer+$09  ;Set next open track
    lda new_sector
    sta dir_buffer+$0a  ;Set next open sector

    ;Fill any remaining directory entries with $FF.

    lda new_dir_ptr     ;Get pointer low byte
    tay                 ;Copy it to Y to use with indirect addressing
    lda #$00
    sta new_dir_ptr     ;Zero the low byte for use with indirect addressing
    lda #$FF            ;A=fill byte to write into unused dir entries
fill_dir_loop:
    sta (new_dir_ptr),y ;Fill byte in dir entry
    iny
    bne fill_dir_loop
    ldx new_dir_ptr+1
    inx
    stx new_dir_ptr+1
    cpx #>(dir_buffer+1024) ;Reached end of directory?
    bmi fill_dir_loop       ;  No: branch to keep filling
    bpl write_new_dir       ;  Yes: branch to write dir to disk

write_file_err:
    ;Print "CANNOT WRITE FILE "
    lda #<cant_write_file
    ldy #>cant_write_file
    jsr puts

    ;Print the filename at (new_dir_ptr)
    jsr put_filename

    ;Fall through into write_new_dir

write_new_dir:
    ;Write the new directory to the disk.

    ;Set sector count for write_sectors (entire directory)
    lda #$08
    sta num_sectors

    ;Set target_ptr for write_sectors
    lda #<dir_buffer
    sta target_ptr
    lda #>dir_buffer
    sta target_ptr+1

    ;Set track/sector for write_sectors (beginning of directory)
    ldy #$00
    sty track           ;Set track 0
    iny
    sty sector          ;Set track 1

    ;Write the new directory to disk
    jsr write_sectors
    beq success_exit    ;Branch if write succeeded

    ;Write dir failed, print error message and return to the prompt

    ;Print "CANNOT WRITE NEW INDEX-REFORMAT DISK"
    ;  and "ALL DATA IS LOST!"
    lda #<cant_write_index
    ldy #>cant_write_index
    jsr puts

    jmp pdos_prompt

success_exit:
    ;Set start of variables to $0404
    lda #>dir_buffer ;TODO this code must be changed to set low byte and
                     ;     high byte separately if dir_buffer ever moves
    sta vartab       ;Set vartab low byte to $04
    sta vartab+1     ;Set vartab high byte to $04

    ;Store an empty BASIC program to reset BASIC since we overwrote
    ;the BASIC program area to use it as buffer storage.
    lda #$00
    sta dir_buffer+$00  ;End of current BASIC line
    sta dir_buffer+$01  ;End of BASIC program first byte
    sta dir_buffer+$02  ;End of BASIC program second byte

    ;Print directory and return to prompt
    lda #'P'            ;P-PRINT DISK DIRECTORY
    jmp try_extrnl_cmd  ;Load $7C00 overlay (overwrites this code)

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
