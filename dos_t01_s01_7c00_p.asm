L7931 = $7931
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
target_ptr  = $b7       ;Pointer: PEDISK target address for memory ops **
dos         = $7800     ;Base address for the RAM-resident portion
dir_sector  = dos+$0700 ;128 bytes for directory sector
drive_sel   = dos+$0791 ;Drive select bit pattern to write to the latch
track       = dos+$0792 ;Track number to write to WD1793 (0-76 or $00-4c)
sector      = dos+$0793 ;Sector number to write to WD1793 (1-26 or $01-1a)

dir_track   = 0         ;Track where directory is stored (always one track)
                        ;First sector of dir is hardcoded

    *=$7c00

    jmp L7CB4

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

L7CB4:
    jsr input_device
    sta drive_sel

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
    beq L7CD7           ;If no error occured, branch to start printing
    jmp pdos_prompt     ;If an error occurred, jump to the PDOS prompt

L7CD7:
    ;Clear screen and print "PEDISK II DISK DIRECTORY"
    lda #<pedisk_dir
    ldy #>pedisk_dir
    jsr puts

    ;Print disk name
    ldy #$00            ;Y = 0, index added to pointer
    ldx #$08            ;X = 8 chars in disk name
L7CE2:
    lda (dir_ptr),y     ;Get char of disk name
    jsr chrout          ;Print it
    iny                 ;Increment pointer to next char
    dex                 ;Decrement chars remaining
    bne L7CE2           ;Loop until 8 chars printed

    ;Print "  SECTORS LEFT= "
    lda #<sectors_left
    ldy #>sectors_left
    jsr puts

    ldx #$00
    stx $59
    lda $7F09
    sta $5E
    lda #$1C    ;TODO 28 sectors per track?
    sta $60
    lda #$00
    sta $5F
    sta $61
    jsr L7931
    lda $7F0A
    clc
    adc $62
    sta $62
    bcc L7D14
    inc $63
L7D14:
    lda #$5F
    sec
    sbc $62
    sta $62
    lda #$04
    sbc $63
    jsr put_hex_byte
    lda $62
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

L7D3C:
    lda dir_ptr
    clc
    adc #$10
    bpl L7D50
    inc sector

    jsr read_a_sector   ;Read next sector in the directory
    beq L7D4E           ;If no error occurred, branch to continue
    jmp pdos_prompt     ;If error occured, jump to PDOS prompt

L7D4E:
    lda #$00
L7D50:
    sta dir_ptr

    ;Check for end of directory

    ldy #$00
    lda (dir_ptr),y     ;Get first byte of filename
    cmp #$FF            ;Equal to $FF?
    bne L7D5D           ;  No: continue
    jmp L7DEB           ;  Yes: jump, end of directory

L7D5D:
    ;Check if file has been deleted

    ldy #$05
    lda (dir_ptr),y     ;Get last byte of filename
    cmp #$FF            ;Equal to $FF?
    beq L7D3C           ;  Yes: file is deleted, skip it

    ;Print newline
    lda #$0D
    jsr chrout

    ;Under "NAME" column
    ;Print filename

    ldy #$00
L7D6C:
    lda (dir_ptr),y
    jsr chrout
    iny
    cpy #$06
    bmi L7D6C

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
    bne L7DD7

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

L7DD7:
    ;Decrement lines count.  If not time for a pause,
    ;jump back to do the next line.

    dec edit_pos
    bmi L7DDE
    jmp next_entry

L7DDE:
    ;Time for a pause.  Wait for a keypress, then
    ;jump back to do the next line.

    ;Print "MORE..."
    lda #<more
    ldy #>more
    jsr puts

    jsr get_char_w_stop ;Get a character and test for {STOP}
    jmp next_screen

L7DEB:
    ;Print newline
    lda #$0D
    jsr chrout

    lda #$00
    sta $E900

    jmp pdos_prompt

    !byte $07
    sta $7FAA
    lda #$02
    !byte $8D
    !byte $AE
