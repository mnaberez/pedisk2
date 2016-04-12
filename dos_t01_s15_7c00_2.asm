vartab = $2a
target_ptr = $b7
copy_buffer = $0400 ;Stores data during copy (overwrites BASIC program text)
L7931 = $7931
pdos_prompt = $7A05
input_device = $7AD1
copy_sector = $7e00 ;128 byte buffer used only by this copy program
dir_sector = $7f00
tmp_7f97 = $7f97
src_drive_sel = $7f97 ;Drive select pattern of source drive
tmp_7f98 = $7f98
dst_drive_sel = tmp_7f98 ;Drive select pattern of destination drive
copy_track = $7f99 ;Current track number for copy
tmp_7f9a = $7f9a
copy_mode = tmp_7f9a ;Copy mode flag (0=two drives, $80=one drive)
read_a_sector = $ECDF
read_sectors = $ECE4
write_a_sector = $ED3A
write_sectors = $ED3F
get_char = $EF7B
puts = $EFE7

latch        = $e900    ;Drive Select Latch
                        ;  bit function
                        ;  === ======
                        ;  7-4 not used
                        ;  3   motor ??
                        ;  2   drive 3 select
                        ;  1   drive 2 select
                        ;  0   drive 1 select

dos         = $7800     ;Base address for the RAM-resident portion
drive_sel   = dos+$0791 ;Drive select bit pattern to write to the latch
track       = dos+$0792 ;Track number to write to WD1793 (0-76 or $00-4c)
sector      = dos+$0793 ;Sector number to write to WD1793 (1-26 or $01-1a)
num_sectors = dos+$0796 ;Number of sectors to read or write

    *=$7c00

    jmp start

copy_from:
    !text $0d,"PEDISK II COPY UTILITY",$0d
    !text "COPY FROM DRIVE #",0
copy_to:
    !text $0d,"COPY TO DRIVE #",0
put_original:
    !text $0d,"PUT ORIGINAL",0
put_copy:
    !text $0d,"PUT COPY"
in_drv_hit_r:
    !text " IN DRIVE"
    !text $0d,"HIT R KEY",0
wrong_disk:
    !text $0d,"* WRONG DISK *",$0d,0

start:
    ;Print banner and "COPY FROM DRIVE #"
    ldy #>copy_from
    lda #<copy_from
    jsr puts

    lda #$08
    sta $7F9C
    sta $5E
    lda #$00
    sta $5F
    sta $61
    lda #$1C            ;TODO 28 sectors per track?
    sta $60
    jsr L7931
    lda $62
    sta $7F9D
    sta $7F9B
    lda #$28            ;TODO 40/41 tracks?
    sec
    sbc $7F9C
    sta $7F9E

    ;Init copy mode flag to two drive mode (0=two drives, $80=one drive)
    lda #$00
    sta copy_mode

    ;Get drive select pattern of source drive
    jsr input_device    ;Print "DEVICE? ", get num, returns drv sel pat in A
    sta src_drive_sel

    ;Print "COPY TO DRIVE #"
    ldy #>copy_to
    lda #<copy_to
    jsr puts

    ;Get drive select pattern of destination drive
    jsr input_device    ;Print "DEVICE? ", get num, returns drv sel pat in A
    sta dst_drive_sel

    ;Skip setting copy mode flag to single drive if drives are different
    cmp src_drive_sel
    bne start_copy     ;Branch if drives are different

    ;Source and destination drives are the same
    ;Set copy mode flag to one drive
    lda #$80
    sta copy_mode

start_copy:
    jsr insert_src_disk
    lda src_drive_sel
    sta drive_sel
    lda #$00
    sta copy_track
    sta track
    lda #$01
    sta sector
    lda #<dir_sector
    sta target_ptr
    lda #>dir_sector
    sta target_ptr+1
    jsr read_a_sector
    beq copy_loop       ;Branch if read succeeded
L7CEB:
    jmp pdos_prompt

copy_loop:
    lda src_drive_sel
    jsr set_rw_params
    jsr read_sectors
    bne L7CEB           ;Branch if a disk error occurred

    ;Skip disk swap if copying in two drive mode
    bit copy_mode
    bpl L7D4D           ;Branch if two drive mode

insert_dst_disk:
    ;Print "PUT COPY"
    ldy #>put_copy
    lda #<put_copy
    jsr puts

    ;Deselect drives and stop motors
    lda #$00            ;Bit 3 = WD1793 /DDEN=0 (double density mode)
                        ;All other bits off = deselect drives, stop motors
    sta latch

    ;Wait for user to press the "R" key
    jsr wait_for_r_key

    lda #$00
    sta track
    lda #$01
    sta sector
    sta num_sectors
    lda #<copy_sector
    sta target_ptr
    lda #>copy_sector
    sta target_ptr+1
    jsr read_a_sector
    bne L7CEB           ;Branch if a disk error occurred
    lda copy_track
    bne L7D3C
    ldx #$07
L7D2E:
    lda copy_sector,x
    sta copy_buffer,x
    dex
    bpl L7D2E
    stx copy_buffer+$0f
    bne L7D4D
L7D3C:
    lda copy_sector+$0f
    cmp #$FF
    beq L7D4D

    ;Print "* WRONG DISK *"
    lda #<wrong_disk
    ldy #>wrong_disk
    jsr puts

    jmp insert_dst_disk
L7D4D:
    lda dst_drive_sel
    jsr set_rw_params
    jsr write_sectors
L7D56:
    bne L7CEB           ;Branch if a disk error occurred
    lda copy_track
    clc
    adc $7F9C
    sta copy_track
    cmp dir_sector+$09  ;Get next open track
    beq L7D69
    bpl finish_and_exit
L7D69:
    cmp $7F9E
    bmi L7D8A
    lda #$28            ;TODO 40/41 tracks?
    sec
    sbc copy_track
    bcc finish_and_exit
    sta $5E
    lda #$1C            ;TODO 28 sectors per track?
    sta $60
    lda #$00
    sta $5F
    sta $61
    jsr L7931
    lda $62
    sta $7F9B
L7D8A:
    ;Skip disk swap if copying in two drive mode
    bit copy_mode
    bpl L7D92           ;Branch if two drive mode

    jsr insert_src_disk
L7D92:
    jmp copy_loop

finish_and_exit:
    lda #$00
    sta track
    lda #$01
    sta sector
    sta num_sectors
    lda #<copy_sector
    sta target_ptr
    lda #>copy_sector
    sta target_ptr+1
    jsr read_a_sector
    bne L7D56           ;Branch if a disk error occurred
    lda #$20
    sta copy_sector+$0f
    jsr write_a_sector
    bne L7D56           ;Branch if a disk error occurred

    ;Set start of BASIC variables to $0404
    lda #>copy_buffer   ;TODO this code must be changed to set low byte and
                        ;     high byte separately if copy_buffer ever moves
    sta vartab          ;Set vartab low byte to $04
    sta vartab+1        ;Set vartab high byte to $04

    ;Store an empty BASIC program to reset BASIC since we overwrote
    ;the BASIC program area to use it as buffer storage.
    lda #$00
    sta copy_buffer+$00 ;End of current BASIC line
    sta copy_buffer+$01 ;End of BASIC program first byte
    sta copy_buffer+$02 ;End of BASIC program second byte

    jmp pdos_prompt

insert_src_disk:
    ;Print "PUT ORIGINAL"
    ldy #>put_original
    lda #<put_original
    jsr puts

    ;Print " IN DRIVE" followed by "HIT R KEY"
    lda #<in_drv_hit_r
    ldy #>in_drv_hit_r
    jsr puts

wait_for_r_key:
;Wait for the user to press the "R" key
;
    jsr get_char
    cmp #'R'
    bne wait_for_r_key
    rts

set_rw_params:
    sta drive_sel
    lda copy_track
    sta track
    lda #$01
    sta sector
    lda $7F9B
    sta num_sectors
    ldx #<copy_buffer
    stx target_ptr
    lda #>copy_buffer
    sta target_ptr+1
    rts
