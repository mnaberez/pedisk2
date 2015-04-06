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
buf_1       = dos+$0680 ;Unknown, possible buffer area #1
buf_2       = dos+$06a0 ;Unknown, possible buffer area #2
buf_3       = dos+$06c0 ;Unknown, possible buffer area #3
buf_4       = dos+$06e0 ;Unknown, possible buffer area #4
dir_sector  = dos+$0700 ;128 bytes for directory sector used by find_file
wedge_x     = dos+$0789 ;Temp storage for X register used by the wedge
wedge_y     = dos+$078a ;Temp storage for Y register used by the wedge
wedge_sp    = dos+$078b ;Temp storage for stack pointer used by the wedge
drive_sel   = dos+$0791 ;Drive select bit pattern to write to the latch
track       = dos+$0792 ;Track number to write to WD1793 (0-76 or $00-4c)
sector      = dos+$0793 ;Sector number to write to WD1793 (1-26 or $01-1a)
num_sectors = dos+$0796 ;Number of sectors to read or write
dir_entry   = dos+$07a0 ;16 byte buffer for a directory entry
wedge_stack = dos+$07e0 ;32 bytes for preserving the stack used by the wedge
drive_sel_f = dos+$07b1 ;Drive select bit pattern parsed from a filename
linget      = $b8f6     ;BASIC Fetch integer (usually a line number)
ptrget      = $c12b     ;BASIC Find a variable

L3400 = $3400

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
chrin          = $FFCF
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
    bne save_done
    lda $7FB5
    beq L786A

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
    lda #$00
    sta $7FB5

    lda open_track
    sta dir_entry+$0c   ;File track number

    lda open_sector
    sta dir_entry+$0d   ;File sector number

    jsr L78F1
    lda $58
    cmp #$51
    bmi L78C0
    lda #$2B
    sta $7FB5
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
    bne L79F3           ;Branch if a disk error occurred
    jmp dos_stop

L79F3:
    jmp restore
    !byte $B3
    !byte $FA
    rti
    brk
    brk
    rti
    jsr L3400
    !byte $01

dos_stop:
    !byte $46,$49,$25,0

_dos_save:
;Perform !SAVE
;Save a program to disk.
;
;Usage: !SAVE"NAME:0"
;
    jsr save_from_basic
    jmp restore

L7A0A:
    ldx #$03
    lda #>buf_4
    sta dir_ptr+1
    lda #<buf_4
L7A12:
    sta dir_ptr
    ldy #$05
L7A16:
    lda (dir_ptr),y
    cmp dir_entry,y
    bne L7A2D
    dey
    bpl L7A16
    ldy #$11
    lda (dir_ptr),y
    cmp drive_sel_f
    bne L7A2D
L7A29:
    stx $7F8F
    rts
L7A2D:
    dex
    bmi L7A29
    lda dir_ptr
    sec
    sbc #$20
    bne L7A12

_dos_open:
;Perform !OPEN
;
;Usage: !OPEN F$ 
;       !OPEN F$ NEW LEN
; - F$ contains a filename with drive like "NAME:0"
; - TODO: Keywords "NEW" and "LEN" may optionally follow F$ and are unknown
;
    jsr L7A0A
    inx
    beq L7A41
    lda #$30
    bne L7A73
L7A41:
    ldx #$03
    ldy #$60
L7A45:
    lda buf_1,y
    cmp #$FF
    beq L7A5B
    dex
    bpl L7A53
    lda #$31
    bne L7A73
L7A53:
    tya
    sec
    sbc #$20
    tay
    jmp L7A45
L7A5B:
    stx $7F8F
    jsr find_file
    bpl L7A66           ;Branch if the file was found
    jmp restore
L7A66:
    pha
    jsr chrget+$06
    cmp #$A2            ;CBM BASIC token for NEW
    bne L7AD6
    pla
    bne L7A75
    lda #$32
L7A73:
    bne L7ADB
L7A75:
    lda #$64
    sta dir_entry+$0e   ;File sector count low byte
    lda #$80
    sta dir_entry+$06   ;File size low byte
    sta dir_entry+$08   ;Load address low byte
    lda #$00
    sta dir_entry+$07   ;File size high byte
    sta dir_entry+$09   ;Load address high byte
    sta dir_entry+$0a   ;File type (0=SEQ)
    sta dir_entry+$0b   ;TODO ??
    sta dir_entry+$0f   ;File sector count high byte
    jsr chrget
    cmp #$C3            ;CBM BASIC token for LEN
    bne L7AAC
    jsr chrget
    bcs L7AB3
    jsr linget
    lda linnum
    sta dir_entry+$0e   ;File sector count low byte
    lda linnum+1
    sta dir_entry+$0f   ;File sector count high byte
L7AAC:
    jsr L78A2
    bne L7B2C
    beq L7AE8
L7AB3:
    jsr ptrget          ;Find variable
    lda valtyp          ;A = type of variable (0=numeric, $ff=string)
    bne L7AC2           ;Branch if variable is not numeric

    bit intflg          ;Test type of numeric (0=floating point, $80=integer)
    bmi L7AC6           ;Branch if integer

    lda #$34
    bne L7ADB           ;Branch always
L7AC2:
    lda #$35
    bne L7ADB           ;Branch always
L7AC6:
    ldy #$00
    lda (varpnt),y
    sta dir_entry+$0f   ;File sector count high byte
    iny
    lda (varpnt),y
    sta dir_entry+$0e   ;File sector count low byte
    jmp L7AAC
L7AD6:
    pla
    beq L7ADE
    lda #$32
L7ADB:
    jmp L7B3D
L7ADE:
    ldy #$0F
L7AE0:
    lda (dir_ptr),y
    sta dir_entry,y
    dey
    bpl L7AE0
L7AE8:
    lda #$00
L7AEA:
    sta $7FB2
    sta $7FB3
L7AF0:
    sta $7FB5
    lda dir_entry+$0c   ;File track number
    sta $7FBA
    ldx dir_entry+$0d   ;File sector number
    dex
    stx $7FBB
L7B00:
    jsr L7B55
    ldy #$00
    lda $7FB3
    sta (varpnt),y
    iny
    lda $7FB2
    sta (varpnt),y
    jsr L7B59
    ldy #$00
    lda #$00
    sta (varpnt),y
    lda $7fb5
    iny
    sta (varpnt),y
    jsr L7B2F
L7B22:
    lda dir_entry,y
    sta buf_1,x
    dex
    dey
    bpl L7B22
L7B2C:
    jmp restore
L7B2F:
    lda $7F8F
    asl ;a
    asl ;a
    asl ;a
    asl ;a
    asl ;a
    adc #$1F
    tax
    ldy #$1F
    rts
L7B3D:
    sta $7FB5
    ldy #$00
    lda (txtptr),y
L7B44:
    cmp #$00
    beq L7B52
    cmp #':'
    beq L7B52
    jsr chrget
    jmp L7B44
L7B52:
    jmp L7B00
L7B55:
    lda #$49
    bne L7B5B
L7B59:
    lda #$43
L7B5B:
    sta dos_stop+1
    lda txtptr
    pha
    lda txtptr+1
    pha
    lda #<dos_stop
    sta txtptr
    lda #>dos_stop
    sta txtptr+1
    jsr ptrget
    pla
    sta txtptr+1
    pla
    sta txtptr
    rts

_dos_close:
;Perform !CLOSE
;
;Usage: !CLOSE F$
; - F$ contains a filename with drive like "NAME:0"
;
    jsr L7BA6
    ldy #$00
    lda (txtptr),y
    cmp #$80
    bne L7B91
    jsr chrget
    jsr L7C22
    lda #$FF
    sta dir_sector
    jsr write_a_sector
    bne L7BA3           ;Branch if a disk error occurred
L7B91:
    lda #$FF
L7B93:
    sta dir_entry
    sta $7FB5
    lda #$00
    sta latch
    lda #$FF
    jmp L7B00
L7BA3:
    jmp restore
L7BA6:
    jsr L7A0A
    inx
    bne L7BB1
    lda #$07
    jmp L7B3D
L7BB1:
    jsr L7B2F
L7BB4:
    lda buf_1,x
    sta dir_entry,y
    dex
    dey
    bpl L7BB4
    lda #$00
L7BC0:
    sta $7FB5
    rts
L7BC4:
    ldy #$00
    lda (txtptr),y
    cmp #$B9            ;TODO CBM BASIC token for POS?
    bne L7C22
    jsr chrget
    jsr L7B55
    ldy #$00
    lda (varpnt),y
    sta $7FB3
    iny
    lda (varpnt),y
    sta $7FB2
    ora $7FB3
    bne $7BE9
    lda #$08
    jmp L7B3D
L7BE9:
    lda $7FB2
    sec
    sbc #$01
    sta $5E
    lda $7FB3
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
L7C22:
    inc $7FB2
    bne L7C2A
    inc $7FB3
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
    lda #$08
    jmp L7B3D
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
;Usage: !INPUT F$ A$
; - F$ contains a filename with drive like "NAME:0"
; - A$ is the variable to write to
;
    jsr L7BA6
    jsr L7BC4
    jsr read_a_sector
    bne L7CA2           ;Branch if a disk error occurred

    jsr ptrget          ;Find variable
    bit valtyp          ;Test type of variable (0=numeric, $ff=string)
    bmi L7C82           ;Branch if variable is a string

    lda #$09
L7C7F:
    jmp L7B3D
L7C82:
    lda dir_sector
    cmp #$FF
    beq L7C7F
    cmp #$80
    bcc L7C91
    lda #$0A
    bne L7C7F
L7C91:
    ldy #$00
    sta (varpnt),y
    iny
    lda #$01
    sta (varpnt),y
    iny
    lda #$7F
    sta (varpnt),y
    jmp L7B00
L7CA2:
    jmp restore

_dos_print:
;Perform !PRINT
;
;Usage: !PRINT F$ A$
; - F$ contains a filename with drive like "NAME:0"
; - A$ is the variable to read from
;
    jsr L7BA6
    jsr L7BC4

    jsr ptrget          ;Find variable
    bit valtyp          ;Test type of variable (0=numeric, $ff=string)
    bmi L7CB7           ;Branch if variable is a string

    lda #$09
L7CB4:
    jmp L7B3D
L7CB7:
    ldy #$00
    lda (varpnt),y
    cmp #$80
    bcc L7CC3
    lda #$0A
    bne L7CB4
L7CC3:
    sta dir_sector
    iny
    lda (varpnt),y
    sta dir_ptr
    iny
    lda (varpnt),y
    sta dir_ptr+1
    ldy #$7E
L7CD2:
    lda (dir_ptr),y
    sta dir_sector+$01,y
    dey
    bpl L7CD2
    jsr write_a_sector
    bne L7CA2           ;Branch if a disk error occurred
    jmp L7B00

_dos_run:
;Perform !RUN
;Load and run a BASIC program.
;
;Usage: !RUN"NAME:0"
;
    jsr load_file
    txa
    bne L7D10           ;Branch if load failed
    lda #<L7D0C
    sta txtptr
    lda #>L7D0C
    sta txtptr+1
    ldx #$1F
    sei
L7CF3:
    lda wedge_stack,x
    sta $01E0,x
    dex
    bpl L7CF3
    ldx wedge_sp
    txs
    cli
    ldy wedge_y
    ldx wedge_x
    lda #$8A            ;CBM BASIC token for RUN
    jmp check_colon
L7D0C:
    !byte $8a           ;CBM BASIC token for RUN
    !byte 0             ;End of BASIC line
    !byte 0,0           ;End of BASIC program
L7D10:
    jmp restore

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
    jmp restore

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
    jmp restore
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
    jmp restore

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
