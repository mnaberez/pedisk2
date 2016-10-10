latch = $e900 ;Drive Select Latch
l_7931= $7931
pdos_prompt = $7A05
input_device = $7AD1
put_spc_hex = $EB7F
put_hex_byte = $EB84
read_a_sector = $ECDF
get_char_w_stop = $EF59 ;Get a character and test for {STOP}
puts = $EFE7
chrout = $FFD2

;In the zero page locations below, ** indicates the PEDISK destroys
;a location that is used for some other purpose by CBM BASIC 4.

dir_ptr     = $22       ;Pointer: PEDISK directory **
edit_pos    = $27       ;PEDISK memory editor position on current line **
tmp_sector  = $59       ;TODO seems to hold a sector
target_ptr  = $b7       ;Pointer: PEDISK target address for memory ops **
dos         = $7800     ;Base address for the RAM-resident portion
dir_sector  = dos+$0700 ;128 bytes for directory sector
drive_sel   = dos+$0791 ;Drive select bit pattern to write to the latch
track       = dos+$0792 ;Track number to write to WD1793 (0-76 or $00-4c)
sector      = dos+$0793 ;Sector number to write to WD1793 (1-26 or $01-1a)

dir_track   = 0         ;Track where directory is stored (always one track)
                        ;First sector of dir is hardcoded

    *=$7c00

    jmp l_7cb4

more:
    !text $0d,$0a,"MORE....",0
pedisk_dir:
    !text $93,"    PEDISK II DISK DIRECTORY",$0d,$0a
diskname:
    !text "DISKNAME= ",0
sectors_left:
    !text "  SECTORS LEFT= ",0
dirheader:
    !text $0d,$0d,$0a,"NAME   TYPE  TRK SCTR #SCTRS LOAD ENTRY",0
filetypes:
    !text " SEQTL ",0
    !text " INDX  ",0
    !text " ISAM  ",0
    !text " BASIC ",0
    !text " ASSMB ",0
    !text " LOAD  ",0
    !text " TEXT  ",0
    !text " OBJCT ",0

l_7cb4:
    ;Get drive select pattern
    jsr input_device    ;Print "DEVICE? ", get num, returns drv sel pat in A
    sta drive_sel       ;Save the drive select pattern in drive_sel

    ldx #dir_track      ;set track 0 (first track)
    stx track           ;save the requested track number

    inx                 ;set sector 1 (first sector, sectors start at 1)
    stx sector          ;save the requested sector number

    lda #<dir_sector
    sta target_ptr
    sta dir_ptr

    lda #>dir_sector
    sta target_ptr+1
    sta dir_ptr+1

    jsr read_a_sector   ;Read the first directory sector
    beq l_7cd7          ;If no error occured, branch to start printing
    jmp pdos_prompt     ;If an error occurred, jump to the PDOS prompt

l_7cd7:
    ;Clear screen and print "PEDISK II DISK DIRECTORY"
    lda #<pedisk_dir
    ldy #>pedisk_dir
    jsr puts

    ;Print disk name
    ldy #$00            ;Y = 0, index added to pointer
    ldx #$08            ;X = 8 chars in disk name
l_7ce2:
    lda (dir_ptr),y     ;Get char of disk name
    jsr chrout          ;Print it
    iny                 ;Increment pointer to next char
    dex                 ;Decrement chars remaining
    bne l_7ce2          ;Loop until 8 chars printed

    ;Print "  SECTORS LEFT= "
    lda #<sectors_left
    ldy #>sectors_left
    jsr puts

    ldx #$00
    stx tmp_sector
    lda dir_sector+$09  ;Next open track
    sta $5E
    lda #$1C            ;TODO disk conversion: 28 sectors per track?
    sta $60
    lda #$00
    sta $5F
    sta $61
    jsr l_7931
    lda dir_sector+$0a  ;Next open sector
    clc
    adc $62
    sta $62
    bcc l_7d14
    inc $63
l_7d14:
    lda #$5F
    sec
    sbc $62
    sta $62
    lda #$04

    ;Print free sector count in hex
    sbc $63             ;Free sector count high byte
    jsr put_hex_byte
    lda $62             ;Free sector count low byte
    jsr put_hex_byte

    ;Print "NAME   TYPE  TRK SCTR #SCTRS LOAD ENTRY"
    lda #<dirheader
    ldy #>dirheader
    jsr puts

next_screen:
    ;Start line countdown used to pause screen

    lda #$12
    sta edit_pos

    ;Print newline

    lda #$0D
    jsr chrout

next_entry:
    lda #$0A
    jsr chrout

l_7d3c:
    lda dir_ptr
    clc
    adc #$10
    bpl l_7d50
    inc sector

    jsr read_a_sector   ;Read next sector in the directory
    beq l_7d4e          ;If no error occurred, branch to continue
    jmp pdos_prompt     ;If error occured, jump to PDOS prompt

l_7d4e:
    lda #$00
l_7d50:
    sta dir_ptr

    ;Check for end of directory

    ldy #$00
    lda (dir_ptr),y     ;Get first byte of filename
    cmp #$FF            ;Equal to $FF?
    bne l_7d5d          ;  No: continue
    jmp l_7deb          ;  Yes: jump, end of directory

l_7d5d:
    ;Check if file has been deleted

    ldy #$05
    lda (dir_ptr),y     ;Get last byte of filename
    cmp #$FF            ;Equal to $FF?
    beq l_7d3c          ;  Yes: file is deleted, skip it

    ;Print newline
    lda #$0D
    jsr chrout

    ;Under "NAME" column
    ;Print filename

    ldy #$00
l_7d6c:
    lda (dir_ptr),y
    jsr chrout
    iny
    cpy #$06
    bmi l_7d6c

    ;Under "TYPE" column
    ;Print file type

    ldy #$0A
    lda (dir_ptr),y
    asl ;a
    asl ;a
    asl ;a
    clc
    adc #<filetypes
    ldy #>filetypes
    jsr puts

    ;Under "TRK" column
    ;Print file track number

    ldy #$0C
    lda (dir_ptr),y
    jsr put_hex_byte

    ;Print space

    lda #$20
    jsr chrout

    ;Under "SCTR" column
    ;Print file sector number

    ldy #$0D
    lda (dir_ptr),y
    jsr put_spc_hex

    ;Print two spaces

    lda #$20
    jsr chrout
    jsr chrout

    ;Under "#SCTRS" column (1/2)
    ;Print file sector count high byte

    ldy #$0F
    lda (dir_ptr),y
    jsr put_spc_hex

    ;Under "#SCTRS" column (2/2)
    ;Print file sector count low byte

    ldy #$0E
    lda (dir_ptr),y
    jsr put_hex_byte

    ;If the file type is not $05 ("LOAD") then skip printing both
    ;the load address and the entry address.  Note: for all other
    ;file types except $05, the word at offset $06/07 is the file
    ;length, not an entry address.

    ldy #$0A
    lda (dir_ptr),y
    cmp #$05
    bne l_7dd7

    ;Print two spaces

    lda #$20
    jsr chrout
    jsr chrout

    ;Under "LOAD" column (1/2)
    ;Print load address high byte

    ldy #$09
    lda (dir_ptr),y
    jsr put_spc_hex

    ;Under "LOAD" column (2/2)
    ;Print load address low byte

    dey                 ;Y=$08
    lda (dir_ptr),y
    jsr put_hex_byte

    ;Under "ENTRY" column (1/2)
    ;Print entry address high byte

    dey                 ;Y=$07
    lda (dir_ptr),y
    jsr put_spc_hex

    ;Under "ENTRY" column (2/2)
    ;Print entry address low byte

    dey                 ;Y=$06
    lda (dir_ptr),y
    jsr put_hex_byte

l_7dd7:
    ;Decrement lines count.  If not time for a pause,
    ;jump back to do the next line.

    dec edit_pos
    bmi l_7dde
    jmp next_entry

l_7dde:
    ;Time for a pause.  Wait for a keypress, then
    ;jump back to do the next line.

    ;Print "MORE..."
    lda #<more
    ldy #>more
    jsr puts

    jsr get_char_w_stop ;Get a character and test for {STOP}
    jmp next_screen

l_7deb:
    ;Print newline
    lda #$0D
    jsr chrout

    ;Deselect drives and stop motors
    lda #$00            ;Bit 3 = WD1793 /DDEN=0 (double density mode)
                        ;All other bits off = deselect drives, stop motors
                        ;TODO disk conversion: this code always sets /DDEN=0
    sta latch

    jmp pdos_prompt

filler:
    !byte $07,$8d,$aa,$7f,$a9,$02,$8d,$ae
