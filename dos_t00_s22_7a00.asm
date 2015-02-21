dir_ptr = $22
hex_save_a = $26
edit_ptr = $66
chrget = $70
L7857 = $7857
L7C00 = $7C00
L7C11 = $7C11
filename = $7fa0
drive_sel_f = $7fb1
latch = $e900
l_ead1 = $EAD1
restore = $eb5e
write_a_sector = $ED3A
find_file = $EE33
load_file = $EE9E
not_found = $EEE6
input_hex_addr = $EEFB
input_hex_word = $EF08
l_ef59 = $EF59
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

    jsr l_ef59          ;A = character

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
    beq jmp_exec_file
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
jmp_exec_file:
    jmp exec_file

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
    jmp l_ead1

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
    sta filename,y
    iny
    cpy #$05
    bmi ext1

    ;Set last char of filename to command character
    pla
    sta filename+$05

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
    sta filename,y
    iny
    cpy #$07
    bmi L7AAC
L7ABB:
    lda #' '
L7ABD:
    cpy #$06
    bpl L7AC7
    sta filename,y
    iny
    bne L7ABD
L7AC7:
    jsr chrin
    jsr L7ADB
    sta drive_sel_f
    rts

L7AD1:
    lda #<enter_device
    ldy #>enter_device
    jsr puts
    jsr l_ef59
L7ADB:
    cmp #'0'
    bmi L7AD1
    cmp #'3'
    bpl L7AD1
    and #$03
    tax
    lda $EA2F,x
    rts

load_prog:
;L-LOAD DISK PROGRAM
;
    jsr try_load_file
    jmp pdos_prompt

try_load_file:
    jsr input_filename
    jsr load_file
    txa
    bne L7B11
    ldy #$0A
    lda (dir_ptr),y
    cmp #$05
    beq L7B04
    jmp bad_cmd_or_file
L7B04:
    ldy #$06
    lda (dir_ptr),y
    sta edit_ptr
    iny
    lda (dir_ptr),y
    sta edit_ptr+1
    lda #$00
L7B11:
    rts

exec_file:
;X-EXECUTE DISK FILE
;
    jsr try_load_file
    bne jmp_pdos_prompt
    jmp jsr_edit_ptr

goto_memory:
;G-GO TO MEMORY
;
    lda #$0D
    jsr chrout
    jsr input_hex_addr
jsr_edit_ptr:
    jsr jmp_edit_ptr
jmp_pdos_prompt:
    jmp pdos_prompt
jmp_edit_ptr:
    jmp (edit_ptr)

save_prog:
;S-SAVE A PROGRAM
;
    jsr input_filename
    lda #$0D
    jsr chrout
    jsr input_hex_addr
    lda edit_ptr
    sta filename+$08
    lda edit_ptr+1
    sta filename+$09
    lda #'-'
    jsr chrout
    jsr input_hex_word
    lda edit_ptr
    clc
    adc #$7F
    php
    sec
    sbc filename+$08
    sta hex_save_a
    lda edit_ptr+1
    sbc filename+$09
    plp
    adc #$00
    asl hex_save_a
    rol ;a
    sta filename+$0e
    lda #$00
    sta filename+$0f
    lda #<enter_entry
    ldy #>enter_entry
    jsr puts
    jsr input_hex_word
    lda #$0D
    jsr chrout
    lda edit_ptr
    sta filename+$06
    lda edit_ptr+1
    sta filename+$07
    lda #$05
    sta filename+$0a
    jsr find_file
    bmi L7B90
    tax
    beq L7BE2
    jsr L7857
L7B90:
    jmp pdos_prompt

kill_file:
;K-KILL A FILE
;
    ;Print "** DELETE-" prompt for filename to delete
    lda #<enter_kill
    ldy #>enter_kill
    jsr puts

    jsr input_filename

    jsr find_file
    tax
    bmi L7BAE
    bne L7BB1

    lda #$FF
    ldy #$05
    sta (dir_ptr),y
    jsr write_a_sector
L7BAE:
    jmp pdos_prompt
L7BB1:
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
