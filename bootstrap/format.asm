fdc          = $e980    ;WD1793 Floppy Disk Controller
fdc_cmdst    = fdc+0    ;  Command/status register
fdc_track    = fdc+1    ;  Track register
fdc_sector   = fdc+2    ;  Sector register
fdc_data     = fdc+3    ;  Data register

hex_save_a = $26
target_ptr = $b7
dir_sector  = $7f00
status_mask = $7f90
drive_sel = $7f91
track = $7f92
sector = $7f93
status = $7f94
linprt = $CF83
select_drive = $EBA0
deselect = $EB0B
send_fdc_cmd = $EC0D
read_a_sector = $ECDF
write_a_sector = $ED3A
puts = $EFE7
chrout = $FFD2

tracks = 77
sectors = 26
sector_size = 128

    *=$0400

bas_header:
    !byte $00           ;Null byte at start of BASIC program
    !word bas_eol+1     ;Pointer to the next BASIC line
bas_line:
    !word $000a         ;Line number
    !byte $9e           ;Token for SYS command
    !text "1037"        ;Arguments for SYS
bas_eol:
    !byte $00           ;End of BASIC line
    !byte $00,$00       ;End of BASIC program

init:
    ;Init track and sector
    ldx #0
    stx track
    inx
    stx sector
    stx fdc_sector

    ;Select drive 0
    lda #1              ;Pattern to select drive 0
    sta drive_sel
    jsr select_drive    ;Select drive using pattern in drive_sel

    ;TODO ?
    lda #$03
    jsr send_fdc_cmd

    ;Check if the disk is write protected
    lda fdc_cmdst
    and #$40
    beq not_protected   ;Branch if not write protected

    ;Print "WRITE PROTECT ERROR" and exit
    lda #<protected_msg
    ldy #>protected_msg
    jsr puts
    jmp deselect_and_exit

not_protected:
    ;TODO ? Check for other error
    lda fdc_cmdst
    and #$9D
    cmp #$04
    beq not_other_err   ;Branch if error

    ;Print "OTHER ERROR" and exit
    lda #<protected_msg
    ldy #>protected_msg
    jsr puts
    jmp deselect_and_exit

not_other_err:
    ;Format all tracks on the disk
    jsr format

    ;Read last track, last sector as a test
    jsr set_target_ptr
    lda #tracks-1
    sta track
    lda #sectors
    sta sector
    jsr read_a_sector
    bne failed          ;Branch if error

    ;Disk has been formatted successfully.  All sectors on the
    ;disk have been filled with $E6.  Now we need to write the
    ;directory sectors.

    ;Print "WRITE EMPTY DIR"
    lda #<write_dir_msg
    ldy #>write_dir_msg
    jsr puts

    ;Fill all 128 bytes of the sector buffer with $FF.
    ldx #$7F
    lda #$FF
fill_ff:
    sta dir_sector,x
    dex
    bpl fill_ff

    ;Fill track 0, sectors 1-8 (entire directory) with $FF
    ;because empty directory entries always contain $FF.
    ;Start with sector 8, step down to sector 1.
    lda #0
    sta track
    lda #8
    sta sector
dir_loop:
    jsr set_target_ptr
    jsr write_a_sector
    bne failed          ;Branch if error
    dec sector
    lda sector
    bne dir_loop

    ;Now that the entire directory has been filled with $FF,
    ;we just need to update the first directory sector.

    ;Set the disk name
    ldx #0
fill_dn:
    lda disk_name,x
    beq write_dir
    sta dir_sector,x
    inx
    bne fill_dn         ;Branch always

write_dir:
    ;Set number of used file entries to 0 (empty disk)
    lda #$00
    sta dir_sector+$08  ;Number of used file entries to 0

    ;Set next open track and sector to track 0, sector 9.
    ;This is the first sector after the directory.
    sta dir_sector+$09  ;Set next open track to 0
    lda #$09
    sta dir_sector+$0a  ;Set next open sector to 9

    ;Fill unknown bytes in directory
    lda #$20
    sta dir_sector+$0b  ;TODO These bytes in the directory
    sta dir_sector+$0c  ;     are unknown and appear unused.
    sta dir_sector+$0d
    sta dir_sector+$0e
    sta dir_sector+$0f

    ;Write track 0, sector 1
    lda #1
    sta sector
    jsr set_target_ptr
    jsr write_a_sector
    bne failed              ;Branch if error

    ;Disk has been formatted and empty directory written to it.

finished_ok:
    ;Print "FINISHED OK"
    lda #<finished_msg
    ldy #>finished_msg
    jsr puts
    jmp deselect_and_exit

failed:
    ;Print "FAILED"
    lda #<failed_msg
    ldy #>failed_msg
    jsr puts
    ;Fall through into deselect_and_exit

deselect_and_exit:
    jmp deselect

set_target_ptr:
    ;Set pointer target_ptr for sector write
    lda #<dir_sector
    sta target_ptr
    lda #>dir_sector
    sta target_ptr+1
    rts

format:
    lda #$0d
    jsr chrout

track_loop:
    ;Print cursor up then "FORMAT TRACK"
    lda #<format_track_msg
    ldy #>format_track_msg
    jsr puts

    ;Print track number
    lda #$00            ;High byte of number to print = 0
    ldx track           ;Low byte of number to print = track
    jsr linprt          ;Print 256*A + X in decimal

    ;Print newline
    lda #$0d
    jsr chrout

    ;Format the track
    jsr format_track

    ;Increment track, loop until all tracks have been formatted.
    inc track
    lda #tracks
    cmp track
    bne track_loop
    rts

format_track:
    ;Seek to track (no verify)
    lda track
    sta fdc_data
    lda #%00010011      ;seek?
    jsr send_fdc_cmd

    lda #$00
    sta status_mask

    ldy #$01            ;Initialize sector count to 1

    sei

    lda #%11110100      ;write track, 15ms delay?
    sta fdc_cmdst

;Busy wait for WD1793
    ldx #$06
L7D97:
    dex
    bne L7D97

;Write $FF x 40
    ldx #40
l1a:
    lda #$E6
l1b:
    bit fdc_cmdst
    beq l1b
    lda #$FF
    sta fdc_data        ;data = FF
    dex
    bne l1a

;Write $00 x 6
    ldx #6
l2a:
    lda #$E6
l2b:
    bit fdc_cmdst
    beq l2b
    lda #0
    sta fdc_data        ;data = 0
    dex
    bne l2a

;Write $FC x 1
    ldx #1
l3a:
    lda #$E6
l3b:
    bit fdc_cmdst
    beq l3b
    lda #$FC
    sta fdc_data        ;data = FC
    dex
    bne l3a

;Write $FF x 26
    ldx #26
l4a:
    lda #$E6
l4b:
    bit fdc_cmdst
    beq l4b
    lda #$FF
    sta fdc_data        ;data = FF
    dex
    bne l4a

sector_loop:

;Write $00 x 6
    ldx #6
l5a:
    lda #$E6
l5b:
    bit fdc_cmdst
    beq l5b
    lda #0
    sta fdc_data        ;data = 0
    dex
    bne l5a

;Write $FE x 1 (id address mark)
    ldx #1
l6a:
    lda #$E6
l6b:
    bit fdc_cmdst
    beq l6b
    lda #$FE
    sta fdc_data        ;data = FE
    dex
    bne l6a

;Write track number
    ldx #1
l7a:
    lda #$E6
l7b:
    bit fdc_cmdst
    beq l7b
    lda track
    sta fdc_data        ;data = track
    dex
    bne l7a

;Write side number
    ldx #1
l8a:
    lda #$E6
l8b:
    bit fdc_cmdst
    beq l8b
    lda #0
    sta fdc_data        ;data = side 0
    dex
    bne l8a

;Write sector number
    ldx #1
l9a:
    lda #$E6
l9b:
    bit fdc_cmdst
    beq l9b
    sty fdc_data        ;data = sector
    dex
    bne l9a

;Write sector length
    ldx #1
l10a:
    lda #$E6
l10b:
    bit fdc_cmdst
    beq l10b
    lda #0
    sta fdc_data        ;data = 0 (128 byte sector len)
    dex
    bne l10a

;Write F7 x 1
    ldx #1
l11a:
    lda #$E6
l11b:
    bit fdc_cmdst
    beq l11b
    lda #$f7
    sta fdc_data        ;data = F7
    dex
    bne l11a

;Write FF x 11
    ldx #11
l12a:
    lda #$E6
l12b:
    bit fdc_cmdst
    beq l12b
    lda #$ff
    sta fdc_data        ;data = FF
    dex
    bne l12a

;Write $00 x 6
    ldx #6
l13a:
    lda #$E6
l13b:
    bit fdc_cmdst
    beq l13b
    lda #0
    sta fdc_data        ;data = 0
    dex
    bne l13a

;Write FB x 1
    ldx #1
l14a:
    lda #$E6
l14b:
    bit fdc_cmdst
    beq l14b
    lda #$fb
    sta fdc_data        ;data = FB
    dex
    bne l14a

;Write E5 x 1
    ldx #128
l15a:
    lda #$E6
l15b:
    bit fdc_cmdst
    beq l15b
    lda #$e5
    sta fdc_data        ;data = E5
    dex
    bne l15a

;Write F7 x 1
    ldx #1
l16a:
    lda #$E6
l16b:
    bit fdc_cmdst
    beq l16b
    lda #$f7
    sta fdc_data        ;data = F7
    dex
    bne l16a

;Write FF x 1
    ldx #1
l17a:
    lda #$E6
l17b:
    bit fdc_cmdst
    beq l17b
    lda #$ff
    sta fdc_data        ;data = FF
    dex
    bne l17a

    ;increment to next sector
    iny

    cpy #sectors+1
    bpl track_done
    jmp sector_loop

track_done:
    lda #$01
track_done_wait:
    bit fdc_cmdst
    bne track_done_wait
    cli
    rts

protected_msg:
    !text "WRITE PROTECT ERROR",$0d,0

other_err_msg:
    !text "OTHER ERROR",$0d,0

format_track_msg:
    !text $91,"FORMAT TRACK",0

write_dir_msg:
    !text "WRITE EMPTY DIR",$0d,0

disk_name:
    !text "YOURDISK",0

failed_msg:
    !text $0d,"FAILED",$0d,0

finished_msg:
    !text "FINISHED OK",$0d,0
