latch        = $e900    ;Drive Select Latch
                        ;  bit function
                        ;  === ======
                        ;  7-4 not used
                        ;  3   motor ??
                        ;  2   drive 3 select
                        ;  1   drive 2 select
                        ;  0   drive 1 select

;In the zero page locations below, ** indicates the PEDISK destroys
;a location that is used for some other purpose by CBM BASIC 4.

valtyp      = $07       ;Data type of value: 0=numeric, $ff=string
intflg      = $08       ;Type of number: 0=floating point, $80=integer
linnum      = $11       ;2 byte integer (usually a line number) from linget
dir_ptr     = $22       ;Pointer: PEDISK directory **
hex_save_a  = $26       ;PEDISK temporarily saves A during hex conversion **
edit_pos    = $27       ;PEDISK memory editor position on current line **
txttab      = $28       ;Pointer: Start of BASIC text
vartab      = $2a       ;Pointer: Start of BASIC variables
varpnt      = $44       ;Pointer: Current BASIC variable
open_track  = $56       ;Next track open for a new file **
open_sector = $57       ;Next sector open for a new file **
edit_ptr    = $66       ;Pointer: PEDISK current address of memory editor **
chrget      = $70       ;Subroutine: Get Next Byte of BASIC Text (patched)
txtptr      = $77       ;Pointer: Current Byte of BASIC Text
target_ptr  = $b7       ;Pointer: PEDISK target address for memory ops **

dos         = $7800     ;Base address for the RAM-resident portion
file_infos  = dos+$0680 ;4 buffers of 32 bytes each for tracking open files
dir_sector  = dos+$0700 ;128 bytes for directory sector used by find_file
wedge_x     = dos+$0789 ;Temp storage for X register used by the wedge
wedge_y     = dos+$078a ;Temp storage for Y register used by the wedge
wedge_sp    = dos+$078b ;Temp storage for stack pointer used by the wedge
file_num    = dos+$078f ;File number (0-3) of currently open file
drive_sel   = dos+$0791 ;Drive select bit pattern to write to the latch
track       = dos+$0792 ;Track number to write to WD1793 (0-76 or $00-4c)
sector      = dos+$0793 ;Sector number to write to WD1793 (1-26 or $01-1a)
num_sectors = dos+$0796 ;Number of sectors to read or write
dir_entry   = dos+$07a0 ;16 byte buffer for a directory entry
wedge_stack = dos+$07e0 ;32 bytes for preserving the stack used by the wedge
drive_sel_f = dos+$07b1 ;Drive select bit pattern parsed from a filename
fi_pos      = dos+$07b2 ;2 bytes for record position used with FI% variable
fc_error    = dos+$07b5 ;Error code that will be set in FC% variable
linget      = $b8f6     ;BASIC Fetch integer (usually a line number)
ptrget      = $c12b     ;BASIC Find a variable

check_colon    = $EA44
deselect_drive = $EB0B
restore        = $EB5E
put_spc        = $EB7A
put_spc_hex    = $EB7F
put_hex_byte   = $EB84
disk_error     = $EC96
read_a_sector  = $ECDF
read_sectors   = $ECE4
write_a_sector = $ED3A
write_sectors  = $ED3F
find_file      = $EE33
load_file      = $EE9E
not_found      = $EEE6
input_hex_word = $EF08
get_char_w_stop= $EF59
edit_memory    = $EF83
puts           = $EFE7
chrout         = $FFD2

e_exists = $05 ;File Exists

    *=dos

dos_save:   jmp _dos_save   ;Perform !SAVE
dos_open:   jmp _dos_open   ;Perform !OPEN
dos_close:  jmp _dos_close  ;Perform !CLOSE
dos_input:  jmp _dos_input  ;Perform !INPUT
dos_print:  jmp _dos_print  ;Perform !PRINT
dos_run:    jmp _dos_run    ;Perform !RUN
dos_sys:    jmp _dos_sys    ;Perform !SYS
dos_list:   jmp _dos_list   ;Perform !LIST

save_from_basic:
;TODO Implements !SAVE command; _dos_save jumps here immediately
    lda vartab
    sec
    sbc txttab
    sta dir_entry+$06   ;File size low byte
    sta $58

    lda vartab+1
    sbc txttab+1
    sta $59
    sta dir_entry+$07   ;File size high byte

    lda txttab
    sta dir_entry+$08   ;Load address low byte

    lda txttab+1
    sta dir_entry+$09   ;Load address high byte

    jsr calc_n_sectors  ;Calculate num_sectors from file size in $58/59
    lda num_sectors
    sta dir_entry+$0e   ;File sector count low byte

    lda #$00
    sta dir_entry+$0f   ;File sector count high byte

    lda #$03            ;Type 3 = BASIC program
    sta dir_entry+$0a   ;File type

    jsr find_file
    tax
    bmi save_done       ;Branch if a disk error occurred
    bne L7857           ;Branch if the file was not found

    lda #e_exists       ;Set error code $05, file exists error
save_error:
    jsr disk_error      ;Print error msg, FDC restore cmd, deselect drive
    bne save_done       ;Branch always

L7857:
;TODO Monitor command "S" (save file) jumps here to perform the save
;
    lda #$00
    sta dir_entry+$0b   ;TODO ??

    jsr L78A2
    bne save_done       ;Branch if an error occurred
    lda fc_error
    beq L786A           ;Branch if no error

    lda #$06            ;A = 6, TODO error number for ??
    bne save_error      ;Branch always

L786A:
    lda dir_entry+$08   ;File load address low byte
    sta target_ptr

    lda dir_entry+$09   ;File load address high byte
    sta target_ptr+1

    lda open_track
    sta track

    lda open_sector
    sta sector

    lda dir_entry+$0e   ;File sector count low byte
    sta num_sectors

    jsr write_sectors
    bne save_done       ;Branch if a disk error occurred
    lda #$00
    sta latch           ;Drive Select Latch
    lda #$00
save_done:
    rts

calc_n_sectors:
;TODO seems to calculate num_sectors from file size in $58/59
    lda $58
    clc
    adc #$7F            ;$7F = 128 byte sector - 1
    bcc L789A
    inc $59
L789A:
    asl ;a
    lda $59
    rol ;a
    sta num_sectors
    rts

L78A2:
;TODO called from L7857 (monitor save command) and open_create
;is this create a file?
    lda #$00            ;FC% error code for OK
    sta fc_error

    lda open_track
    sta dir_entry+$0c   ;File track number

    lda open_sector
    sta dir_entry+$0d   ;File sector number

    jsr L78F1
    lda $58
    cmp #$51
    bmi L78C0
    lda #$2B            ;TODO FC% error code for ??
    sta fc_error
    rts

L78C0:
    ldy #$0F
L78C2:
    lda dir_entry,y
    sta (dir_ptr),y
    dey
    bpl L78C2
    lda sector
    cmp #$01
    beq L78E0
    jsr write_a_sector
    bne save_done       ;Branch if a disk error occurred
    lda #$01
    sta sector
    jsr read_a_sector
    bne save_done       ;Branch if a disk error occurred
L78E0:
    inc dir_sector+$08  ;Increment number of used file entries

    lda $58
    sta dir_sector+$09  ;Set next open track

    lda $59
    sta dir_sector+$0a  ;Set next open sector

    jsr write_a_sector
    rts

L78F1:
    jsr L790D
    lda dir_entry+$0d   ;File sector number
    clc
    adc $59
    cmp #$1D            ;TODO Past last sector?  28 sectors per track on 5.25"
    bmi L7902
    sbc #$1C            ;TODO 28 sectors per track?
    inc $58
L7902:
    sta $59
    lda dir_entry+$0c   ;File track number
    clc
    adc $58
    sta $58
    rts

L790D:
    lda dir_entry+$0e   ;File sector count low byte
    sec
    sbc #$01
    sta $5E
    lda dir_entry+$0f   ;File sector count high byte
    sbc #$00
    sta $5F
    lda #$1C            ;TODO 28 sectors per track?
    sta $60
    lda #$00
    sta $61
    jsr L797B
    ldx $5E
    inx
    stx $59
    lda $62
    sta $58
    rts

L7931:
    jsr L7948
    ldx #$10
L7936:
    jsr L7953
    bcc L793E
    jsr L7958
L793E:
    dex
    beq L7947
    jsr L7972
    jmp L7936
L7947:
    rts

L7948:
    lda #$00
    sta $62
    sta $63
    sta $64
    sta $65
    rts

L7953:
    asl $5E
    rol $5F
    rts

L7958:
    lda $60
    clc
    adc $62
    sta $62
    lda $61
    adc $63
    sta $63
    lda #$00
    adc $64
    sta $64
    lda #$00
    adc $65
    sta $65
    rts

L7972:
    asl $62
    rol $63
    rol $64
    rol $65
    rts

L797B:
    ldx #$00
    stx $62
    stx $63
    cpx $60
    bne L798E
    cpx $61
    bne L798E
    stx $5E
    stx $5F
L798D:
    rts

L798E:
    lda $61
    cmp $5F
    bcc L799E
    bne L79AB
    lda $60
    cmp $5E
    beq L799E
    bcs L79AB
L799E:
    inx
    asl $60
    rol $61
    bcc L798E
    dex
    ror $61
    jmp L79B0
L79AB:
    dex
    bmi L798D
    lsr $61
L79B0:
    ror $60
    sec
    lda $5E
    sbc $60
    pha
    lda $5F
    sbc $61
    php
    rol $62
    rol $63
    plp
    bcs L79C8
    pla
    jmp L79AB
L79C8:
    sta $5F
    pla
    sta $5E
    jmp L79AB

_dos_sys:
;Perform !SYS
;Enter PDOS monitor mode.
;
;Usage: !SYS (accepts no arguments)
;
    lda #<dos_stop      ;Load address low byte
    sta target_ptr
    lda #>dos_stop      ;Load address high byte
    sta target_ptr+1

    ldx #$00            ;Set track 0 (first track)
    stx track           ;Track number to write to WD1793 (0-76 or $00-4c)

    inx                 ;Increment to 1 (drive select pattern for drive 0)
    stx drive_sel       ;Drive select bit pattern to write to the latch

    lda #$16            ;Set sector 22
    sta sector          ;Sector number to write to WD1793 (1-26 or $01-1a)

    lda #$04
    sta num_sectors     ;Number of sectors to read or write

    jsr read_sectors
    bne sys_disk_err    ;Branch if a disk error occurred
    jmp dos_stop

sys_disk_err:
    jmp restore         ;Restore top 32 bytes of the stack page and return

l_79f6: ;dos+$01f6
    !byte $b3,$fa,$40,$00,$00,$40,$20,$00,$34,$01

dos_stop:
fi_or_fc:
    !text "FI%",0

_dos_save:
;Perform !SAVE
;Save a program to disk.
;
;Usage: !SAVE"NAME:0"
;
    jsr save_from_basic
    jmp restore         ;Restore top 32 bytes of the stack page and return

get_file_num:
;Get the file number of an already opened file
;from its filename and drive.
;
;Open files are stored in the file_infos table.  There are 4
;possible open files, numbered 0 to 3.  Each open file is
;represented by 32 bytes in file_infos.  The first 16 bytes are
;the file's directory entry, followed by 1 byte for the drive
;select pattern.
;
;Calling parameters:
;  dir_entry: first 6 bytes only with the filename
;  drive_sel_f: drive select pattern of the drive
;
;Returns:
;  file_num: File number (0..3) if found, or $FF if not found
;  X = same as file_num
;
    ldx #$03            ;Counts down possible file numbers 3..0

    ;Initialize pointer to last open file in file_infos
    lda #>(file_infos+(3*$20))
    sta dir_ptr+1
    lda #<(file_infos+(3*$20))

gfn_loop:
    sta dir_ptr         ;Set pointer to file_infos low byte

    ;Check if requested filename matches current file in file_infos
    ldy #$05            ;Counts down filename chars 5..0
gfn_fname_loop:
    lda (dir_ptr),y     ;Get a filename byte from open file info
    cmp dir_entry,y     ;Compare it to filename we want
    bne gfn_next        ;Not a match? Go to next file info.
    dey                 ;Decrement filename index
    bpl gfn_fname_loop  ;Loop until entire filename is checked

    ;Check if requested drive select pattern matches current in file_infos
    ldy #$11            ;Set index to drive select pattern in file info
    lda (dir_ptr),y     ;Get drive select pattern in file info
    cmp drive_sel_f     ;Compare it to drive select pattern we want
    bne gfn_next        ;Not a match? Go to next file info.

gfn_found:
    stx file_num
    rts

gfn_next:
    dex                 ;Decrement to next file number
    bmi gfn_found       ;Past zero?  Return file number of $FF

    lda dir_ptr         ;Get low byte of file_infos pointer
    sec
    sbc #$20            ;Subtract $20 to move to next file info
    bne gfn_loop        ;Branch always

_dos_open:
;Perform !OPEN
;
;Open a sequential (SEQ) file for reading or writing.
;
;A sequential file is a set of records.  A record is a variable length string
;of 127 bytes or less.  A record is written with the !PRINT command and read
;with !INPUT.  Each record occupies one sector (128 bytes), where the first
;byte of the sector stores the record length (0-127).  The total number of
;records in the file is set when the file is created, and is the same as the
;file's sector count (offsets $0E-$0F in the directory entry).
;
;Usage: !OPEN "NAME:0"            (open an existing SEQ file)
;       !OPEN "NAME:0" NEW        (create SEQ file with default 100 records)
;       !OPEN "NAME:0" NEW LEN 35 (create SEQ file with 35 records)
;
;Filename may be specified as a variable (F$) or immediate ("NAME:0").
;
    ;Check if file is already open
    jsr get_file_num    ;X=file number from filename or $FF if not open
    inx                 ;Increment X to test it for $FF
    beq open_find_num   ;Equal to $FF?  File not open, branch to continue

    ;File is already open
    lda #$30            ;FC% error code for file already open error
    bne open_err_1      ;Branch always; go to seq_cmd_error

open_find_num:
    ;Init to look for free buffer in file_infos
    ldx #$03            ;Init X for counting down 4 file numbers (3..0)
    ldy #(3*$20)        ;Init Y index for first byte of last file info

open_find_loop:
    ;Check if this file info is available to be used
    lda file_infos,y    ;Get first byte of filename from file info
    cmp #$FF            ;Is this file info unused?
    beq open_found_num  ;  Yes: branch, we'll use this file info
    dex                 ;Decrement file number
    bpl open_find_next  ;File number >= 0? Branch to try next file info

    ;No free space in file_infos, all 4 buffers are in use
    lda #$31            ;FC% error code for too many open files error
    bne open_err_1      ;Branch always; go to seq_cmd_error

open_find_next:
    ;Move to the next file info and loop
    tya                 ;Y->A so we can subtract it
    sec
    sbc #$20            ;Subtract $20 to move index to next file info
    tay                 ;A->Y
    jmp open_find_loop  ;Loop to check if it is available to be used

open_found_num:
    ;Found an open file number, it's in X
    stx file_num        ;Save file number in file_num

    ;Try to find the file on disk (may or may not exist)
    jsr find_file       ;A=0 found, A=$7F not found, A=$FF disk error
    bpl open_check_new  ;Branch if no disk error occurred

    ;Disk error occurred and was printed
    jmp restore         ;Restore top 32 bytes of the stack page and return

open_check_new:
    ;Check if NEW keyword was specified
    pha                 ;Push find_file status onto stack
    jsr chrget+$06
    cmp #$A2            ;CBM BASIC token for NEW
    bne open_not_new    ;Branch if NEW was not specified

    ;NEW keyword was specified so we are creating a new file.
    ;Ensure that the file does not already exist.
    pla                 ;Pull find_file status off stack
    bne open_new        ;Branch if file was not found on disk

    ;Trying to create a new file but filename already exists.
    lda #$32            ;FC% error code for file exists
open_err_1:
    bne open_err_2      ;Branch always; go to seq_cmd_error

open_new:
    ;Create a new file on disk and open it

    lda #$64            ;A = default of 100 records
    sta dir_entry+$0e   ;Set file sector count low byte
    lda #$80
    sta dir_entry+$06   ;File size low byte
    sta dir_entry+$08   ;Load address low byte
    lda #$00
    sta dir_entry+$07   ;File size high byte
    sta dir_entry+$09   ;Load address high byte
    sta dir_entry+$0a   ;File type (0=SEQ)
    sta dir_entry+$0b   ;TODO ??
    sta dir_entry+$0f   ;File sector count high byte

    ;Check if LEN keyword was specified
    jsr chrget          ;Get next byte of BASIC text
    cmp #$C3            ;CBM BASIC token for LEN
    bne open_create     ;Branch if LEN was not specified

    ;LEN keyword was specified

    jsr chrget          ;Get next byte of BASIC text
    bcs open_handle_len ;TODO what does carry set mean?

    ;Set record count from text (e.g. 123 from "!OPEN F$ NEW LEN 123")
    jsr linget          ;Fetch integer into linnum
    lda linnum          ;A = low byte of integer
    sta dir_entry+$0e   ;Set file sector count low byte
    lda linnum+1        ;A = high byte of integer
    sta dir_entry+$0f   ;Set file sector count high byte

open_create:
    ;Create a new file on disk
    jsr L78A2
    bne open_create_err ;Branch if an error occurred
    beq open_done       ;Branch always

open_handle_len:
    jsr ptrget          ;Find variable

    ;Check if LEN argument is numeric
    lda valtyp          ;A = type of variable (0=numeric, $ff=string)
    bne open_len_str    ;Branch if variable is not numeric

    ;LEN argument is numeric
    ;Check if it is an integer
    bit intflg          ;Test type of numeric (0=floating point, $80=integer)
    bmi open_set_len    ;Branch if integer

    ;LEN argument is a float
    lda #$34            ;FC% error code for LEN argument not an integer
    bne open_err_2      ;Branch always; go to seq_cmd_error

open_len_str:
    ;LEN argument is not numeric
    lda #$35            ;FC% error code for LEN argument not numeric
    bne open_err_2      ;Branch always; go to seq_cmd_error

open_set_len:
    ;LEN argument is a valid integer, set sector count from it
    ldy #$00
    lda (varpnt),y
    sta dir_entry+$0f   ;File sector count high byte
    iny
    lda (varpnt),y
    sta dir_entry+$0e   ;File sector count low byte
    jmp open_create

open_not_new:
    ;NEW keyword was not specified so we are trying to open a file
    ;that already exists on disk.  Ensure the file does not already exist.
    pla                 ;Pull find_file status off stack
    beq open_existing   ;Branch find_file found the file on disk

    ;Trying to open an existing file but it doesn't exist.
    lda #$32            ;FC% error code for file found
open_err_2:
    jmp seq_cmd_error   ;Jump out to finish this command on error

open_existing:
    ;Open an existing file on disk

    ldy #$0F
L7AE0:
    lda (dir_ptr),y
    sta dir_entry,y
    dey
    bpl L7AE0

open_done:
    lda #$00
    sta fi_pos
    sta fi_pos+1
    sta fc_error
    lda dir_entry+$0c   ;File track number
    sta $7FBA
    ldx dir_entry+$0d   ;File sector number
    dex
    stx $7FBB
                        ;Fall through into seq_cmd_done

seq_cmd_done:
    ;Set variable FI% to value in fi_pos/fi_pos+1
    jsr ptrget_fi       ;Find variable FI%
    ldy #$00
    lda fi_pos+1
    sta (varpnt),y
    iny
    lda fi_pos
    sta (varpnt),y

    ;Set variable FC% to value in fc_error
    jsr ptrget_fc       ;Find variable FC%
    ldy #$00
    lda #$00
    sta (varpnt),y
    lda fc_error
    iny
    sta (varpnt),y

    jsr file_num_to_xy

L7B22:
    lda dir_entry,y
    sta file_infos,x
    dex
    dey
    bpl L7B22

open_create_err:
    jmp restore         ;Restore top 32 bytes of the stack page and return

file_num_to_xy:
    lda file_num
    asl ;a
    asl ;a
    asl ;a
    asl ;a
    asl ;a
    adc #$1F
    tax
    ldy #$1F
    rts

seq_cmd_error:
;Sequential file command error has occurred.  Set the error code
;that will be stored in the FC% variable, consume any bytes of BASIC
;text remaining in the current statement, and jump to seq_cmd_done
;to finish up.
;
;A = error code that will be stored in the FC% variable
;
    sta fc_error        ;Store A so it will become the FC% variable

    ldy #$00
    lda (txtptr),y      ;Peek at next byte of BASIC text
stmt_loop:
    cmp #$00            ;Is it the end of current BASIC line?
    beq stmt_done       ;  Yes: branch, we're done consuming BASIC text

    cmp #':'            ;Is it the end of the current BASIC statement?
    beq stmt_done       ;  Yes: branch, we're done consuming BASIC text

    jsr chrget          ;Consume the byte of BASIC text (it will be ignored)
    jmp stmt_loop       ;Loop until end of current statement or line
stmt_done:
    jmp seq_cmd_done

ptrget_fi:
;Find the variable FI% using ptrget
;
    lda #'I'            ;A = "I" to make "FI%"
    bne ptrget_fc_or_fi ;Branch always

ptrget_fc:
;Find the variable FC% using ptrget
;
    lda #'C'            ;A = "C" to make "FC%""
                        ;Fall through into ptrget_fc_or_fi

ptrget_fc_or_fi:
    ;Store A making fi_or_fi into "FC%" or "FI%"
    sta fi_or_fc+1

    ;Save the current txtptr on the stack
    lda txtptr
    pha
    lda txtptr+1
    pha

    ;Set txtptr to address of "FI%" or "FC%" string
    lda #<fi_or_fc
    sta txtptr
    lda #>fi_or_fc
    sta txtptr+1

    ;Find variable FC% or FI%
    jsr ptrget

    ;Restore original value of txtptr and return
    pla
    sta txtptr+1
    pla
    sta txtptr
    rts

_dos_close:
;Perform !CLOSE
;
;Close an open sequential (SEQ) file.
;See _dos_open for a description of sequential files.
;
;Usage: !CLOSE F$
;       !CLOSE F$ END  (TODO what does END mean? truncate file?)
;
;Filename may be specified as a variable (F$) or immediate ("NAME:0").
;
    jsr handle_filename ;TODO this must handle the filename

    ldy #$00
    lda (txtptr),y      ;Peek at next byte of BASIC text
    cmp #$80            ;Is it the CBM BASIC token for END?
    bne L7B91           ;  No: branch to ??? TODO

    jsr chrget          ;Consume the END token
    jsr no_pos_keyword
    lda #$FF
    sta dir_sector
    jsr write_a_sector
    bne close_disk_err  ;Branch if a disk error occurred
L7B91:
    lda #$FF
    sta dir_entry
    sta fc_error
    lda #$00
    sta latch
    lda #$FF
    jmp seq_cmd_done
close_disk_err:
    jmp restore         ;Restore top 32 bytes of the stack page and return

handle_filename:
;TODO called from _dos_print, _dos_open, _dos_close
    jsr get_file_num    ;X=file number from filename or $FF if not open
    inx                 ;Increment X to test for $FF
    bne L7BB1           ;Not equal to $FF?  File open, branch to continue

    lda #$07            ;FC% error code for file not open error
    jmp seq_cmd_error   ;Jump out to finish this command on error

L7BB1:
    jsr file_num_to_xy
L7BB4:
    lda file_infos,x
    sta dir_entry,y
    dex
    dey
    bpl L7BB4
    lda #$00
    sta fc_error
    rts

handle_pos:
;TODO called from _dos_print and _dos_input
    ldy #$00
    lda (txtptr),y      ;Peek at next byte of BASIC text
    cmp #$B9            ;CBM BASIC token for POS
    bne no_pos_keyword  ;Branch if POS was not specified

    jsr chrget          ;Consume the POS token
    jsr ptrget_fi       ;Find variable FI%
    ldy #$00
    lda (varpnt),y
    sta fi_pos+1
    iny
    lda (varpnt),y
    sta fi_pos
    ora fi_pos+1
    bne pos_nonzero
    lda #$08            ;FC% error code for position out of range
    jmp seq_cmd_error   ;Jump out to finish this command on error

pos_nonzero:
    lda fi_pos
    sec
    sbc #$01
    sta $5E
    lda fi_pos+1
    sbc #$00
    sta $5F
    lda #$1C            ;TODO 28 sectors per track?
    sta $60
    lda #$00
    sta $61
L7C00:
    jsr L797B
    lda $5E
    clc
    adc dir_entry+$0d   ;File sector number
    pha
    lda $62
    adc dir_entry+$0c   ;File track number
    sta $7FBA
    pla
    cmp #$1D            ;TODO Past last sector?  28 sectors per track on 5.25"
    bcc L7C1C
    inc $7FBA
    sbc #$1C            ;TODO 28 sectors per track?
L7C1C:
    sta $7FBB
    jmp L7C3C

no_pos_keyword:
    inc fi_pos
    bne L7C2A
    inc fi_pos+1
L7C2A:
    inc $7FBB
    lda $7FBB
    cmp #$1D            ;TODO Past last sector?  28 sectors per track on 5.25"
    bcc L7C3C
    inc $7FBA
    lda #$01
    sta $7FBB
L7C3C:
    lda $7FBA
    sta track
    cmp $7FBC
    bcc L7C56
    bne L7C51
    lda $7FBB
    cmp $7FBD
    bcc L7C56
L7C51:
    lda #$08            ;FC% error code for position out of range
    jmp seq_cmd_error   ;Jump out to finish this command on error

L7C56:
    lda $7FBB
    sta sector
    lda #<dir_sector
    sta target_ptr
    lda #>dir_sector
    sta target_ptr+1
    lda drive_sel_f
    sta drive_sel
    rts

_dos_input:
;Perform !INPUT
;
;Read a record from an open sequential (SEQ) file.
;See _dos_open for a description of sequential files.
;
;Usage: !INPUT "NAME:0" A$        (read record at current position into A$)
;       !INPUT "NAME:0" POS A$    (read record at position in FI% into A$)
;
;Filename may be specified as a variable (F$) or immediate ("NAME:0").
;Optional POS keyword sets position to value in FI% (starts at 1, not 0)
;Last argument is a variable that will receive the record data.
;
    jsr handle_filename ;TODO this must handle the filename
    jsr handle_pos      ;TODO handle possible POS keyword

    ;Read the sector from disk
    jsr read_a_sector
    bne input_disk_err  ;Branch if a disk error occurred

    ;Get the variable that will receive the record data
    jsr ptrget          ;Find variable
    bit valtyp          ;Test type of variable (0=numeric, $ff=string)
    bmi input_got_str   ;Branch if variable is a string

    lda #$09            ;FC% error code for "Not a string"
input_err:
    jmp seq_cmd_error   ;Jump out to finish this command on error

input_got_str:
    ;Get record length
    lda dir_sector      ;Get length of record (normally 0-127)

    ;Check for end of records marker
    cmp #$FF            ;TODO end of records?
    beq input_err       ;If so, branch to error exit

    ;Check record length is sane
    cmp #$80            ;Compare with 128 (the size of a disk sector)
    bcc input_len_ok    ;If less than 128, the record length is valid (0-127),
                        ;  so we continue.

    ;Record would be longer than 127 bytes
    lda #$0A            ;TODO error code for "Record too long"?
    bne input_err       ;Branch always to error exit

input_len_ok:
    ;TODO finish disassembly
    ldy #$00
    sta (varpnt),y
    iny
    lda #$01
    sta (varpnt),y
    iny
    lda #$7F
    sta (varpnt),y
    jmp seq_cmd_done

input_disk_err:
    jmp restore         ;Restore top 32 bytes of the stack page and return

_dos_print:
;Perform !PRINT
;
;Write a record to an open sequential (SEQ) file.
;See _dos_open for a description of sequential files.
;
;Usage: !PRINT "NAME:0" A$        (write record in A$ at current position)
;       !PRINT "NAME:0" POS A$    (write record in A$ at position in FI%)
;
;Filename may be specified as a variable (F$) or immediate ("NAME:0").
;Optional POS keyword sets position to value in FI% (starts at 1, not 0)
;Last argument is variable to read record data from (TODO can this be immediate?)
;and must be 127 bytes or less.
;
    jsr handle_filename ;TODO this must handle the filename
    jsr handle_pos      ;TODO handle possible POS keyword

    ;Get the variable that will provide the record data
    jsr ptrget          ;Find variable, sets valtyp and varpnt
    bit valtyp          ;Test type of variable (0=numeric, $ff=string)
    bmi print_got_str   ;Branch if variable is a string

    ;Variable is not a string
    lda #$09            ;FC% error code for "Not a string"
print_err:
    jmp seq_cmd_error   ;Jump out to finish this command on error

print_got_str:
    ;Check that the string length is 127 bytes or less
    ldy #$00            ;Y=0 index string length byte
    lda (varpnt),y      ;Get length of string variable
    cmp #$80            ;Compare with 128 (the size of a disk sector)
    bcc print_str_ok    ;If less than 128, the variable will fit as a record,
                        ;  so we continue.  A sector is 128 bytes, but the first
                        ;  byte is used for the record length.

    ;String is longer than 127 bytes, so it won't fit as a record
    lda #$0A            ;TODO error code for "Record too long"?
    bne print_err       ;Branch always to error exit

print_str_ok:
    ;String is valid as a record, set record length
    sta dir_sector      ;Store the string length in the first byte of
                        ;  the sector buffer

    ;Set dir_ptr to point to the string data in memory
    iny                 ;Increment Y to point to low byte of string pointer
    lda (varpnt),y      ;Get low byte of string data pointer
    sta dir_ptr         ;Copy it into the dir_ptr low byte
    iny                 ;Increment Y to point to high byte of string pointer
    lda (varpnt),y      ;Get high byte of string data pointer
    sta dir_ptr+1       ;Copy it into the dir_ptr high byte

    ;Copy 127 bytes from string data buffer into the sector buffer
    ;The first byte of the sector is the record length, the other 127 bytes
    ;hold the record data.
    ldy #$7E            ;Y = 127 minus 1 to count down string data bytes
print_copy_loop:
    lda (dir_ptr),y     ;Get byte from string data
    sta dir_sector+1,y  ;Store in sector buffer (+1 is for the length byte)
    dey                 ;Decrement Y to move to next string data byte
    bpl print_copy_loop ;Keep going until 127 bytes are copied

    ;Write the sector to disk
    jsr write_a_sector
    bne input_disk_err  ;Branch if a disk error occurred

    jmp seq_cmd_done

_dos_run:
;Perform !RUN
;Load and run a BASIC program.
;
;Usage: !RUN"NAME:0"
;
    jsr load_file
    txa
    bne run_disk_err    ;Branch if load failed
    lda #<run_text
    sta txtptr
    lda #>run_text
    sta txtptr+1
    ldx #$1F
    sei
run_stack_loop:
    lda wedge_stack,x
    sta $01E0,x
    dex
    bpl run_stack_loop
    ldx wedge_sp
    txs
    cli
    ldy wedge_y
    ldx wedge_x
    lda #$8A            ;CBM BASIC token for RUN
    jmp check_colon
run_text:
    !byte $8a           ;CBM BASIC token for RUN
    !byte 0             ;End of BASIC line
    !byte 0,0           ;End of BASIC program
run_disk_err:
    jmp restore         ;Restore top 32 bytes of the stack page and return

_dos_list:
;Perform !LIST
;List the disk directory
;
;Usage: !LIST (accepts no arguments)
;
    ;Print "DEVICE?"
    lda #<device
    ldy #>device
    jsr puts

    ;Get a character until it is a valid drive number
    jsr get_char_w_stop ;Get a character and test for {STOP}
    cmp #'0'
    bmi _dos_list
    cmp #'4'
    bpl _dos_list

    jmp L7D83           ;Jump over the strings

device:
    !text $0d,$0d,"DEVICE?",0
more:
    !text $0d,"MORE..",0
diskname:
    !text $93,"DISKNAME= ",0
dirheader:
    !text $0d,$0d,"NAME  TYPE TRK SCTR #SCTRS",0
filetypes:
    !text "SEQ",0
    !text "IND",0
    !text "ISM",0
    !text "BAS",0
    !text "ASM",0
    !text "LD ",0
    !text "TXT",0
    !text "OBJ",0

    ;Convert char to a drive select bit pattern, store the pattern

L7D83:
    and #$03
    tax
    sec
L7D87:
    rol ;a
    dex
    bpl L7D87
    sta drive_sel       ;Drive select bit pattern to write to the latch

    ;Set track 0

    ldx #$00
    stx track           ;Track number to write to WD1793 (0-76 or $00-4c)

    ;Set sector 1

    inx
    stx sector          ;Sector number to write to WD1793 (1-26 or $01-1a)

L7D97:
    lda #<dir_sector
    sta target_ptr
    sta dir_ptr

    lda #>dir_sector
    sta target_ptr+1
    sta dir_ptr+1

    jsr read_a_sector
    beq L7DAB           ;Branch if read succeeded
    jmp restore         ;Restore top 32 bytes of the stack page and return

    ;Print "DISKNAME= "

L7DAB:
    lda #<diskname
    ldy #>diskname
    jsr puts

    ;Print first disk name (first 8 bytes of track 0, sector 1)

    ldy #$00
    ldx #$08
L7DB6:
    lda (dir_ptr),y
    jsr chrout
    iny
    dex
    bne L7DB6

    ;Print "NAME  TYPE TRK SCTR #SCTRS"

    lda #<dirheader
    ldy #>dirheader
    jsr puts

    ;Set line number countdown until "MORE.." prompt

L7DC6:
    lda #18
    sta edit_pos

    ;Print a newline

    lda #$0D
    jsr chrout

L7DCF:
    lda dir_ptr
    clc
    adc #$10
    bpl L7DE3
    inc sector          ;Sector number to write to WD1793 (1-26 or $01-1a)
    jsr read_a_sector
    beq L7DE1           ;Branch if read succeeded
    jmp restore         ;Restore top 32 bytes of the stack page and return
L7DE1:
    lda #$00
L7DE3:
    sta dir_ptr

    ;Check for end of directory

    ldy #$00
    lda (dir_ptr),y     ;Get first byte of filename
    cmp #$FF            ;Equal to $FF?
    bne L7DF0           ;  No: continue
    jmp L7E56           ;  Yes: jump, end of directory

    ;Check if file has been deleted

L7DF0:
    ldy #$05
    lda (dir_ptr),y     ;Get last byte of filename
    cmp #$FF            ;Equal to $FF?
    beq L7DCF           ;  Yes: file is deleted, skip it
                        ;  No: continue

    ;Print a newline

    lda #$0D
    jsr chrout

    ;Print filename followed by a space

    ldy #$00
L7DFF:
    lda (dir_ptr),y
    jsr chrout
    iny
    cpy #$06
    bmi L7DFF
    jsr put_spc

    ;Set pointer to file type

    ldy #$0A
    lda (dir_ptr),y

    ;Print file type followed by a space

    asl ;a
    asl ;a
    clc
    adc #<filetypes
    ldy #>filetypes
    jsr puts
    jsr put_spc

    ;Set pointer to file track number

    ldy #$0C
    lda (dir_ptr),y

    ;Print track number in hex followed by a space

    jsr put_hex_byte
    jsr put_spc

    ;Set pointer to file sector number

    ldy #$0D
    lda (dir_ptr),y

    ;Print sector number in hex followed by two spaces

    jsr put_spc_hex
    jsr put_spc
    jsr put_spc

    ;Print high byte of sector count in hex

    ldy #$0F
    lda (dir_ptr),y
    jsr put_spc_hex

    ;Print low byte of sector count in hex

    ldy #$0E
    lda (dir_ptr),y
    jsr put_hex_byte

    dec edit_pos
    bmi L7E49
    jmp L7DCF

    ;Print "MORE.."

L7E49:
    lda #<more
    ldy #>more
    jsr puts

    jsr get_char_w_stop ;Get a character and test for {STOP}
    jmp L7DC6

    ;Print a newline

L7E56:
    lda #$0D
    jsr chrout

    jsr deselect_drive
    jsr chrget
    jmp restore         ;Restore top 32 bytes of the stack page and return

    !byte $8F
    sbc $FFF4,x
    cpy $8C
    !byte $04
    sty $1804
L7E6E:
    txa
    bcc L7E6E
    sbc $FFFF,x
    sbc $FFFF
    !byte $FF
    php
    dex
    !byte $1C
    !byte $12
    !byte $B2
    and $B506,y
