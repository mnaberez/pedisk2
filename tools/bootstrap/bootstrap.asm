;Bootstrap a PEDISK disk using a CBM disk
;
;This program is written as a PRG file to a CBM drive along with any number
;other PRG files named like "TRACK 0X00"..."TRACK 0X4C" that contain PEDISK
;track data.  When this program is run, the file "TRACK 0X00" is loaded into
;$0800 and its data is written to track 0 on the PEDISK.  The disk in the
;PEDISK must already been formatted.  After the track is written, the next track
;number is read from offset $04 and its "TRACK 0Xxx" file is loaded and written.
;The process repeats until the value at offset $04 is $FF, signaling the end.
;
;The format of a track PRG file is:
;  $00-$01  Load address (always $0800)
;  $02      Track number of the data
;  $03      Count of sectors in the data (26 for 8", 28 for 5.25")
;  $04      Next track after this one, or $FF if none
;  $05...   Sector data (128 bytes * count of sectors)
;

status        = $96       ;Status byte for I/O operations
lvflag        = $9d       ;LOAD/VERIFY flag (0=load, nonzero=verify)
fnlen         = $d1       ;Filename length
sa            = $d3       ;Secondary address
dn            = $d4       ;Device number
fnadr         = $da       ;Pointer: Filename address
linprt        = $cf83     ;BASIC 4 Print 256*A + X in decimal
loadop        = $f356     ;BASIC 4 load PRG file without relocating
chrout        = $ffd2     ;KERNAL write byte to default output (screen)

target_ptr    = $b7       ;Pointer: PEDISK target address for memory ops
dos           = $7800     ;Base address for the PEDISK RAM-resident portion
drive_sel     = dos+$0791 ;Drive select bit pattern to write to the latch
track         = dos+$0792 ;Track number to write to WD1793 (0-76 or $00-4c)
sector        = dos+$0793 ;Sector number to write to WD1793 (1-26 or $01-1a)
num_sectors   = dos+$0796 ;Number of sectors to read or write
rom           = $e800     ;Base address for the PEDISK ROM portion
drive_selects = rom+$022f ;Drive select bit patterns table
deselect      = rom+$030b ;Deselect drive
write_sectors = rom+$053f ;Write sectors
puts          = rom+$07e7 ;Print a null-terminated string

data          = $0800   ;Base address where track data will be loaded
data_track    = data+0  ;Track number for the data
data_sec_cnt  = data+1  ;Count of sectors in the data
data_next_trk = data+2  ;Next track after this one, or $FF if none
data_sectors  = data+3  ;Sector data (128 bytes * data_sec_cnt)

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

start:
    ldx #0
    lda drive_selects,x ;Get pattern to select PEDISK drive 0
    sta drive_sel       ;Store pattern to write to the drive select latch

    txa
    sta data_next_trk   ;Start at PEDISK track 0

    lda dn              ;Get current CBM device number
    bne got_dn          ;Branch to use current device if there is one
    lda #8
    sta dn              ;Default to CBM device number 8
got_dn:
    jsr print_cbm_unit
loop:
    jsr update_filename
    jsr print_load_file ;Print 'LOADING CBM DOS FILE "TRACK 0Xxx"'
    jsr load_track_file ;Load file from CBM drive, prints msg and exits if error
    jsr print_write_trk ;Print "WRITING PEDISK TRACK x"
    jsr write_track     ;Write track to PEDISK, prints msg and returns if error
    bne done            ;Branch if a PEDISK error occurred

    lda data_next_trk
    cmp #$ff
    bne loop
done:
    jmp deselect        ;Deselect PEDISK drive (unloads head) and return

print_cbm_unit:
    ;Print "USING CBM DOS UNIT x"
    lda #<using_cbm_unit
    ldy #>using_cbm_unit
    jsr puts
    lda #$00            ;High byte of number to print = 0
    ldx dn              ;Low byte of number to print = dn
    jsr linprt          ;Print 256*A + X in decimal
    lda #$0d
    jmp chrout

print_load_file:
;Print 'LOADING CBM DOS FILE "0Xxx"'
    lda #<loading_cbm_file
    ldy #>loading_cbm_file
    jsr puts
    lda #<filename
    ldy #>filename
    jsr puts
    lda #'"'
    jsr chrout
    lda #$0d
    jmp chrout

print_write_trk:
;Print "WRITING PEDISK TRACK x"
    lda #<writing_pedisk_track
    ldy #>writing_pedisk_track
    jsr puts
    lda #$00            ;High byte of number to print = 0
    ldx data_track      ;Low byte of number to print = track number
    jsr linprt          ;Print 256*A + X in decimal
    lda #$0d
    jmp chrout

load_track_file:
;Load the track data from a CBM program file.  This assumes that the
;current device number (dn) has already been set.
;
    lda #0
    sta status          ;Clear status byte
    sta lvflag          ;Set load/Verify select flag: 0 = Load

    lda #1
    sta sa              ;Secondary address = 1

    lda #filename_len
    sta fnlen           ;Set length of filename

    lda #<filename
    sta fnadr           ;Set low address of filename
    lda #>filename
    sta fnadr+1         ;Set high address of filename

    lda #<data
    sta $fb             ;Set low address to load data into
    lda #>data
    sta $fb+1           ;Set high address to load data into

    jmp loadop          ;Load the track data file
                        ;  If loading fails, control does not return.
                        ;  An error message like "?file not found in 10" will
                        ;  be printed and the BASIC prompt will return.

update_filename:
;Update the filename with the track number in data_next_trk
;
    lda data_next_trk
    lsr
    lsr
    lsr
    lsr
    and #$0f
    tax
    lda hex_chars,x
    sta filename_end-2
    lda data_next_trk
    and #$0f
    tax
    lda hex_chars,x
    sta filename_end-1
    rts
hex_chars:
    !text "0123456789ABCDEF"

write_track:
;Write the track data to the PEDISK
;
    lda data_track
    sta track               ;Set PEDISK track number
    lda #1
    sta sector              ;Set PEDISK sector number
    lda data_sec_cnt
    sta num_sectors         ;Set number of sectors to write
    lda #<data_sectors
    sta target_ptr          ;Set start address low byte
    lda #>data_sectors
    sta target_ptr+1        ;Set start address high byte
    jmp write_sectors       ;Write the sectors

using_cbm_unit: !text "USING CBM DOS UNIT", 0
loading_cbm_file: !text "LOADING CBM DOS FILE ", '"', 0
writing_pedisk_track: !text "WRITING PEDISK TRACK",0

filename: !text "TRACK 0X00", 0
filename_end = * - 1
filename_len = filename_end - filename
