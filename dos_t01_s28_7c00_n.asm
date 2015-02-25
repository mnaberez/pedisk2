dir_ptr = $22
pdos_prompt = $7A05
input_filename = $7AA3
dir_entry = $7fa0
drive_sel_f = $7fb1
write_a_sector = $ED3A
find_file = $EE33
puts = $EFE7

    *=$7c00

    jmp start

old_file:
    !text $0d,"PEDISK II FILE RENAME UTILITY",$0d
    !text "OLD FILE-",0
new_file:
    !text $0d,"NEW FILE-",0
already_in_file:
    !text $0d,"****NAME ALREADY IN FILE****",0
not_in_dir:
    !text $0d,"****NOT IN DIRECTORY****",0

start:
    ;Print banner and "OLD FILE-"
    lda #<old_file
    ldy #>old_file
    jsr puts

    ;Print "FILE?" and get the old filename from user
    ;  Sets filename bytes in dir_entry and drive_sel_f
    jsr input_filename

    ;Save the old filename in fname
    ldx #$05
copy_old:
    lda dir_entry,x
    sta fname,x
    dex
    bpl copy_old

    ;Save drive select pattern of old file in drv_sel.  It will
    ;not actually be used.
    lda drive_sel_f
    sta drv_sel

    ;Print "NEW FILE-"
    lda #<new_file
    ldy #>new_file
    jsr puts

    ;Print "FILE?" and get the new filename from user
    ;  Sets filename bytes in dir_entry and drive_sel_f
    jsr input_filename

    ;Check if the new filename already exists in the directory
    jsr find_file
    tax
    bmi check_error     ;Branch if a disk error occurred
    beq file_exists     ;Branch if file was found

    ;Move the old filename into filename, and in the process
    ;push each byte of the new filename onto the stack.
    ldx #$05
recall_old:
    lda dir_entry,x
    pha
    lda fname,x
    sta dir_entry,x
    dex
    bpl recall_old

    ;Check if the old filename exists in the directory.  If it is found,
    ;find_file leaves a directory sector in memory at dir_sector and
    ;sets up dir_ptr pointing to the filename.
    jsr find_file
    tax

check_error:
    bmi exit            ;Branch if a disk error occurred
    bne file_not_found  ;Branch if file was not found

    ;Pop each byte of the new filename off the stack and write it into
    ;the directory sector buffer, overwriting the old filename.
    ldy #$00
rename_entry:
    pla
    sta (dir_ptr),y
    iny
    cpy #$06
    bmi rename_entry

    ;Write the directory sector back to the disk.
    jsr write_a_sector

exit:
    ;Return to the PDOS prompt.
    jmp pdos_prompt

file_exists:
    ;Print "****NAME ALREADY IN FILE****" and exit
    lda #<already_in_file
puts_exit:
    ldy #>already_in_file
    jsr puts
    jmp pdos_prompt

file_not_found:
    ;Print "****NOT IN DIRECTORY****" and exit
    lda #<not_in_dir
    jmp puts_exit

fname:
    !byte 0,0,0,0,0,0
drv_sel:
    !byte 0

filler:
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF
