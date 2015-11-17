;Write the first 100 sectors of a PEDISK disk.  The disk must already
;be formatted.  Use this to write the system files.

target_ptr  = $b7       ;Pointer: PEDISK target address for memory ops **
dos         = $7800     ;Base address for the RAM-resident portion
track       = dos+$0792 ;Track number to write to WD1793 (0-76 or $00-4c)
sector      = dos+$0793 ;Sector number to write to WD1793 (1-26 or $01-1a)
num_sectors = dos+$0796 ;Number of sectors to read or write
write_sectors = $ED3F
deselect    = $EB0B

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

writesys:
    lda #0
    sta track
    lda #1
    sta sector
    lda #100
    sta num_sectors
    lda #<data
    sta target_ptr
    lda #>data
    sta target_ptr+1
    jsr write_sectors
    jsr deselect
    rts

data:
    ;append a !byte directive with data for the first 100 sectors
