dir_ptr = $22
hex_save_a = $26
edit_ptr = $66
chrget = $70
l_7857= $7857
l_7c00= $7C00
l_7c11= $7C11
dir_entry = $7fa0
drive_sel_f = $7fb1
latch = $e900
drive_selects = $ea2f
restart_dos = $EAD1
restore = $eb5e
write_a_sector = $ED3A
find_file = $EE33
load_file = $EE9E
not_found = $EEE6
input_hex_addr = $EEFB
input_hex_word = $EF08
get_char_w_stop = $EF59
edit_memory = $EF83
puts = $EFE7
chrin = $FFCF
chrout = $FFD2

    *=$7a00

    lda #$93            ;A = PETSCII clear screen
    jsr chrout          ;Print A to clear the screen

pdos_prompt:
;Show the PDOS prompt, get a command from the user, and dispatch
;the command.  All commands in this file and in the external $7C00
;overlay files jump to this routine when they finish.
;
    ldx #$FF
    txs                 ;Reset stack pointer

    ;Deselect drives and stop motors
    lda #$00            ;Bit 3 = WD1793 /DDEN=0 (double density mode)
                        ;All other bits off = deselect drives, stop motors
                        ;TODO disk conversion: this code always sets /DDEN=0
    sta latch

    ;Print the PDOS prompt

    lda #$0D            ;A = carriage return
    jsr chrout          ;Print CR
    jsr chrout          ;Print another CR

    lda #'>'            ;A = PDOS prompt character
    jsr chrout          ;Print the prompt

    ;Get a key from the keyboard

    jsr get_char_w_stop ;A = character

    ;Check if key is the range of A-Z

    cmp #'A'
    bcc bad_cmd_or_file ;Less than 'A'?  Branch to bad command.
    cmp #'Z'+1
    bcc dispatch_cmd    ;Less than 'Z'+1?  Branch to good command.
                        ;Otherwise, fall through to bad command.

bad_cmd_or_file:
;Bad command or filename was entered.  Print the error
;message and then jump back to the prompt.
;
    jsr not_found       ;Print "??????"
    jmp pdos_prompt     ;Jump to the prompt

dispatch_cmd:
;A valid command character (A-Z) has been entered.  Try to dispatch
;it to one of the internal routines in this file.  If it is not
;recognized, try to load an external $7C00 overlay for it.
;
    cmp #'L'            ;L-LOAD DISK PROGRAM
    beq jmp_load_prog
    cmp #'S'            ;S-SAVE A PROGRAM
    beq jmp_save_prog
    cmp #'M'            ;M-MEMORY ALTER
    beq jmp_edit_memory
    cmp #'R'            ;R-RE-ENTER BASIC
    beq reenter_basic
    cmp #'G'            ;G-GO TO MEMORY
    beq jmp_goto_memory
    cmp #'X'            ;X-EXECUTE DISK FILE
    beq jmp_exec_prog
    cmp #'K'            ;K-KILL A FILE
    beq jmp_kill_file

    ;Not an internal command, try to load it from an overlay file.

try_extrnl_cmd:
    jsr external_cmd    ;Try to load the overlay
    txa                 ;X=0 means overlay loaded successfully
    bne pdos_prompt     ;If load failed, jump to prompt.
    jmp l_7c00          ;If load succeeded, jump to the overlay.

jmp_kill_file:
    jmp kill_file
jmp_load_prog:
    jmp load_prog
jmp_save_prog:
    jmp save_prog
jmp_edit_memory:
    jmp edit_memory
jmp_goto_memory:
    jmp goto_memory
jmp_exec_prog:
    jmp exec_prog

enter_file:
    !text $0d,"FILE? ",0
enter_device:
    !text $0d,"DEVICE? ",0
enter_entry:
    !text $0d,"ENTRY? ",0

reenter_basic:
;R-RE-ENTER BASIC
;
    jsr chrget
    lda #>(restore-1)
    pha
    lda #<(restore-1)
    pha
    jmp restart_dos     ;Clear open file buffers and load DOS again

external_cmd:
;Load an external command.  External commands are files on the disk
;that are named like "*****X", where the last character is the
;command.  All commands load into dos+$0400.
;
    pha

    ;Fill first 5 chars of filename with "*****"
    lda #'*'
    ldy #$00
ext1:
    sta dir_entry,y
    iny
    cpy #$05
    bmi ext1

    ;Set last char of filename to command character
    pla
    sta dir_entry+$05   ;Last byte of filename

    ;Set drive select pattern for drive 0
    ldy #$01
    sty drive_sel_f

    ;Try to load the overlay
    jsr load_file
    rts

input_filename:
;Prompt the user for a filename like "NAME:0".  Stores the filename
;in dir_entry and the drive select pattern in drive_sel_f.
;
    ;Print "FILE? "
    lda #<enter_file
    ldy #>enter_file
    jsr puts

    ldy #$00
l_7aac:
    jsr chrin
    cmp #':'
    beq l_7abb
    sta dir_entry,y
    iny
    cpy #$07
    bmi l_7aac
l_7abb:
    lda #' '
l_7abd:
    cpy #$06
    bpl l_7ac7
    sta dir_entry,y
    iny
    bne l_7abd
l_7ac7:
    jsr chrin
    jsr parse_drive
    sta drive_sel_f
    rts

input_device:
;Prompt the user for a drive number and return its
;drive select pattern in A.
;
    ;Print "DEVICE? "
    lda #<enter_device
    ldy #>enter_device
    jsr puts

    ;Get a character from the user
    jsr get_char_w_stop

parse_drive:
;Parse an ASCII drive number ("0"-"2") in A and return the
;correspoding drive select pattern in A.
;
;If the ASCII char in A is out of range, the user will be
;prompted to enter a new drive number until a number in
;range is entered.
;
    cmp #'0'
    bmi input_device    ;Branch to ask for a new number if < '0'
    cmp #'3'
    bpl input_device    ;Branch to ask for a new number if >= '3'

    and #$03            ;Convert ASCII to number 0-2
    tax
    lda drive_selects,x ;Get drive select pattern for drive number
    rts

load_prog:
;L-LOAD DISK PROGRAM
;
;Load a machine language program (file type 5) from disk.
;The program will be loaded into memory at the start address specified
;by the file.  The program is not executed.
;
    jsr try_load_file   ;Prompt for a file and load it into memory
    jmp pdos_prompt     ;Jump to the PDOS prompt

try_load_file:
;Prompt for a filename, load the file into memory at its start
;address, and set edit_ptr to its entry address.  The file is
;loaded regardless of type (TODO is this a bug?) but "??????" is
;shown if it is not type 5 (machine language program).  Return A=0
;on success, A=nonzero on any error.
;
    ;Print "FILE?" and get a filename from user
    ;  Sets filename bytes in dir_entry and drive_sel_f
    jsr input_filename

    ;Load the file into memory
    jsr load_file
    txa
    bne tlf2            ;Branch if load failed

    ;Check that the file is type 5 (machine language program)
    ;  If it's not, show "??????" and jump back to the prompt because
    ;  other file types don't have an entry address.

    ldy #$0A            ;Set index to file type byte in directory entry
    lda (dir_ptr),y     ;Get the file type
    cmp #$05            ;Is it type 5 (machine language program)?
    beq tlf1            ;  Yes: branch to continue
    jmp bad_cmd_or_file ;  No: jump to show "??????" and return to prompt

tlf1:
    ;File is type 5 (machine language program)
    ;Copy the entry address from the directory entry into edit_ptr

    ldy #$06            ;Set index to entry addr low byte in dir entry
    lda (dir_ptr),y     ;Get the entry address low byte
    sta edit_ptr        ;Save it in edit_ptr low byte
    iny                 ;Set index to entry addr high byte in dir entry
    lda (dir_ptr),y     ;Get the entry address high byte
    sta edit_ptr+1      ;Save it in edit_ptr high byte

    lda #$00            ;A = 0 indicates success
tlf2:
    rts

exec_prog:
;X-EXECUTE DISK FILE
;
;Load a machine language program (file type 5) from disk and execute it.
;The program will be loaded into memory at the start address specified
;by the file.  The program will be executed by jumping to the
;entry address specified by the file.
;
    jsr try_load_file   ;Prompt for a filename and load it into memory
    bne jmp_pdos_prompt ;If load failed, jump to the PDOS prompt
    jmp jsr_edit_ptr    ;If load succeeded, jump to the file's entry address

goto_memory:
;G-GO TO MEMORY
;
    lda #$0D
    jsr chrout
    jsr input_hex_addr
jsr_edit_ptr:
    jsr jmp_edit_ptr   ;JSR (edit_ptr)
jmp_pdos_prompt:
    jmp pdos_prompt
jmp_edit_ptr:
    jmp (edit_ptr)

save_prog:
;S-SAVE A PROGRAM
;
    ;Print "FILE?" and get a filename from user
    ;  Sets filename bytes in dir_entry and drive_sel_f
    jsr input_filename

    ;Print a newline
    lda #$0D
    jsr chrout

    ;Print "ADDR?" and get the start address in edit_ptr
    jsr input_hex_addr

    ;Set the load address in the directory entry
    lda edit_ptr
    sta dir_entry+$08   ;Load address low byte
    lda edit_ptr+1
    sta dir_entry+$09   ;Load address high byte

    ;Print "-" to prompt for the end address
    lda #'-'
    jsr chrout

    ;Get the end address in edit_ptr
    jsr input_hex_word

    lda edit_ptr
    clc
    adc #$7F
    php
    sec
    sbc dir_entry+$08   ;Load address low byte
    sta hex_save_a
    lda edit_ptr+1
    sbc dir_entry+$09   ;Load address high byte
    plp
    adc #$00
    asl hex_save_a
    rol ;a
    sta dir_entry+$0e   ;Sector count low byte
    lda #$00
    sta dir_entry+$0f   ;Sector count high byte

    ;Print "ENTRY? "
    lda #<enter_entry
    ldy #>enter_entry
    jsr puts

    ;Get the entry address into edit ptr
    jsr input_hex_word

    ;Print a newline
    lda #$0D
    jsr chrout

    ;Set the entry address in the directory entry
    lda edit_ptr
    sta dir_entry+$06   ;Entry address low byte
    lda edit_ptr+1
    sta dir_entry+$07   ;Entry address high byte

    ;Set the file type in the directory entry
    lda #$05            ;Type 5 = machine language program
    sta dir_entry+$0a   ;File type

    ;Check that the filename does not already exist
    jsr find_file
    bmi l_7b90          ;Branch if a disk error occurred
    tax
    beq file_exists     ;Branch if the file was found

    ;TODO this must save the file
    jsr l_7857
l_7b90:
    jmp pdos_prompt

kill_file:
;K-KILL A FILE
;
;Delete a file from disk.  This only sets a marker that hides the file
;from being listed in the directory.  The directory entry and the data
;sectors are not freed.  To reclaim the space, the "disk compression"
;utility must be run.
;
    ;Print "** DELETE-" prompt
    lda #<enter_kill
    ldy #>enter_kill
    jsr puts

    ;Get filename to delete from user
    jsr input_filename

    ;Find the file in the directory.  If found, the directory sector with
    ;the entry will be in dir_sector and dir_ptr will point to the entry.
    jsr find_file
    tax
    bmi kill_done           ;Branch if a disk error occurred
    bne kill_not_found      ;Branch if the file was not found

    ;Set the last byte of the filename to $FF, which
    ;marks the file as deleted.
    lda #$FF
    ldy #$05                ;Y=index to last byte in filename
    sta (dir_ptr),y         ;Set last byte of filename to $FF

    ;Write the directory sector back to the disk.
    jsr write_a_sector
kill_done:
    jmp pdos_prompt
kill_not_found:
    jmp bad_cmd_or_file

enter_kill:
    !text $0d,"** DELETE-",0
dupe_error:
    !text $0d,"DUPLICATE FILE NAME-CANNOT SAVE",$0d,0

file_exists:
    lda #<dupe_error
    ldy #>dupe_error
    jsr puts
    jmp pdos_prompt

filler:
    !byte $CD,$81,$E9,$D0,$01,$60,$A9,$03,$20,$0D,$EC,$CE,$8C,$7F,$D0
    !byte $D7,$A9,$10,$2C,$A9
