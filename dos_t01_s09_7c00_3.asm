fdc          = $e980    ;WD1793 Floppy Disk Controller
fdc_cmdst    = fdc+0    ;  Command/status register
fdc_track    = fdc+1    ;  Track register
fdc_sector   = fdc+2    ;  Sector register
fdc_data     = fdc+3    ;  Data register

L000D = $0D
hex_save_a = $26
target_ptr = $b7
pdos_prompt = $7A05
input_device = $7AD1
dir_sector  = $7f00
status_mask = $7f90
drive_sel = $7f91
track = $7f92
sector = $7f93
status = $7f94
linprt = $CF83          ;BASIC Print 256*A + X in decimal
select_drive = $EBA0
send_fdc_cmd = $EC0D
LECCC = $ECCC
write_a_sector = $ED3A
get_char = $EF7B
puts = $EFE7
chrout = $FFD2

    *=$7c00

    jmp start

disk_format:
    !text $0d,$0d,"PEDISK II DISK FORMAT"
    !text $0d,"   DOUBLE DENSITY",$0d,0
are_you_sure:
    !text $0d,"SURE? (Y-YES)",0
enter_name:
    !text $0d,"NAME? ",$0d,0
finished_disk:
    !text $0d,"FINISHED!",0
protected_disk:
    !text $0d,"PROTECTED DISK!!",$0d,0
error:
    !text " ERROR!",0
finished_track:
    !text $0d,"FORMAT TRACK ",0

start:
    ;Print banner
    lda #<disk_format
    ldy #>disk_format
    jsr puts

    jsr input_device
    sta drive_sel

    ;Print "SURE? (Y-YES)"
    lda #<are_you_sure
    ldy #>are_you_sure
    jsr puts

    ;Get a character from the user, exit if it's not "Y"
    jsr get_char
    cmp #'Y'
    bne exit

    ;Select drive 0
    jsr select_drive
    bne exit            ;Exit if an error occurred

    ;TODO ?
    lda #$03
    jsr send_fdc_cmd

    ;Check if the disk is write protected
    lda fdc_cmdst
    and #$40
    bne protected       ;Branch if write protected

    ;TODO ?
    lda fdc_cmdst
    and #$9D
    cmp #$04
    beq format          ;Branch if no error

    lda #$F0
    jmp puts_error_exit

exit:
    jmp pdos_prompt

protected:
;Disk is write protected.  Print "PROTECTED DISK!"
;and exit.
;
    nop

    ;Print "PROTECTED DISK!!"
    lda #<protected_disk
    ldy #>protected_disk
    jsr puts

    lda #$F3
    jmp puts_error_exit

format:
;Start formatting the disk.
;
    ;Set first track (track 0)
    ldx #$00
    stx track

    ;Set first sector (sector 1)
    inx
    stx sector
    stx fdc_sector

track_loop:
    ;Format the current track
    jsr format_track

    ;Print "FORMAT TRACK "
    lda #<finished_track
    ldy #>finished_track
    jsr puts

    ;Print the track number in decimal
    lda #$00            ;High byte of number to print = 0
    ldx track           ;Low byte of number to print = track
    jsr linprt          ;Print 256*A + X in decimal

    ;Increment track, loop until all tracks have been formatted.
    inc track
    lda #$28            ;TODO 40/41 tracks?
    cmp track
    bpl track_loop

    ;All tracks have been formatted.

    ;Set target_ptr to dir_sector, a 128 byte buffer in memory
    ;that we will use to write the directory sectors.
    lda #<dir_sector
    sta target_ptr
    lda #>dir_sector
    sta target_ptr+1

    ;Fill all 128 bytes of the buffer with $FF
    ldy #$7F
    lda #$FF
L7CF9:
    sta (target_ptr),y
    dey
    bpl L7CF9

    ;Set track 0, sector 2 (this is the second sector of the directory)
    ldx #$00
    stx track           ;Set track 0
    inx
    inx
    stx sector          ;Set sector 2

erase_dir_loop:
    ;Write the sector to disk (all $FF bytes)
    jsr write_a_sector
L7D0B:
    bne exit            ;Branch if a disk error occurred

    ;TODO check ??
    lda status
    beq L7D17           ;Branch if no error

    lda #$F1
    jmp puts_error_exit

L7D17:
    ;Increment to next directory sector, keep filling until end of dir
    ldx sector
    inx
    stx sector
    cpx #$09
    bmi erase_dir_loop

    ;All directory sectors except the first one has been filled
    ;with $FF (track 0, sectors 2-8).  Only the first directory
    ;sector (track 0, sector 1) needs to be written now.

    ;Set sector 1 (first directory sector)
    lda #$01
    sta sector

    ;PRINT "NAME? "
    lda #<enter_name
    ldy #>enter_name
    jsr puts

    ;Get 8 characters for disk name, store it in the directory
    ldx #$00
L7D30:
    stx hex_save_a
    jsr get_char        ;Wait for a char, echo it, return it in A
    ldx hex_save_a
    sta dir_sector,x
    inx
    cpx #$08
    bcc L7D30

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

    ;Write the first directory sector
    jsr write_a_sector
    bne L7D0B           ;Branch if a disk error occurred

    ;Print "FINISHED!"
    lda #<finished_disk
    ldy #>finished_disk
    jsr puts

    jmp pdos_prompt

puts_error_exit:
;Print ?? followed by " ERROR!" and exit
    pha
    lda L000D           ;TODO XXX is this a bug? should it be #$0d?
    jsr chrout
    pla

    ;Print " ERROR!"
    lda #<error
    ldy #>error
    jsr puts

    jmp pdos_prompt

format_track:
    lda track
    sta fdc_data
    lda #$13
    jsr send_fdc_cmd
    lda #$00
    sta status_mask
    ldy #$01
    sei
    lda #$F4
    sta fdc_cmdst
    ldx #$06
L7D97:
    dex
    bne L7D97
    ldx #$10
L7D9C:
    lda #$E6
L7D9E:
    bit fdc_cmdst
    beq L7D9E
    lda #$4E
    sta fdc_data
    dex
    bne L7D9C
    ldx #$08
L7DAD:
    lda #$E6
L7DAF:
    bit fdc_cmdst
    beq L7DAF
    lda #$00
    sta fdc_data
    dex
    bne L7DAD
    ldx #$03
L7DBE:
    lda #$E6
L7DC0:
    bit fdc_cmdst
    beq L7DC0
    lda #$F6
    sta fdc_data
    dex
    bne L7DBE
    lda #$E6
L7DCF:
    bit fdc_cmdst
    beq L7DCF
    lda #$FC
    sta fdc_data
    ldx #$20
L7DDB:
    lda #$E6
L7DDD:
    bit fdc_cmdst
    beq L7DDD
    lda #$4E
    sta fdc_data
    dex
    bne L7DDB
L7DEA:
    ldx #$08
L7DEC:
    lda #$E6
L7DEE:
    bit fdc_cmdst
    beq L7DEE
    lda #$00
    sta fdc_data
    dex
    bne L7DEC
    ldx #$03
L7DFD:
    lda #$E6
L7DFF:
    bit fdc_cmdst
    beq L7DFF
    lda #$F5
    sta fdc_data
    dex
    bne L7DFD
    lda #$E6
L7E0E:
    bit fdc_cmdst
    beq L7E0E
    lda #$FE
    sta fdc_data
    lda #$E6
L7E1A:
    bit fdc_cmdst
    beq L7E1A
    lda track
    sta fdc_data
    lda #$E6
L7E27:
    bit fdc_cmdst
    beq L7E27
    lda #$00
    sta fdc_data
    lda #$E6
L7E33:
    bit fdc_cmdst
    beq L7E33
    sty fdc_data
    iny
    lda #$E6
L7E3E:
    bit fdc_cmdst
    beq L7E3E
    lda #$00
    sta fdc_data
    lda #$E6
L7E4A:
    bit fdc_cmdst
    beq L7E4A
    lda #$F7
    sta fdc_data
    ldx #$16
L7E56:
    lda #$E6
L7E58:
    bit fdc_cmdst
    beq L7E58
    lda #$4E
    sta fdc_data
    dex
    bne L7E56
    ldx #$0C
L7E67:
    lda #$E6
L7E69:
    bit fdc_cmdst
    beq L7E69
    lda #$00
    sta fdc_data
    dex
    bne L7E67
    ldx #$03
L7E78:
    lda #$E6
L7E7A:
    bit fdc_cmdst
    beq L7E7A
    lda #$F5
    sta fdc_data
    dex
    bne L7E78
    lda #$E6
L7E89:
    bit fdc_cmdst
    beq L7E89
    lda #$FB
    sta fdc_data
    ldx #$80
L7E95:
    lda #$E6
L7E97:
    bit fdc_cmdst
    beq L7E97
    lda #$E5
    sta fdc_data
    dex
    bne L7E95
    lda #$E6
L7EA6:
    bit fdc_cmdst
    beq L7EA6
    lda #$F7
    sta fdc_data
    ldx #$1C            ;TODO 28 sectors per track?
L7EB2:
    lda #$E6
L7EB4:
    bit fdc_cmdst
    beq L7EB4
    lda #$4E
    sta fdc_data
    dex
    bne L7EB2
    lda #$E6
L7EC3:
    bit fdc_cmdst
    bne L7EC3
    lda #$4E
    sta fdc_data
    cpy #$1D            ;TODO Past last sector?  28 sectors per track on 5.25"
    bpl L7ED4
    jmp L7DEA
L7ED4:
    lda #$01
L7ED6:
    bit fdc_cmdst
    bne L7ED6
    cli
    jsr LECCC          ;TODO XXX middle of an instruction in the ROM
    rts

filler:
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
