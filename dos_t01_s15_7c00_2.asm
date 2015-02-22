vartab = $2a
target_ptr = $b7
L7931 = $7931
pdos_prompt = $7A05
input_device = $7AD1
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
in_drive:
    !text " IN DRIVE"
hit_r_key:
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
    lda #$00
    sta $7F9A
    jsr input_device
L7CAE:
    sta $7F97

    ;Print "COPY TO DRIVE #"
    ldy #>copy_to
    lda #<copy_to
    jsr puts

    jsr input_device
    sta $7F98
    cmp $7F97
    bne L7CC8
    lda #$80
    sta $7F9A
L7CC8:
    jsr L7DCD
    lda $7F97
    sta drive_sel
    lda #$00
    sta $7F99
    sta track
    lda #$01
    sta sector
    lda #$00
    sta target_ptr
    lda #$7F
    sta target_ptr+1
    jsr read_a_sector
    beq L7CEE
L7CEB:
    jmp pdos_prompt
L7CEE:
    lda $7F97
    jsr L7DE3
    jsr read_sectors
    bne L7CEB
    bit $7F9A
    bpl L7D4D
L7CFE:
    ;Print "PUT COPY"
    ldy #>put_copy
    lda #<put_copy
    jsr puts

    lda #$00
    sta latch
    jsr L7DDB
    lda #$00
    sta track
    lda #$01
    sta sector
    sta num_sectors
    lda #$00
    sta target_ptr
    lda #$7E
    sta target_ptr+1
    jsr read_a_sector
    bne L7CEB
    lda $7F99
    bne L7D3C
    ldx #$07
L7D2E:
    lda $7E00,x
    sta $0400,x
    dex
    bpl L7D2E
    stx $040F
    bne L7D4D
L7D3C:
    lda $7E0F
    cmp #$FF
    beq L7D4D

    ;Print "* WRONG DISK *"
    lda #<wrong_disk
    ldy #>wrong_disk
    jsr puts

    jmp L7CFE
L7D4D:
    lda $7F98
    jsr L7DE3
    jsr write_sectors
L7D56:
    bne L7CEB
    lda $7F99
    clc
    adc $7F9C
    sta $7F99
    cmp $7F09
    beq L7D69
    bpl L7D95
L7D69:
    cmp $7F9E
    bmi L7D8A
    lda #$28            ;TODO 40/41 tracks?
    sec
    sbc $7F99
    bcc L7D95
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
    bit $7F9A
    bpl L7D92
    jsr L7DCD
L7D92:
    jmp L7CEE
L7D95:
    lda #$00
    sta track
    lda #$01
    sta sector
    sta num_sectors
    lda #$00
    sta target_ptr
    lda #$7E
    sta target_ptr+1
    jsr read_a_sector
    bne L7D56
    lda #$20
    sta $7E0F
    jsr write_a_sector
    bne L7D56
    lda #$04
    sta vartab
    sta vartab+1
    lda #$00
    sta $0400
    sta $0401
    sta $0402
    jmp pdos_prompt
L7DCD:
    ;Print "PUT ORIGINAL"
    ldy #>put_original
    lda #<put_original
    jsr puts

    ;Print "IN DRIVE"
    lda #<in_drive
    ldy #>in_drive
    jsr puts
L7DDB:
    jsr get_char
    cmp #$52
    bne L7DDB
    rts
L7DE3:
    sta drive_sel
    lda $7F99
    sta track
    lda #$01
    sta sector
    lda $7F9B
    sta num_sectors
    ldx #$00
    stx target_ptr
    lda #$04
    sta target_ptr+1
    rts
