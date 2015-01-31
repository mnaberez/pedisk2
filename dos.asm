chrget = $70 ;Subroutine: Get Next Byte of BASIC Text
L0076 = $0076
L3400 = $3400
LC873 = $C873
LCF6D = $CF6D
check_colon = $EA44
deselect = $EB0B
restore = $EB5E
put_spc = $EB7A
put_spc_hex = $EB7F
put_spc_byte = $EB84
disk_error = $EC96
read_a_sector = $ECDF
read_sectors = $ECE4
write_a_sector = $ED3A
write_sectors = $ED3F
find_file = $EE33
load_file = $EE9E
LEF59 = $EF59
puts = $EFE7
chrout = $FFD2

;In the zero page locations below, ** indicates the PEDISK destroys
;a location that is used for some other purpose by CBM BASIC 4.

dir_ptr     = $22       ;Pointer: PEDISK directory **
vartab      = $2a       ;Pointer: Start of BASIC variables

dos         = $7800     ;Base address for the RAM-resident portion
buf_1       = dos+$0680 ;Unknown, possible buffer area #1
buf_2       = dos+$06a0 ;Unknown, possible buffer area #2
buf_3       = dos+$06c0 ;Unknown, possible buffer area #3
buf_4       = dos+$06e0 ;Unknown, possible buffer area #4
dir_sector  = dos+$0700 ;128 bytes for directory sector used by find_file
wedge_y     = dos+$078a ;Temp storage for Y register used by the wedge
wedge_sp    = dos+$078b ;Temp storage for stack pointer used by the wedge
num_sectors = dos+$0796 ;Number of sectors to read or write
filename    = dos+$07a0 ;6 byte buffer used to store filename
wedge_stack = dos+$07e0 ;32 bytes for preserving the stack used by the wedge
drive_sel_f = dos+$07b1 ;Drive select bit pattern parsed from a filename

        *=dos

dos_save:
        jmp     _dos_save
dos_open:
        jmp     _dos_open
dos_close:
        jmp     _dos_close
dos_input:
        jmp     _dos_input
dos_print:
        jmp     _dos_print
dos_run:
        jmp     _dos_run
dos_sys:
        jmp     _dos_sys
dos_list:
        jmp     _dos_list

dos_stop:
        ;fall through

_dos_stop:
        lda     vartab
        sec
        sbc     $28
        sta     $7FA6
        sta     $58
        lda     $2B
        sbc     $29
        sta     $59
        sta     $7FA7
        lda     $28
        sta     $7FA8
        lda     $29
        sta     $7FA9
        jsr     L7891
        lda     num_sectors   ;Number of sectors to read or write
        sta     $7FAE
        lda     #$00
        sta     $7FAF
        lda     #$03
        sta     $7FAA
        jsr     find_file
        tax
        bmi     L7890
        bne     L7857
        lda     #$05
L7852:  jsr     disk_error
        bne     L7890
L7857:  lda     #$00
        sta     $7FAB
        jsr     L78A2
        bne     L7890
        lda     $7FB5
        beq     L786A
        lda     #$06
        bne     L7852

L786A:  lda     $7FA8   ;Load address low byte
        sta     $B7

        lda     $7FA9   ;Load address high byte
        sta     $B8

        lda     $56
        sta     $7F92   ;Track number to write to WD1793 (0-76 or $00-4c)
        lda     $57
        sta     $7F93   ;Sector number to write to WD1793 (1-26 or $01-1a)
        lda     $7FAE
        sta     num_sectors   ;Number of sectors to read or write
        jsr     write_sectors
        bne     L7890
        lda     #$00
        sta     $E900   ;Drive Select Latch
        lda     #$00
L7890:  rts
L7891:  lda     $58
        clc
        adc     #$7F
        bcc     L789A
        inc     $59
L789A:  asl     ;a
        lda     $59
        rol     ;a
        sta     num_sectors   ;Number of sectors to read or write
        rts
L78A2:  lda     #$00
        sta     $7FB5
        lda     $56
        sta     $7FAC
        lda     $57
        sta     $7FAD
        jsr     L78F1
        lda     $58
        cmp     #$51
        bmi     L78C0
        lda     #$2B
        sta     $7FB5
        rts
L78C0:  ldy     #$0F
L78C2:  lda     filename,y
        sta     (dir_ptr),y
        dey
        bpl     L78C2
        lda     $7F93   ;Sector number to write to WD1793 (1-26 or $01-1a)
        cmp     #$01
        beq     L78E0
        jsr     write_a_sector
        bne     L7890
        lda     #$01
        sta     $7F93   ;Sector number to write to WD1793 (1-26 or $01-1a)
        jsr     read_a_sector
        bne     L7890
L78E0:  inc     $7F08
        lda     $58
        sta     $7F09
        lda     $59
        sta     $7F0A
        jsr     write_a_sector
        rts
L78F1:  jsr     L790D
        lda     $7FAD
        clc
        adc     $59
        cmp     #$1D
        bmi     L7902
        sbc     #$1C
        inc     $58
L7902:  sta     $59
        lda     $7FAC
        clc
        adc     $58
        sta     $58
        rts
L790D:  lda     $7FAE
        sec
        sbc     #$01
        sta     $5E
        lda     $7FAF
        sbc     #$00
        sta     $5F
        lda     #$1C
        sta     $60
        lda     #$00
        sta     $61
        jsr     L797B
        ldx     $5E
        inx
        stx     $59
        lda     $62
        sta     $58
        rts
        jsr     L7948
        ldx     #$10
L7936:  jsr     L7953
        bcc     L793E
        jsr     L7958
L793E:  dex
        beq     L7947
        jsr     L7972
        jmp     L7936
L7947:  rts
L7948:  lda     #$00
        sta     $62
        sta     $63
        sta     $64
        sta     $65
        rts
L7953:  asl     $5E
        rol     $5F
        rts
L7958:  lda     $60
        clc
        adc     $62
        sta     $62
        lda     $61
        adc     $63
        sta     $63
        lda     #$00
        adc     $64
        sta     $64
        lda     #$00
        adc     $65
        sta     $65
        rts
L7972:  asl     $62
        rol     $63
        rol     $64
        rol     $65
        rts
L797B:  ldx     #$00
        stx     $62
        stx     $63
        cpx     $60
        bne     L798E
        cpx     $61
        bne     L798E
        stx     $5E
        stx     $5F
L798D:  rts
L798E:  lda     $61
        cmp     $5F
        bcc     L799E
        bne     L79AB
        lda     $60
        cmp     $5E
        beq     L799E
        bcs     L79AB
L799E:  inx
        asl     $60
        rol     $61
        bcc     L798E
        dex
        ror     $61
        jmp     L79B0
L79AB:  dex
        bmi     L798D
        lsr     $61
L79B0:  ror     $60
        sec
        lda     $5E
        sbc     $60
        pha
        lda     $5F
        sbc     $61
        php
        rol     $62
        rol     $63
        plp
        bcs     L79C8
        pla
        jmp     L79AB
L79C8:  sta     $5F
        pla
        sta     $5E
        jmp     L79AB

_dos_sys:
        lda     #$00    ;Load address low byte
        sta     $B7
        lda     #$7A    ;Load address high byte
        sta     $B8

        ldx     #$00
        stx     $7F92   ;Track number to write to WD1793 (0-76 or $00-4c)

        inx
        stx     $7F91   ;Drive select bit pattern to write to the latch

        lda     #$16
        sta     $7F93   ;Sector number to write to WD1793 (1-26 or $01-1a)

        lda     #$04
        sta     num_sectors   ;Number of sectors to read or write

        jsr     read_sectors
        bne     L79F3
        jmp     L7A00
L79F3:  jmp     restore
        !byte   $B3
        !byte   $FA
        rti
        brk
        brk
        rti
        jsr     L3400
        !byte   $01
L7A00:  !byte   $46
L7A01:  eor     #$25
        brk

_dos_save:
        jsr     _dos_stop
        jmp     restore
L7A0A:  ldx     #$03
        lda     #$7E
        sta     dir_ptr+1
        lda     #$E0
L7A12:  sta     dir_ptr
        ldy     #$05
L7A16:  lda     (dir_ptr),y
        cmp     filename,y
        bne     L7A2D
        dey
        bpl     L7A16
        ldy     #$11
        lda     (dir_ptr),y
        cmp     drive_sel_f
        bne     L7A2D
L7A29:  stx     $7F8F
        rts
L7A2D:  dex
        bmi     L7A29
        lda     dir_ptr
        sec
        sbc     #$20
        bne     L7A12

_dos_open:
        jsr     L7A0A
        inx
        beq     L7A41
        lda     #$30
        bne     L7A73
L7A41:  ldx     #$03
        ldy     #$60
L7A45:  lda     buf_1,y
        cmp     #$FF
        beq     L7A5B
        dex
        bpl     L7A53
        lda     #$31
        bne     L7A73
L7A53:  tya
        sec
        sbc     #$20
        tay
        jmp     L7A45
L7A5B:  stx     $7F8F
        jsr     find_file
        bpl     L7A66
        jmp     restore
L7A66:  pha
        jsr     L0076
        cmp     #$A2
        bne     L7AD6
        pla
        bne     L7A75
        lda     #$32
L7A73:  bne     L7ADB
L7A75:  lda     #$64
        sta     $7FAE
        lda     #$80
        sta     $7FA6
        sta     $7FA8
        lda     #$00
        sta     $7FA7
        sta     $7FA9
        sta     $7FAA
        sta     $7FAB
        sta     $7FAF
        jsr     chrget
        cmp     #$C3
        bne     L7AAC
        jsr     chrget
        bcs     L7AB3
        jsr     LC873
        lda     $11
        sta     $7FAE
        lda     $12
        sta     $7FAF
L7AAC:  jsr     L78A2
        bne     L7B2C
        beq     L7AE8
L7AB3:  jsr     LCF6D
        lda     $07
        bne     L7AC2
        bit     $08
        bmi     L7AC6
        lda     #$34
        bne     L7ADB
L7AC2:  lda     #$35
        bne     L7ADB
L7AC6:  ldy     #$00
        lda     ($44),y
        sta     $7FAF
        iny
        lda     ($44),y
        sta     $7FAE
        jmp     L7AAC
L7AD6:  pla
        beq     L7ADE
        lda     #$32
L7ADB:  jmp     L7B3D
L7ADE:  ldy     #$0F
L7AE0:  lda     (dir_ptr),y
        sta     filename,y
        dey
        bpl     L7AE0
L7AE8:  lda     #$00
        sta     $7FB2
        sta     $7FB3
        sta     $7FB5
        lda     $7FAC
        sta     $7FBA
        ldx     $7FAD
        dex
        stx     $7FBB
L7B00:  jsr     L7B55
        ldy     #$00
        lda     $7FB3
        sta     ($44),y
        iny
        lda     $7FB2
        sta     ($44),y
        jsr     L7B59
        ldy     #$00
        lda     #$00
        sta     ($44),y
        lda     $7FB5
        iny
        sta     ($44),y
        jsr     L7B2F
L7B22:  lda     filename,y
        sta     buf_1,x
        dex
        dey
        bpl     L7B22
L7B2C:  jmp     restore
L7B2F:  lda     $7F8F
        asl     ;a
        asl     ;a
        asl     ;a
        asl     ;a
        asl     ;a
        adc     #$1F
        tax
        ldy     #$1F
        rts
L7B3D:  sta     $7FB5
        ldy     #$00
        lda     ($77),y
L7B44:  cmp     #$00
        beq     L7B52
        cmp     #$3A
        beq     L7B52
        jsr     chrget
        jmp     L7B44
L7B52:  jmp     L7B00
L7B55:  lda     #$49
        bne     L7B5B
L7B59:  lda     #$43
L7B5B:  sta     L7A01
        lda     $77
        pha
        lda     $78
        pha
        lda     #$00
        sta     $77
        lda     #$7A
        sta     $78
        jsr     LCF6D
        pla
        sta     $78
        pla
        sta     $77
        rts

_dos_close:
        jsr     L7BA6
        ldy     #$00
        lda     ($77),y
        cmp     #$80
        bne     L7B91
        jsr     chrget
        jsr     L7C22
        lda     #$FF
        sta     dir_sector
        jsr     write_a_sector
        bne     L7BA3
L7B91:  lda     #$FF
        sta     filename
        sta     $7FB5
        lda     #$00
        sta     $E900
        lda     #$FF
        jmp     L7B00
L7BA3:  jmp     restore
L7BA6:  jsr     L7A0A
        inx
        bne     L7BB1
        lda     #$07
        jmp     L7B3D
L7BB1:  jsr     L7B2F
L7BB4:  lda     buf_1,x
        sta     filename,y
        dex
        dey
        bpl     L7BB4
        lda     #$00
        sta     $7FB5
        rts
L7BC4:  ldy     #$00
        lda     ($77),y
        cmp     #$B9
        bne     L7C22
        jsr     chrget
        jsr     L7B55
        ldy     #$00
        lda     ($44),y
        sta     $7FB3
        iny
        lda     ($44),y
        sta     $7FB2
        ora     $7FB3
        bne     L7BE9
        lda     #$08
        jmp     L7B3D
L7BE9:  lda     $7FB2
        sec
        sbc     #$01
        sta     $5E
        lda     $7FB3
        sbc     #$00
        sta     $5F
        lda     #$1C
        sta     $60
        lda     #$00
        sta     $61
        jsr     L797B
        lda     $5E
        clc
        adc     $7FAD
        pha
        lda     $62
        adc     $7FAC
        sta     $7FBA
        pla
        cmp     #$1D
        bcc     L7C1C
        inc     $7FBA
        sbc     #$1C
L7C1C:  sta     $7FBB
        jmp     L7C3C
L7C22:  inc     $7FB2
        bne     L7C2A
        inc     $7FB3
L7C2A:  inc     $7FBB
        lda     $7FBB
        cmp     #$1D
        bcc     L7C3C
        inc     $7FBA
        lda     #$01
        sta     $7FBB
L7C3C:  lda     $7FBA
        sta     $7F92   ;Track number to write to WD1793 (0-76 or $00-4c)
        cmp     $7FBC
        bcc     L7C56
        bne     L7C51
        lda     $7FBB
        cmp     $7FBD
        bcc     L7C56
L7C51:  lda     #$08
        jmp     L7B3D

L7C56:  lda     $7FBB
        sta     $7F93   ;Number of sectors to read or write

        lda     #$00    ;Load address low byte
        sta     $B7

        lda     #$7F    ;Load address high byte
        sta     $B8

        lda     drive_sel_f
        sta     $7F91   ;Drive select bit pattern to write to the latch
        rts

_dos_input:
        jsr     L7BA6
        jsr     L7BC4
        jsr     read_a_sector
        bne     L7CA2
        jsr     LCF6D
        bit     $07
        bmi     L7C82
        lda     #$09
L7C7F:  jmp     L7B3D
L7C82:  lda     dir_sector
        cmp     #$FF
        beq     L7C7F
        cmp     #$80
        bcc     L7C91
        lda     #$0A
        bne     L7C7F
L7C91:  ldy     #$00
        sta     ($44),y
        iny
        lda     #$01
        sta     ($44),y
        iny
        lda     #$7F
        sta     ($44),y
        jmp     L7B00
L7CA2:  jmp     restore

_dos_print:
        jsr     L7BA6
        jsr     L7BC4
        jsr     LCF6D
        bit     $07
        bmi     L7CB7
        lda     #$09
L7CB4:  jmp     L7B3D
L7CB7:  ldy     #$00
        lda     ($44),y
        cmp     #$80
        bcc     L7CC3
        lda     #$0A
        bne     L7CB4
L7CC3:  sta     dir_sector
        iny
        lda     ($44),y
        sta     dir_ptr
        iny
        lda     ($44),y
        sta     dir_ptr+1
        ldy     #$7E
L7CD2:  lda     (dir_ptr),y
        sta     dir_sector+1,y
        dey
        bpl     L7CD2
        jsr     write_a_sector
        bne     L7CA2
        jmp     L7B00

_dos_run:
        jsr     load_file
        txa
        bne     L7D10
        lda     #$0C
        sta     $77
        lda     #$7D
        sta     $78
        ldx     #$1F
        sei
L7CF3:  lda     wedge_stack,x
        sta     $01E0,x
        dex
        bpl     L7CF3
        ldx     wedge_sp
        txs
        cli
        ldy     wedge_y
        ldx     $7F89
        lda     #$8A
        jmp     check_colon
        txa
        brk
        brk
        brk
L7D10:  jmp     restore

_dos_list:
        lda     #<device
        ldy     #>device
        jsr     puts
        jsr     LEF59
        cmp     #'0'
        bmi     _dos_list
        cmp     #'4'
        bpl     _dos_list
        jmp     L7D83

device:
        !text $0d,$0d,"DEVICE?",0
more:
        !text $0d,"MORE",$2e,$2e,0
diskname:
        !text $93,"DISKNAME= ",0
dirheader:
        !text $0d,$0d,"NAME  TYPE TRK SCTR #SCTRS",0
filetypes:
        !text "SEQ",0
        !text "IND",0
        !text "ISM",0
        !text "BAS",0
        !text "ASM",0
        !text "LD ",0
        !text "TXT",0
        !text "OBJ",0

L7D83:  and     #$03
        tax
        sec
L7D87:  rol     ;a
        dex
        bpl     L7D87
        sta     $7F91   ;Drive select bit pattern to write to the latch

        ldx     #$00
        stx     $7F92   ;Track number to write to WD1793 (0-76 or $00-4c)

        inx
        stx     $7F93   ;Sector number to write to WD1793 (1-26 or $01-1a)

L7D97:  lda     #$00    ;Load address low byte
        sta     $B7
        sta     dir_ptr

        lda     #$7F    ;Load address high byte
        sta     $B8
        sta     dir_ptr+1

        jsr     read_a_sector
        beq     L7DAB
        jmp     restore
L7DAB:  lda     #<diskname
        ldy     #>diskname
        jsr     puts
        ldy     #$00
        ldx     #$08
L7DB6:  lda     (dir_ptr),y
        jsr     chrout
        iny
        dex
        bne     L7DB6
        lda     #<dirheader
        ldy     #>dirheader
        jsr     puts
L7DC6:  lda     #$12
        sta     $27
        lda     #$0D
        jsr     chrout
L7DCF:  lda     dir_ptr
        clc
        adc     #$10
        bpl     L7DE3
        inc     $7F93   ;Sector number to write to WD1793 (1-26 or $01-1a)
        jsr     read_a_sector
        beq     L7DE1
        jmp     restore
L7DE1:  lda     #$00
L7DE3:  sta     dir_ptr
        ldy     #$00
        lda     (dir_ptr),y
        cmp     #$FF
        bne     L7DF0
        jmp     L7E56
L7DF0:  ldy     #$05
        lda     (dir_ptr),y
        cmp     #$FF
        beq     L7DCF
        lda     #$0D
        jsr     chrout
        ldy     #$00
L7DFF:  lda     (dir_ptr),y
        jsr     chrout
        iny
        cpy     #$06
        bmi     L7DFF
        jsr     put_spc
        ldy     #$0A
        lda     (dir_ptr),y
        asl     ;a
        asl     ;a
        clc
        adc     #<filetypes
        ldy     #>filetypes
        jsr     puts
        jsr     put_spc
        ldy     #$0C
        lda     (dir_ptr),y
        jsr     put_spc_byte
        jsr     put_spc
        ldy     #$0D
        lda     (dir_ptr),y
        jsr     put_spc_hex
        jsr     put_spc
        jsr     put_spc
        ldy     #$0F
        lda     (dir_ptr),y
        jsr     put_spc_hex
        ldy     #$0E
        lda     (dir_ptr),y
        jsr     put_spc_byte
        dec     $27
        bmi     L7E49
        jmp     L7DCF
L7E49:  lda     #<more
        ldy     #>more
        jsr     puts
        jsr     LEF59
        jmp     L7DC6
L7E56:  lda     #$0D
        jsr     chrout
        jsr     deselect
        jsr     chrget
        jmp     restore
        !byte   $CF
        sbc     $FFF4,x
        cpy     $8C
        !byte   $04
        sty     $1804
L7E6E:  txa
        bcc     L7E6E
        sbc     $FFFF,x
        sbc     $FFFF
        !byte   $FF
        php
        dex
        !byte   $1C
        !byte   $12
        !byte   $92
        and     $BD03,y