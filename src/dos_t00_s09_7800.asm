latch        = $e900    ;Drive Select Latch

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
tmp_track   = $58       ;TODO seems to hold a track
tmp_sector  = $59       ;TODO seems to hold a sector
filesize    = $58       ;2 byte file size, shared with tmp_track/tmp_sector
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
dir_entry   = dos+$07a0 ;32 bytes: a dir entry (first 16) or file info (32)
wedge_stack = dos+$07e0 ;32 bytes for preserving the stack used by the wedge
drive_sel_f = dos+$07b1 ;Drive select bit pattern parsed from a filename
fi_pos      = dos+$07b2 ;2 bytes for record position used with FI% variable
fc_error    = dos+$07b5 ;Error code that will be set in FC% variable
m_7fba_track  = dos+$07ba ;TODO seems to hold a track
m_7fbb_sector = dos+$07bb ;TODO seems to hold a sector
m_7fbc_track  = dos+$07bc ;TODO seems to hold a track
m_7fbd_sector = dos+$07bd ;TODO seems to hold a sector
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
get_char_w_stop= $EF59
puts           = $EFE7
chrout         = $FFD2

;Error codes for "disk error" message (all others in the ROM)
e_exists       = $05 ;File Exists
e_unknown_06   = $06 ;TODO Unknown

;Error codes for FC%
f_ok           = $00 ;OK
f_not_open     = $07 ;File not open
f_not_string   = $09 ;Variable is not a string
f_unknown_2b   = $2B ;TODO Unknown
f_already_open = $30 ;File already open
f_too_many     = $31 ;Too many open files
f_bad_filename = $32 ;Bad filename (file exists or file not found)
f_len_float    = $34 ;LEN argument is a float
f_len_not_num  = $35 ;LEN argument not numeric
f_unknown_ff   = $ff ;TODO Unknown

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
    sta dir_entry+$06   ;Save file size low byte in dir entry
    sta filesize        ;Save file size low byte to calculate sector count

    lda vartab+1
    sbc txttab+1
    sta filesize+1      ;Save file size high byte to calculate sector count
    sta dir_entry+$07   ;Save file size high byte in dir entry

    lda txttab
    sta dir_entry+$08   ;Save load address low byte in dir entry

    lda txttab+1
    sta dir_entry+$09   ;Save load address high byte in dir entry

    jsr calc_n_sectors  ;Calculate num_sectors from filesize
    lda num_sectors
    sta dir_entry+$0e   ;Save file sector count low byte in dir entry

    lda #$00
    sta dir_entry+$0f   ;Save file sector count high byte in dir entry

    lda #$03            ;Type 3 = BASIC program
    sta dir_entry+$0a   ;Save file type in dir entry

    jsr find_file
    tax
    bmi save_done       ;Branch if a disk error occurred
    bne l_7857          ;Branch if the file was not found

    lda #e_exists       ;Set error code $05, file exists error
save_error:
    jsr disk_error      ;Print error msg, FDC restore cmd, deselect drive
    bne save_done       ;Branch always

l_7857:
;TODO Monitor command "S" (save file) jumps here to perform the save
;
    lda #$00
    sta dir_entry+$0b   ;TODO ??

    jsr l_78a2
    bne save_done       ;Branch if an error occurred
    lda fc_error
    beq l_786a          ;Branch if no error

    lda #e_unknown_06   ;A = 6, TODO error number for ??
    bne save_error      ;Branch always

l_786a:
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

    ;Deselect drives and stop motors
    lda #$00            ;TODO disk conversion: this code always sets /DDEN=0
                        ;Bit 3 = WD1793 /DDEN=0 (double density mode)
                        ;All other bits off = deselect drives, stop motors
    sta latch

    lda #$00
save_done:
    rts

calc_n_sectors:
;TODO seems to calculate num_sectors from filesize
    lda filesize        ;Get file size low byte
    clc
    adc #$7F            ;$7F = 128 byte sector - 1
    bcc l_789a
    inc filesize+1      ;Get file size high byte
l_789a:
    asl ;a
    lda filesize+1      ;Get file size high byte
    rol ;a
    sta num_sectors
    rts

l_78a2:
;TODO called from l_7857 (monitor save command) and open_create
;is this create a file?
    lda #f_ok           ;FC% error code for OK
    sta fc_error

    lda open_track
    sta dir_entry+$0c   ;File track number

    lda open_sector
    sta dir_entry+$0d   ;File sector number

    jsr l_78f1

    lda tmp_track
    cmp #$51
    bmi l_78c0

    lda #f_unknown_2b   ;TODO FC% error code for ??
    sta fc_error
    rts

    ;Copy the directory entry at dir_entry into the entry at (dir_ptr)
l_78c0:
    ldy #$0F            ;Y = offset of last byte (a dir entry is 16 bytes)
l_78c2:
    lda dir_entry,y
    sta (dir_ptr),y
    dey
    bpl l_78c2          ;Loop until entire entry has been copied

    lda sector
    cmp #$01
    beq l_78e0

    jsr write_a_sector
    bne save_done       ;Branch if a disk error occurred

    lda #$01
    sta sector
    jsr read_a_sector
    bne save_done       ;Branch if a disk error occurred
                        ;Fall through to write sector 1

l_78e0:
    inc dir_sector+$08  ;Increment number of used file entries

    lda tmp_track
    sta dir_sector+$09  ;Set next open track

    lda tmp_sector
    sta dir_sector+$0a  ;Set next open sector

    jsr write_a_sector
    rts

l_78f1:
;TODO called from l_78a2 only
    jsr l_790d

    lda dir_entry+$0d   ;File sector number
    clc
    adc tmp_sector
    cmp #$1D            ;TODO disk conversion: Past last sector?  28 sectors per track on 5.25"
    bmi l_7902
    sbc #$1C            ;TODO disk conversion: 28 sectors per track?
    inc tmp_track
l_7902:
    sta tmp_sector
    lda dir_entry+$0c   ;File track number
    clc
    adc tmp_track
    sta tmp_track
    rts

l_790d:
;TODO called from l_78f1 only in this file
;     also called from dos_t01_s19_7c00_1_disk_compression.asm
;
    lda dir_entry+$0e   ;File sector count low byte
    sec
    sbc #$01
    sta $5E
    lda dir_entry+$0f   ;File sector count high byte
    sbc #$00
    sta $5F
    lda #$1C            ;TODO disk conversion: 28 sectors per track?
    sta $60
    lda #$00
    sta $61

    jsr divide

    ldx $5E
    inx
    stx tmp_sector
    lda $62
    sta tmp_track
    rts

mult:
;Multiple calc1 * calc2 giving calc3 (4 bytes)
;
    jsr blnk3
    ldx #$10
mllp1:
    jsr sl1
    bcc mlelp1
    jsr add23
mlelp1:
    dex
    beq mltfin
    jsr sl3
    jmp mllp1
mltfin:
    rts

blnk3:
    lda #$00
    sta $62
    sta $63
    sta $64
    sta $65
    rts

sl1:
    asl $5E
    rol $5F
    rts

add23:
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

sl3:
    asl $62
    rol $63
    rol $64
    rol $65
    rts

divide:
;Divide calc1 by calc2 giving calc3
;Remainder in calc1
;
    ldx #$00
    stx $62
    stx $63
    cpx $60
    bne divok1
    cpx $61
    bne divok1
    stx $5E
    stx $5F
divrts:
    rts

divok1:
    lda $61
    cmp $5F
    bcc dvelp1
    bne dvflp1
    lda $60
    cmp $5E
    beq dvelp1
    bcs dvflp1
dvelp1:
    inx
    asl $60
    rol $61
    bcc divok1
    dex
    ror $61
    jmp dvhigh
dvflp1:
    dex
    bmi divrts
    lsr $61
dvhigh:
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
    bcs dvsub
    pla
    jmp dvflp1
dvsub:
    sta $5F
    pla
    sta $5E
    jmp dvflp1

_dos_sys:
;Perform !SYS
;Enter PDOS monitor mode.
;
;Usage: !SYS (accepts no arguments)
;
    lda #<dos_monitor   ;Load address low byte
    sta target_ptr
    lda #>dos_monitor   ;Load address high byte
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
    jmp dos_monitor

sys_disk_err:
    jmp restore         ;Restore top 32 bytes of the stack page and return

l_79f6: ;dos+$01f6
    !byte $b3,$fa,$40,$00,$00,$40,$20,$00,$34,$01

dos_monitor:
;PDOS monitor mode (!SYS prompt) overlay code loads here
;and overwrites the code below.

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
;Open files are stored in the file_infos table.  There are 4 possible open
;files, numbered 0 to 3.  Each open file has an associated 32 byte buffer
;in file_infos.  If the first byte of a 32 byte buffer is $FF, that buffer
;is unused.  Otherwise, the first 16 bytes are the file's directory entry,
;followed by 1 byte for the drive select pattern.
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
;       !OPEN "NAME:0" NEW LEN    (TODO is this valid? seen in PEDISK newsletter issue 2)
;       !OPEN "NAME:0" NEW LEN 35 (create SEQ file with 35 records)
;       !OPEN "NAME:0" NEW LEN N% (create SEQ file with N% records)
;
;Filename may be specified as a string variable (F$) or literal ("NAME:0").
;Record count may be specified as an integer variable (N%) or literal (35).
;
    ;Check if file is already open
    jsr get_file_num    ;X=file number from filename or $FF if not open
    inx                 ;Increment X to test it for $FF
    beq open_find_num   ;Equal to $FF?  File not open, branch to continue

    ;File is already open
    lda #f_already_open ;FC% error code for file already open error
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
    lda #f_too_many     ;FC% error code for too many open files error
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
    lda #f_bad_filename ;FC% error code for file exists
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
    bcs open_len_var    ;Branch if byte is not an ASCII numeral

    ;Set record count from literal number after LEN
    ;  (e.g. "123" from "!OPEN F$ NEW LEN 123")
    jsr linget          ;Fetch integer into linnum
    lda linnum          ;A = low byte of integer
    sta dir_entry+$0e   ;Set file sector count low byte
    lda linnum+1        ;A = high byte of integer
    sta dir_entry+$0f   ;Set file sector count high byte
                        ;Fall through into open_create

open_create:
    ;Create a new file on disk
    jsr l_78a2
    bne open_create_err ;Branch if an error occurred
    beq open_done       ;Branch always

open_len_var:
    ;Try to set record count from integer variable after LEN
    ;  (e.g. "N%" from "!OPEN F$ NEW LEN N%")
    jsr ptrget          ;Find variable, sets valtyp and varpnt

    ;Check if variable after LEN is numeric
    lda valtyp          ;A = type of variable (0=numeric, $ff=string)
    bne open_len_str    ;Branch if variable is not numeric

    ;Variable after LEN is numeric
    ;Check if it is an integer
    bit intflg          ;Test type of numeric (0=floating point, $80=integer)
    bmi open_len_int    ;Branch if integer

    ;Variable after LEN is floating point but an integer is required
    lda #f_len_float    ;FC% error code for LEN argument not an integer
    bne open_err_2      ;Branch always; go to seq_cmd_error

open_len_str:
    ;Variable after LEN is a string but an integer is required
    lda #f_len_not_num  ;FC% error code for LEN argument not numeric
    bne open_err_2      ;Branch always; go to seq_cmd_error

open_len_int:
    ;Variable after LEN is an integer
    ;Set sector count from it
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
    beq open_existing   ;Branch if find_file found the file on disk

    ;Trying to open an existing file but it doesn't exist.
    lda #f_bad_filename ;FC% error code for file not found
open_err_2:
    jmp seq_cmd_error   ;Jump out to finish this command on error

open_existing:
    ;Opening an existing file on disk; find_file has already found the file
    ldy #$0F
l_7ae0:
    lda (dir_ptr),y
    sta dir_entry,y
    dey
    bpl l_7ae0

open_done:
    lda #f_ok
    sta fi_pos
    sta fi_pos+1
    sta fc_error
    lda dir_entry+$0c   ;File track number
    sta m_7fba_track
    ldx dir_entry+$0d   ;File sector number
    dex
    stx m_7fbb_sector
                        ;Fall through into seq_cmd_done

seq_cmd_done:
    ;Set variable FI% to value in fi_pos, fi_pos+1
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

    jsr file_num_to_xy  ;Set up X for file_infos and Y for 32 byte countdown

l_7b22:
    lda dir_entry,y
    sta file_infos,x
    dex
    dey
    bpl l_7b22

open_create_err:
    jmp restore         ;Restore top 32 bytes of the stack page and return

file_num_to_xy:
;Call with file number (0..3) in A
;Returns with indexes set:
;  X = offset into file_infos
;  Y = 31 for counting down 32 bytes from 31 to -1
    lda file_num
    asl ;a
    asl ;a
    asl ;a
    asl ;a
    asl ;a
    adc #$1F
    tax
    ldy #$1F            ;Y = 31 (start of 32 byte countdown from 31 to -1)
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
    ;Store A making fi_or_fc into "FC%" or "FI%"
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
;Usage: !CLOSE "NAME:0"
;       !CLOSE "NAME:0" END  (TODO what does END mean? truncate file?)
;
;Filename may be specified as a string variable (F$) or literal ("NAME:0").
;
    jsr handle_filename ;TODO this must handle the filename

    ldy #$00
    lda (txtptr),y      ;Peek at next byte of BASIC text
    cmp #$80            ;Is it the CBM BASIC token for END?
    bne l_7b91          ;  No: branch to ??? TODO

    jsr chrget          ;Consume the END token
    jsr no_pos_keyword
    lda #$FF
    sta dir_sector
    jsr write_a_sector
    bne close_disk_err  ;Branch if a disk error occurred
l_7b91:
    lda #f_unknown_ff
    sta dir_entry
    sta fc_error

    ;Deselect drives and stop motors
    lda #$00            ;Bit 3 = WD1793 /DDEN=0 (double density mode)
                        ;All other bits off = deselect drives, stop motors
    sta latch

    lda #$FF
    jmp seq_cmd_done
close_disk_err:
    jmp restore         ;Restore top 32 bytes of the stack page and return

handle_filename:
;TODO called from _dos_print, _dos_input, _dos_close
    jsr get_file_num    ;X=file number from filename or $FF if not open
    inx                 ;Increment X to test for $FF
    bne l_7bb1          ;Not equal to $FF?  File is open, branch to continue

    lda #f_not_open     ;FC% error code for file not open error
    jmp seq_cmd_error   ;Jump out to finish this command on error

l_7bb1:
    jsr file_num_to_xy  ;Set up X for file_infos and Y for dir_entry
l_7bb4:
    lda file_infos,x
    sta dir_entry,y
    dex
    dey
    bpl l_7bb4
    lda #f_ok
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

    ;Copy value in FI% into fi_pos, fi_pos+1
    ldy #$00
    lda (varpnt),y
    sta fi_pos+1
    iny
    lda (varpnt),y
    sta fi_pos

    ;Branch if position (fi_pos, fi_pos+1) is valid
    ora fi_pos+1
    bne pos_nonzero

    ;Position of 0 is invalid, set error and exit
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
    lda #$1C            ;TODO disk conversion: 28 sectors per track?
    sta $60
    lda #$00
    sta $61
l_7c00:
    jsr divide
    lda $5E
    clc
    adc dir_entry+$0d   ;File sector number
    pha
    lda $62
    adc dir_entry+$0c   ;File track number
    sta m_7fba_track
    pla
    cmp #$1D            ;TODO disk conversion: Past last sector?  28 sectors per track on 5.25"
    bcc l_7c1c
    inc m_7fba_track
    sbc #$1C            ;TODO disk conversion: 28 sectors per track?
l_7c1c:
    sta m_7fbb_sector
    jmp l_7c3c

no_pos_keyword:
    inc fi_pos
    bne l_7c2a
    inc fi_pos+1
l_7c2a:
    inc m_7fbb_sector
    lda m_7fbb_sector
    cmp #$1D            ;TODO disk conversion: Past last sector?  28 sectors per track on 5.25"
    bcc l_7c3c
    inc m_7fba_track
    lda #$01
    sta m_7fbb_sector
l_7c3c:
    lda m_7fba_track
    sta track
    cmp m_7fbc_track    ;TODO where is this ($7FBC) set?
    bcc l_7c56
    bne l_7c51
    lda m_7fbb_sector
    cmp m_7fbd_sector   ;TODO where is this ($7FBD) set?
    bcc l_7c56
l_7c51:
    lda #$08            ;FC% error code for position out of range
    jmp seq_cmd_error   ;Jump out to finish this command on error

l_7c56:
    lda m_7fbb_sector
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
;Filename may be specified as a string variable (F$) or literal ("NAME:0").
;Optional POS keyword sets position to value in FI% (starts at 1, not 0)
;Last argument is a string variable that will receive the record data.
;
    jsr handle_filename ;TODO this must handle the filename
    jsr handle_pos      ;TODO handle possible POS keyword

    ;Read the sector from disk
    jsr read_a_sector
    bne input_disk_err  ;Branch if a disk error occurred

    ;Get the variable that will receive the record data
    jsr ptrget          ;Find variable, sets valtyp and varpnt
    bit valtyp          ;Test type of variable (0=numeric, $ff=string)
    bmi input_got_str   ;Branch if variable is a string

    lda #f_not_string   ;FC% error code for "Not a string"
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
;Filename may be specified as a string variable (F$) or literal ("NAME:0").
;Optional POS keyword sets position to value in FI% (starts at 1, not 0)
;Last argument is a string variable (can't be a literal) with 127 bytes
;of data or less.
;
    jsr handle_filename ;TODO this must handle the filename
    jsr handle_pos      ;TODO handle possible POS keyword

    ;Get the variable that will provide the record data
    jsr ptrget          ;Find variable, sets valtyp and varpnt
    bit valtyp          ;Test type of variable (0=numeric, $ff=string)
    bmi print_got_str   ;Branch if variable is a string

    ;Variable is not a string
    lda #f_not_string   ;FC% error code for "Not a string"
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

    jmp l_7d83          ;Jump over the strings

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

l_7d83:
    and #$03
    tax
    sec
l_7d87:
    rol ;a
    dex
    bpl l_7d87
    sta drive_sel       ;Drive select bit pattern to write to the latch
                        ;TODO disk conversion: what does this do to bit for /DDEN?

    ;Set track 0

    ldx #$00
    stx track           ;Track number to write to WD1793 (0-76 or $00-4c)

    ;Set sector 1

    inx
    stx sector          ;Sector number to write to WD1793 (1-26 or $01-1a)

l_7d97:
    lda #<dir_sector
    sta target_ptr
    sta dir_ptr

    lda #>dir_sector
    sta target_ptr+1
    sta dir_ptr+1

    jsr read_a_sector
    beq l_7dab          ;Branch if read succeeded
    jmp restore         ;Restore top 32 bytes of the stack page and return

    ;Print "DISKNAME= "

l_7dab:
    lda #<diskname
    ldy #>diskname
    jsr puts

    ;Print first disk name (first 8 bytes of track 0, sector 1)

    ldy #$00
    ldx #$08
l_7db6:
    lda (dir_ptr),y
    jsr chrout
    iny
    dex
    bne l_7db6

    ;Print "NAME  TYPE TRK SCTR #SCTRS"

    lda #<dirheader
    ldy #>dirheader
    jsr puts

    ;Set line number countdown until "MORE.." prompt

l_7dc6:
    lda #18
    sta edit_pos

    ;Print a newline

    lda #$0D
    jsr chrout

l_7dcf:
    lda dir_ptr
    clc
    adc #$10
    bpl l_7de3
    inc sector          ;Sector number to write to WD1793 (1-26 or $01-1a)
    jsr read_a_sector
    beq l_7de1          ;Branch if read succeeded
    jmp restore         ;Restore top 32 bytes of the stack page and return
l_7de1:
    lda #$00
l_7de3:
    sta dir_ptr

    ;Check for end of directory

    ldy #$00
    lda (dir_ptr),y     ;Get first byte of filename
    cmp #$FF            ;Equal to $FF?
    bne l_7df0          ;  No: continue
    jmp l_7e56          ;  Yes: jump, end of directory

    ;Check if file has been deleted

l_7df0:
    ldy #$05
    lda (dir_ptr),y     ;Get last byte of filename
    cmp #$FF            ;Equal to $FF?
    beq l_7dcf          ;  Yes: file is deleted, skip it
                        ;  No: continue

    ;Print a newline

    lda #$0D
    jsr chrout

    ;Print filename followed by a space

    ldy #$00
l_7dff:
    lda (dir_ptr),y
    jsr chrout
    iny
    cpy #$06
    bmi l_7dff
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
    bmi l_7e49
    jmp l_7dcf

    ;Print "MORE.."

l_7e49:
    lda #<more
    ldy #>more
    jsr puts

    jsr get_char_w_stop ;Get a character and test for {STOP}
    jmp l_7dc6

    ;Print a newline

l_7e56:
    lda #$0D
    jsr chrout

    jsr deselect_drive
    jsr chrget
    jmp restore         ;Restore top 32 bytes of the stack page and return

filler:
    !byte $8F,$FD,$F4,$FF,$C4,$8C,$04,$8C,$04,$18,$8A,$90,$FD,$FD,$FF,$FF
    !byte $ED,$FF,$FF,$FF,$08,$CA,$1C,$12,$B2,$39,$06,$B5
