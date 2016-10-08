fdc          = $e980    ;WD1793 Floppy Disk Controller
fdc_cmdst    = fdc+0    ;  Command/status register
fdc_track    = fdc+1    ;  Track register
fdc_sector   = fdc+2    ;  Sector register
fdc_data     = fdc+3    ;  Data register

l_000d= $0D
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
l_eccc= $ECCC
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

    ;Get drive select pattern
    jsr input_device    ;Print "DEVICE? ", get num, returns drv sel pat in A
    sta drive_sel       ;Save the drive select pattern in drive_sel

    ;Print "SURE? (Y-YES)"
    lda #<are_you_sure
    ldy #>are_you_sure
    jsr puts

    ;Get a character from the user, exit if it's not "Y"
    jsr get_char
    cmp #'Y'
    bne exit

    ;Select drive
    jsr select_drive    ;Select drive using pattern in drive_sel
    bne exit            ;Exit if an error occurred

    ;Move head to track 0
    lda #$03            ;Set restore command, no verify, 30ms step rate
    jsr send_fdc_cmd

    ;Check if the disk is write protected
    lda fdc_cmdst
    and #$40
    bne protected       ;Branch if write protected

    ;Check drive is ready and at track 0
    lda fdc_cmdst
    and #%10011101      ;Mask x00x xx0x:
                        ;     x--- ---- not ready
                        ;     ---x ---- seek error
                        ;     ---- x--- crc error
                        ;     ---- -x-- track 0
                        ;     ---- ---x busy
    cmp #%00000100      ;Compare with only track 0 flag set
    beq format          ;Branch if at track 0 and no error

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
l_7cf9:
    sta (target_ptr),y
    dey
    bpl l_7cf9

    ;Set track 0, sector 2 (this is the second sector of the directory)
    ldx #$00
    stx track           ;Set track 0
    inx
    inx
    stx sector          ;Set sector 2

erase_dir_loop:
    ;Write the sector to disk (all $FF bytes)
    jsr write_a_sector
l_7d0b:
    bne exit            ;Branch if a disk error occurred

    ;TODO check ??
    lda status
    beq l_7d17          ;Branch if no error

    lda #$F1
    jmp puts_error_exit

l_7d17:
    ;Increment to next directory sector, keep filling until end of dir
    ldx sector
    inx
    stx sector
    cpx #$09
    bmi erase_dir_loop

    ;All directory sectors except the first one have been filled
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
l_7d30:
    stx hex_save_a
    jsr get_char        ;Wait for a char, echo it, return it in A
    ldx hex_save_a
    sta dir_sector,x
    inx
    cpx #$08
    bcc l_7d30

    ;Set number of used file entries to 0 (empty disk)
    lda #$00
    sta dir_sector+$08  ;Number of used file entries to 0

    ;Set next open track and sector to track 0, sector 9.
    ;This is the first sector after the directory.
    sta dir_sector+$09  ;Set next open track to 0
    lda #$09
    sta dir_sector+$0a  ;Set next open sector to 9

    ;Fill unused bytes in directory with $20
    lda #$20
    sta dir_sector+$0b
    sta dir_sector+$0c
    sta dir_sector+$0d
    sta dir_sector+$0e
    sta dir_sector+$0f

    ;Write the first directory sector
    jsr write_a_sector
    bne l_7d0b          ;Branch if a disk error occurred

    ;Print "FINISHED!"
    lda #<finished_disk
    ldy #>finished_disk
    jsr puts

    jmp pdos_prompt

puts_error_exit:
;Print ?? followed by " ERROR!" and exit
    pha
    lda l_000d          ;TODO XXX is this a bug? should it be #$0d?
    jsr chrout
    pla

    ;Print " ERROR!"
    lda #<error
    ldy #>error
    jsr puts

    jmp pdos_prompt

format_track:
    ;Seek to track
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
l_7d97:
    dex
    bne l_7d97

;Write $4E x 16
    ldx #$10
l_7d9c:
    lda #$E6
l_7d9e:
    bit fdc_cmdst
    beq l_7d9e
    lda #$4E
    sta fdc_data        ;data = 4e
    dex
    bne l_7d9c

;Write $00 x 8
    ldx #$08
l_7dad:
    lda #$E6
l_7daf:
    bit fdc_cmdst
    beq l_7daf
    lda #$00
    sta fdc_data        ;data = 0
    dex
    bne l_7dad

;Write $F6 x 3
    ldx #$03
l_7dbe:
    lda #$E6
l_7dc0:
    bit fdc_cmdst
    beq l_7dc0
    lda #$F6
    sta fdc_data        ;data = f6 (writes c2)
    dex
    bne l_7dbe

;Write $FC x 1
    lda #$E6
l_7dcf:
    bit fdc_cmdst
    beq l_7dcf
    lda #$FC
    sta fdc_data        ;data = fc (index mark)

;Write $4E x 32
    ldx #$20
l_7ddb:
    lda #$E6
l_7ddd:
    bit fdc_cmdst
    beq l_7ddd
    lda #$4E
    sta fdc_data        ;data = 4e
    dex
    bne l_7ddb

;
;Start of a sector
;

l_7dea:

;Write $00 x 8
    ldx #$08
l_7dec:
    lda #$E6
l_7dee:
    bit fdc_cmdst
    beq l_7dee
    lda #$00
    sta fdc_data        ;data = 0
    dex
    bne l_7dec

;Write $F5 x 3
    ldx #$03
l_7dfd:
    lda #$E6
l_7dff:
    bit fdc_cmdst
    beq l_7dff
    lda #$F5
    sta fdc_data        ;data = f5 (write ?)
    dex
    bne l_7dfd

;Write $FE x 1 (id address mark)
    lda #$E6
l_7e0e:
    bit fdc_cmdst
    beq l_7e0e
    lda #$FE
    sta fdc_data        ;data = fe (id address mark)

;Write track byte
    lda #$E6
l_7e1a:
    bit fdc_cmdst
    beq l_7e1a
    lda track
    sta fdc_data        ;data = track number

;Write side number byte
    lda #$E6
l_7e27:
    bit fdc_cmdst
    beq l_7e27
    lda #$00
    sta fdc_data        ;data = side number 0

;Write sector number byte
    lda #$E6
l_7e33:
    bit fdc_cmdst
    beq l_7e33
    sty fdc_data        ;data = sector number

;Increment sector number for next iteration
    iny

;Write sector length byte
    lda #$E6
l_7e3e:
    bit fdc_cmdst
    beq l_7e3e
    lda #$00
    sta fdc_data        ;data = sector length (0 = 128 bytes)

;Write $F7 x 1
    lda #$E6
l_7e4a:
    bit fdc_cmdst
    beq l_7e4a
    lda #$F7
    sta fdc_data        ;data = f7 (2 CRCs written)

;Write $4E x 22
    ldx #$16
l_7e56:
    lda #$E6
l_7e58:
    bit fdc_cmdst
    beq l_7e58
    lda #$4E
    sta fdc_data        ;data = 4e
    dex
    bne l_7e56

;Write $00 x 12
    ldx #$0C
l_7e67:
    lda #$E6
l_7e69:
    bit fdc_cmdst
    beq l_7e69
    lda #$00
    sta fdc_data        ;data = 0
    dex
    bne l_7e67

;Write $F5 x 3
    ldx #$03
l_7e78:
    lda #$E6
l_7e7a:
    bit fdc_cmdst
    beq l_7e7a
    lda #$F5
    sta fdc_data        ;data = f5 (writes a1)
    dex
    bne l_7e78

;Write $FB x 1
    lda #$E6
l_7e89:
    bit fdc_cmdst
    beq l_7e89
    lda #$FB            ;data = fb
    sta fdc_data

;Write $E5 x 128
    ldx #$80
l_7e95:
    lda #$E6
l_7e97:
    bit fdc_cmdst
    beq l_7e97
    lda #$E5            ;data = e5
    sta fdc_data
    dex
    bne l_7e95

;Write $F7 x 1
    lda #$E6
l_7ea6:
    bit fdc_cmdst
    beq l_7ea6
    lda #$F7
    sta fdc_data        ;data = f7

;Write $4E x 28
    ldx #$1C            ;TODO 28 sectors per track?
l_7eb2:
    lda #$E6
l_7eb4:
    bit fdc_cmdst
    beq l_7eb4
    lda #$4E
    sta fdc_data        ;data = 4e
    dex
    bne l_7eb2

;Write $4E x 1
    lda #$E6
l_7ec3:
    bit fdc_cmdst
    bne l_7ec3
    lda #$4E
    sta fdc_data        ;data = 4e

;
;End of Sector
;

    cpy #$1D            ;TODO Past last sector?  28 sectors per track on 5.25"
    bpl l_7ed4

    jmp l_7dea

l_7ed4:
    lda #$01
l_7ed6:
    bit fdc_cmdst
    bne l_7ed6
    cli
    jsr l_eccc         ;TODO XXX middle of an instruction in the ROM
    rts

filler:
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    !byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
