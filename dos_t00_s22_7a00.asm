dir_ptr = $22
hex_save_a = $26
edit_ptr = $66
chrget = $70
L7857 = $7857
L7C00 = $7C00
L7C11 = $7C11
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
    lda #$00
    sta latch           ;TODO deselect drives?

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
;recognized, try to load an external $7C000 overlay for it.
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
    jmp L7C00           ;If load succeeded, jump to the overlay.

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
    jmp restart_dos     ;Clear buf_1 - buf_4 and load DOS again

external_cmd:
;Load an external command.  External commands are files on the disk
;that are named like "*****X", where the last character is the
;command.  All commands load into $7C00.
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
    sta dir_entry+$05  ;Last byte of filename

    ;Set drive select pattern for drive 0
    ldy #$01
    sty drive_sel_f

    ;Try to load the overlay
    jsr load_file
    rts

input_filename:
    lda #<enter_file
    ldy #>enter_file
    jsr puts
    ldy #$00
L7AAC:
    jsr chrin
    cmp #':'
    beq L7ABB
    sta dir_entry,y
    iny
    cpy #$07
    bmi L7AAC
L7ABB:
    lda #' '
L7ABD:
    cpy #$06
    bpl L7AC7
    sta dir_entry,y
    iny
    bne L7ABD
L7AC7:
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
;Load a machine language program (file type 5) from disk.
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
    ;Copy the start address into load address
    jsr input_hex_addr
    lda edit_ptr
    sta dir_entry+$08   ;Load address low byte
    lda edit_ptr+1
    sta dir_entry+$09   ;Load address high byte

    ;Print "-" to separate start and end address
    ;Get the end address in edit_ptr
    lda #'-'
    jsr chrout
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

    lda #<enter_entry
    ldy #>enter_entry
    jsr puts

    jsr input_hex_word

    lda #$0D
    jsr chrout

    lda edit_ptr
    sta dir_entry+$06   ;Entry address low byte
    lda edit_ptr+1
    sta dir_entry+$07   ;Entry address high byte

    lda #$05            ;Type 5 = machine language program
    sta dir_entry+$0a   ;File type

    jsr find_file
    bmi L7B90           ;Branch if a disk error occurred
    tax
    beq L7BE2           ;Branch if the file was found

    jsr L7857
L7B90:
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

L7BE2:
    lda #<dupe_error
    ldy #>dupe_error
    jsr puts
    jmp pdos_prompt

filler:
;The bytes from here to the end of the file are not used by the code
;above.  They are likely part of another program that happened to be
;in memory when this overlay was saved to disk.
;
    cmp $E981
    bne fill1
    rts
fill1:
    lda #$03
    jsr $EC0D
    dec $7F8C
    bne $7BD3
    lda #$10
    !byte $2C, $A9
