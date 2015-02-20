fdc          = $e980    ;WD1793 Floppy Disk Controller
fdc_cmdst    = fdc+0    ;  Command/status register
fdc_track    = fdc+1    ;  Track register
fdc_sector   = fdc+2    ;  Sector register
fdc_data     = fdc+3    ;  Data register

L000D = $0D
hex_save_a = $26
target_ptr = $b7
L7A05 = $7A05
L7AD1 = $7AD1
dir_sector  = $7f00
status_mask = $7f90
drive_sel = $7f91
track = $7f92
sector = $7f93
status = $7f94
linprt = $CF83          ;BASIC Print 256*A + X in decimal
select_drive = $EBA0
l_ec0d = $EC0D
LECCC = $ECCC
write_a_sector = $ED3A
l_ef7b = $EF7B
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

    jsr L7AD1
    sta drive_sel

    ;Print "SURE? (Y-YES)"
    lda #<are_you_sure
    ldy #>are_you_sure
    jsr puts

    jsr l_ef7b
    cmp #'Y'
    bne exit

    jsr select_drive
    bne exit
    lda #$03
    jsr l_ec0d
    lda fdc_cmdst
    and #$40
    bne protected
    lda fdc_cmdst
    and #$9D
    cmp #$04
    beq format
    lda #$F0
    jmp puts_error_exit

exit:
    jmp L7A05

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
    ldx #$00
    stx track
    inx
    stx sector
    stx fdc_sector

track_loop:
    jsr format_track

    ;Print "FORMAT TRACK "
    lda #<finished_track
    ldy #>finished_track
    jsr puts

    ;Print the track number in decimal
    lda #$00            ;High byte of number to print = 0
    ldx track           ;Low byte of number to print = track
    jsr linprt          ;Print 256*A + X in decimal

    inc track
    lda #$28            ;TODO 40/41 tracks?
    cmp track
    bpl track_loop

    lda #<dir_sector
    sta target_ptr
    lda #>dir_sector
    sta target_ptr+1

    ldy #$7F
    lda #$FF
L7CF9:
    sta (target_ptr),y
    dey
    bpl L7CF9

    ldx #$00
    stx track
    inx
    inx
    stx sector
L7D08:
    jsr write_a_sector
L7D0B:
    bne exit
    lda status
    beq L7D17
    lda #$F1
    jmp puts_error_exit

L7D17:
    ldx sector
    inx
    stx sector
    cpx #$09
    bmi L7D08
    lda #$01
    sta sector

    ;PRINT "NAME? "
    lda #<enter_name
    ldy #>enter_name
    jsr puts

    ldx #$00
L7D30:
    stx hex_save_a
    jsr l_ef7b          ;Wait for a char, echo it, return it in A
    ldx hex_save_a
    sta dir_sector,x
    inx
    cpx #$08
    bcc L7D30

    lda #$00
    sta dir_sector+$08
    sta dir_sector+$09
    lda #$09
    sta dir_sector+$0a
    lda #$20
    sta dir_sector+$0b
    sta dir_sector+$0c
    sta dir_sector+$0d
    sta dir_sector+$0e
    sta dir_sector+$0f
    jsr write_a_sector
    bne L7D0B

    ;Print "FINISHED!"
    lda #<finished_disk
    ldy #>finished_disk
    jsr puts

    jmp L7A05

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

    jmp L7A05

format_track:
    lda track
    sta fdc_data
    lda #$13
    jsr l_ec0d
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
