latch        = $e900    ;Drive Select Latch
                        ;  bit function
                        ;  === ======
                        ;  7-4 not used
                        ;  3   motor ??
                        ;  2   drive 3 select
                        ;  1   drive 2 select
                        ;  0   drive 1 select

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
put_hex_byte = $EB84
disk_error = $EC96
read_a_sector = $ECDF
read_sectors = $ECE4
write_a_sector = $ED3A
write_sectors = $ED3F
find_file = $EE33
load_file = $EE9E
l_ef59 = $EF59 ;Get a character and test for {STOP}
puts = $EFE7
chrin = $FFCF
chrout = $FFD2

;In the zero page locations below, ** indicates the PEDISK destroys
;a location that is used for some other purpose by CBM BASIC 4.

valtyp      = $07       ;Data type of value: 0=numeric, $ff=string
dir_ptr     = $22       ;Pointer: PEDISK directory **
edit_pos    = $27       ;PEDISK memory editor position on current line **
txttab      = $28       ;Pointer: Start of BASIC text
vartab      = $2a       ;Pointer: Start of BASIC variables
varpnt      = $44       ;Pointer: Current BASIC variable
open_track  = $56       ;Next track open for a new file **
open_sector = $57       ;Next sector open for a new file **
txtptr      = $77       ;Pointer: Current Byte of BASIC Text
target_ptr  = $b7       ;Pointer: PEDISK target address for memory ops **

dos         = $7800     ;Base address for the RAM-resident portion
buf_1       = dos+$0680 ;Unknown, possible buffer area #1
buf_2       = dos+$06a0 ;Unknown, possible buffer area #2
buf_3       = dos+$06c0 ;Unknown, possible buffer area #3
buf_4       = dos+$06e0 ;Unknown, possible buffer area #4
dir_sector  = dos+$0700 ;128 bytes for directory sector used by find_file
wedge_x     = dos+$0789 ;Temp storage for X register used by the wedge
wedge_y     = dos+$078a ;Temp storage for Y register used by the wedge
wedge_sp    = dos+$078b ;Temp storage for stack pointer used by the wedge
drive_sel   = dos+$0791 ;Drive select bit pattern to write to the latch
track       = dos+$0792 ;Track number to write to WD1793 (0-76 or $00-4c)
sector      = dos+$0793 ;Sector number to write to WD1793 (1-26 or $01-1a)
num_sectors = dos+$0796 ;Number of sectors to read or write
filename    = dos+$07a0 ;6 byte buffer used to store filename
wedge_stack = dos+$07e0 ;32 bytes for preserving the stack used by the wedge
drive_sel_f = dos+$07b1 ;Drive select bit pattern parsed from a filename

L0070 = $70
L0076 = $76
L0D00 = $0D00
LB8F6 = $B8F6
LC12B = $C12B
LEA44 = $EA44
LEB0B = $EB0B
LEB5E = $EB5E
LEB7A = $EB7A
LEB7F = $EB7F
LEB84 = $EB84
LEC0D = $EC0D
LEC96 = $EC96
LECDF = $ECDF
LECE4 = $ECE4
LED3A = $ED3A
LED3F = $ED3F
LEE33 = $EE33
LEE9E = $EE9E
LEEE6 = $EEE6
LEF08 = $EF08
LEF83 = $EF83

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
        sbc     txttab
        sta     $7FA6
        sta     $58
        lda     vartab+1
        sbc     txttab+1
        sta     $59
        sta     $7FA7
        lda     txttab
        sta     $7FA8
        lda     txttab+1
        sta     $7FA9
        jsr     L7891
        lda     num_sectors     ;Number of sectors to read or write
        sta     $7FAE           ;number of sectors?
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

L786A:  lda     $7FA8           ;Load address low byte
        sta     target_ptr

        lda     $7FA9           ;Load address high byte
        sta     target_ptr+1

        lda     open_track
        sta     track           ;Track number to write to WD1793 (0-76 or $00-4c)

        lda     open_sector
        sta     sector          ;Sector number to write to WD1793 (1-26 or $01-1a)

        lda     $7FAE           ;number of sectors?
        sta     num_sectors     ;Number of sectors to read or write
        jsr     write_sectors
        bne     L7890
        lda     #$00
        sta     latch           ;Drive Select Latch
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
        sta     num_sectors     ;Number of sectors to read or write
        rts
L78A2:  lda     #$00
        sta     $7FB5

        lda     open_track
        sta     $7FAC           ;track

        lda     open_sector
        sta     $7FAD           ;sector

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
        lda     sector          ;Sector number to write to WD1793 (1-26 or $01-1a)
        cmp     #$01
        beq     L78E0
        jsr     write_a_sector
        bne     L7890
        lda     #$01
        sta     sector          ;Sector number to write to WD1793 (1-26 or $01-1a)
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
        lda     $7FAD           ;sector
        clc
        adc     $59
        cmp     #29
        bmi     L7902
        sbc     #28
        inc     $58
L7902:  sta     $59
        lda     $7FAC           ;track
        clc
        adc     $58
        sta     $58
        rts
L790D:  lda     $7FAE           ;number of sectors?
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
        lda     #$00            ;Load address low byte
        sta     target_ptr
        lda     #$7A            ;Load address high byte
        sta     target_ptr+1

        ldx     #$00            ;Set track 0 (first track)
        stx     track           ;Track number to write to WD1793 (0-76 or $00-4c)

        inx                     ;Increment to 1 (drive select pattern for drive 0)
        stx     drive_sel       ;Drive select bit pattern to write to the latch

        lda     #$16            ;Set sector 22
        sta     sector          ;Sector number to write to WD1793 (1-26 or $01-1a)

        lda     #$04
        sta     num_sectors     ;Number of sectors to read or write

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

_dos_save:  !byte   $20
L7A05:  clc
        sei
        jmp     LEB5E
L7A0A:  ldx     #$03
        lda     #$7E
        sta     $23
        lda     #$E0
L7A12:  sta     $22
        ldy     #$05
L7A16:  lda     ($22),y
        cmp     L7FA0,y
        bne     L7A2D
        dey
        bpl     L7A16
        ldy     #$11
        lda     ($22),y
        !byte   $CD
L7A25:  lda     ($7F),y
        bne     L7A2D
L7A29:  stx     L7F8F
        rts
L7A2D:  dex
        bmi     L7A29
        lda     $22
        sec
        sbc     #$20
        bne     L7A12

_dos_open:  jsr     L7A0A
        inx
        beq     L7A41
        lda     #$30
        bne     L7A73
L7A41:  ldx     #$03
        ldy     #$60
L7A45:  lda     L7E80,y
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
L7A5B:  stx     L7F8F
        jsr     LEE33
        !byte $10

L7A62:  ;Used as a string
        !byte $03
        jmp     LEB5E
        pha
        jsr     L0076

L7A6A: ;Used as a string
        cmp     #$A2
        bne     L7AD6
        pla
        bne     L7A75
        lda     #$32
L7A73:  !byte $d0

L7A74:  ;Used as a string
        !byte $66
L7A75:  lda     #$64
        sta     L7FAE
        lda     #$80
        sta     L7FA6
        sta     L7FA8
        lda     #$00
        sta     L7FA7
        !byte   $8D
        !byte   $A9
L7A89:  !byte   $7F
        sta     L7FAA
        sta     L7FAB
        sta     L7FAF
        jsr     L0070
        cmp     #$C3
        bne     L7AAC
        jsr     L0070
        bcs     L7AB3
        jsr     LB8F6
        !byte   $A5
L7AA3:  ora     ($8D),y
        ldx     $A57F
        !byte   $12
        sta     L7FAF
L7AAC:  jsr     L78A2
        bne     L7B2C
        beq     L7AE8
L7AB3:  jsr     LC12B
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
        sta     L7FAF
        iny
        lda     ($44),y
        sta     L7FAE
        jmp     L7AAC
L7AD6:  pla
        beq     L7ADE
        lda     #$32
L7ADB:  jmp     L7B3D
L7ADE:  ldy     #$0F
L7AE0:  lda     ($22),y
        sta     L7FA0,y
        dey
        bpl     L7AE0
L7AE8:  lda     #$00
L7AEA:  sta     L7FB2
        sta     L7FB3
L7AF0:  sta     L7FB5
        lda     L7FAC
        sta     L7FBA
        ldx     L7FAD
        dex
        stx     L7FBB
L7B00:  jsr     L7B55
        ldy     #$00
        lda     L7FB3
        sta     ($44),y
        iny
        lda     L7FB2
        sta     ($44),y
        !byte   $20
        !byte   $59
L7B12:  !byte   $7B
        ldy     #$00
        lda     #$00
        sta     ($44),y
        !byte   $AD
L7B1A:  lda     $7F,x
        iny
        sta     ($44),y
        jsr     L7B2F
L7B22:  lda     L7FA0,y
        sta     L7E80,x
        dex
        dey
        !byte   $10
L7B2B:  !byte   $F6
L7B2C:  jmp     LEB5E
L7B2F:  lda     L7F8F
        asl     ;a
        asl     ;a
        asl     ;a
        asl     ;a
        asl     ;a
        adc     #$1F
        tax
        ldy     #$1F
        rts
L7B3D:  sta     L7FB5
        ldy     #$00
        lda     ($77),y
L7B44:  cmp     #$00
        beq     L7B52
        cmp     #$3A
        beq     L7B52
        jsr     L0070
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
        jsr     LC12B
        pla
        sta     $78
        pla
        sta     $77
        rts

_dos_close:  jsr     L7BA6
        ldy     #$00
        lda     ($77),y
        cmp     #$80
        bne     L7B91
        jsr     L0070
        jsr     L7C22
        lda     #$FF
        sta     L7F00
        jsr     LED3A
        bne     L7BA3
L7B91:  lda     #$FF
L7B93:  sta     L7FA0
        sta     L7FB5
        lda     #$00
        sta     $E900
        lda     #$FF
        jmp     L7B00
L7BA3:  jmp     LEB5E
L7BA6:  jsr     L7A0A
        inx
        bne     L7BB1
        lda     #$07
        jmp     L7B3D
L7BB1:  jsr     L7B2F
L7BB4:  ;Used as a string
        lda     L7E80,x
        sta     L7FA0,y
        dex
        dey
        bpl     L7BB4
        lda     #$00

L7BC0: ;Used as a string
        sta     L7FB5
        rts
L7BC4:  ldy     #$00
        lda     ($77),y
        cmp     #$B9
        bne     L7C22
        jsr     L0070
        jsr     L7B55
        ldy     #$00
        lda     ($44),y
        sta     L7FB3
        iny
        lda     ($44),y
        sta     L7FB2
        ora     L7FB3
        bne     L7BE9
        lda     #$08
        jmp     L7B3D
L7BE9:  lda     L7FB2
        sec
        sbc     #$01
        sta     $5E
        lda     L7FB3
        sbc     #$00
        sta     $5F
        lda     #$1C
        sta     $60
        lda     #$00
        sta     $61
L7C00:  jsr     L797B
        lda     $5E
        clc
        adc     L7FAD
        pha
        lda     $62
        adc     L7FAC
        sta     L7FBA
        pla
        cmp     #$1D
        bcc     L7C1C
        inc     L7FBA
        sbc     #$1C
L7C1C:  sta     L7FBB
        jmp     L7C3C
L7C22:  inc     L7FB2
        bne     L7C2A
        inc     L7FB3
L7C2A:  inc     L7FBB
        lda     L7FBB
        cmp     #$1D
        bcc     L7C3C
        inc     L7FBA
        lda     #$01
        sta     L7FBB
L7C3C:  lda     L7FBA
        sta     L7F92
        cmp     L7FBC
        bcc     L7C56
        bne     L7C51
        lda     L7FBB
        cmp     L7FBD
        bcc     L7C56
L7C51:  lda     #$08
        jmp     L7B3D
L7C56:  lda     L7FBB
        sta     L7F93
        lda     #$00
        sta     $B7
        lda     #$7F
        sta     $B8
        lda     L7FB1
        sta     L7F91
        rts

_dos_input:  jsr     L7BA6
        jsr     L7BC4
        jsr     LECDF
        bne     L7CA2
        jsr     LC12B
        bit     $07
        bmi     L7C82
        lda     #$09
L7C7F:  jmp     L7B3D
L7C82:  lda     L7F00
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
L7CA2:  jmp     LEB5E

_dos_print:  jsr     L7BA6
        jsr     L7BC4
        jsr     LC12B
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
L7CC3:  sta     L7F00
        iny
        lda     ($44),y
        sta     $22
        iny
        lda     ($44),y
        sta     $23
        ldy     #$7E
L7CD2:  lda     ($22),y
        sta     L7F01,y
        dey
        bpl     L7CD2
        jsr     LED3A
        bne     L7CA2
        jmp     L7B00

_dos_run:  jsr     LEE9E
        txa
        bne     L7D10
        lda     #$0C
        sta     $77
        lda     #$7D
        sta     $78
        ldx     #$1F
        sei
L7CF3:  lda     L7FE0,x
        sta     $01E0,x
        dex
        bpl     L7CF3
        ldx     L7F8B
        txs
        cli
        ldy     L7F8A
        ldx     L7F89
        lda     #$8A
        jmp     LEA44
        txa
        brk
        brk
        brk
L7D10:  jmp     LEB5E

_dos_list:
        ;Print "DEVICE?"

        lda     #<device
        ldy     #>device
        jsr     puts

        ;Get a character until it is a valid drive number

        jsr     l_ef59          ;Get a character and test for {STOP}
        cmp     #'0'
        bmi     _dos_list
        cmp     #'4'
        bpl     _dos_list

        jmp     L7D83           ;Jump over the strings

device:
        !text $0d,$0d,"DEVICE?",0
more:
        !text $0d,"MORE..",0
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

        ;Convert char to a drive select bit pattern, store the pattern

L7D83:  and     #$03
        tax
        sec
L7D87:  rol     ;a
        dex
        bpl     L7D87
        sta     drive_sel       ;Drive select bit pattern to write to the latch

        ;Set track 0

        ldx     #$00
        stx     track           ;Track number to write to WD1793 (0-76 or $00-4c)

        ;Set sector 1

        inx
        stx     sector          ;Sector number to write to WD1793 (1-26 or $01-1a)

L7D97:  lda     #$00            ;Load address low byte
        sta     target_ptr
        sta     dir_ptr

        lda     #$7F            ;Load address high byte
        sta     target_ptr+1
        sta     dir_ptr+1

        jsr     read_a_sector
        beq     L7DAB
        jmp     restore

        ;Print "DISKNAME= "

L7DAB:  lda     #<diskname
        ldy     #>diskname
        jsr     puts

        ;Print first disk name (first 8 bytes of track 0, sector 1)

        ldy     #$00
        ldx     #$08
L7DB6:  lda     (dir_ptr),y
        jsr     chrout
        iny
        dex
        bne     L7DB6

        ;Print "NAME  TYPE TRK SCTR #SCTRS"

        lda     #<dirheader
        ldy     #>dirheader
        jsr     puts

        ;Set line number countdown until "MORE.." prompt

L7DC6:  lda     #18
        sta     edit_pos

        ;Print a newline

        lda     #$0D
        jsr     chrout

L7DCF:  lda     dir_ptr
        clc
        adc     #$10
        bpl     L7DE3
        inc     sector          ;Sector number to write to WD1793 (1-26 or $01-1a)
        jsr     read_a_sector
        beq     L7DE1
        jmp     restore
L7DE1:  lda     #$00
L7DE3:  sta     dir_ptr

        ;Check for end of directory

        ldy     #$00
        lda     (dir_ptr),y     ;Get first byte of filename
        cmp     #$FF            ;Equal to $FF?
        bne     L7DF0           ;  No: continue
        jmp     L7E56           ;  Yes: jump, end of directory

        ;Check if file has been deleted

L7DF0:  ldy     #$05
        lda     (dir_ptr),y     ;Get last byte of filename
        cmp     #$FF            ;Equal to $FF?
        beq     L7DCF           ;  Yes: file is deleted, skip it
                                ;  No: continue

        ;Print a newline

        lda     #$0D
        jsr     chrout

        ;Print filename followed by a space

        ldy     #$00
L7DFF:  lda     (dir_ptr),y
        jsr     chrout
        iny
        cpy     #$06
        bmi     L7DFF
        jsr     put_spc

        ;Set pointer to file type

        ldy     #$0A
        lda     (dir_ptr),y

        ;Print file type followed by a space

        asl     ;a
        asl     ;a
        clc
        adc     #<filetypes
        ldy     #>filetypes
        jsr     puts
        jsr     put_spc

        ;Set pointer to file track number

        ldy     #$0C
        lda     (dir_ptr),y

        ;Print track number in hex followed by a space

        jsr     put_hex_byte
        jsr     put_spc

        ;Set pointer to file sector number

        ldy     #$0D
        lda     (dir_ptr),y

        ;Print sector number in hex followed by two spaces

        jsr     put_spc_hex
        jsr     put_spc
        jsr     put_spc

        ;Print high byte of sector count in hex

        ldy     #$0F
        lda     (dir_ptr),y
        jsr     put_spc_hex

        ;Print low byte of sector count in hex

        ldy     #$0E
        lda     (dir_ptr),y
        jsr     put_hex_byte

        dec     edit_pos
        bmi     L7E49
        jmp     L7DCF

        ;Print "MORE.."

L7E49:  lda     #<more
        ldy     #>more
        jsr     puts

        jsr     l_ef59          ;Get a character and test for {STOP}
        jmp     L7DC6

        ;Print a newline

L7E56:  lda     #$0D
        jsr     chrout

        jsr     deselect
        jsr     chrget
        jmp     restore

        !byte   $8F
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
        !byte   $B2
        and     $B506,y
L7E80:  lda     #$93
        jsr     chrout
L7E85:  ldx     #$FF
        txs
        lda     #$00
        sta     $E900
        lda     #$0D
        jsr     chrout
        jsr     chrout
        lda     #$3E
        jsr     chrout

        jsr     l_ef59  ;Get a character and test for {STOP}
        cmp     #'A'
        bcc     L7EA5
        cmp     #'Z'+1
        bcc     L7EAB

L7EA5:  jsr     LEEE6
        jmp     L7A05

L7EAB:  cmp     #'L'    ;L-LOAD DISK PROGRAM
        beq     L7ED3
        cmp     #'S'    ;S-SAVE A PROGRAM
        beq     L7ED6
        cmp     #'M'    ;M-MEMORY ALTER
        beq     L7ED9
        cmp     #'R'    ;R-RE-ENTER BASIC
        beq     L7EFD
        cmp     #'G'    ;G-GO TO MEMORY
        beq     L7EDC
        cmp     #'X'    ;X-EXECUTE DISK FILE
        beq     L7EDF
        cmp     #'K'    ;K-KILL A FILE
        beq     L7ED0
        jsr     L7A89
        txa
        bne     L7E85
        jmp     L7C00

L7ED0:  jmp     L7B93
L7ED3:  jmp     L7AEA
L7ED6:  jmp     L7B2B
L7ED9:  jmp     LEF83
L7EDC:  jmp     L7B1A
L7EDF:  jmp     L7B12

        !text $0d,"FILE? ",0

        !text $0d,"DEVICE? ",0

        !text $0d,"ENTRY? ",0

L7EFD:  jsr     L0070
L7F00:  !byte   $A9
L7F01:  !byte   $EB
        pha
        lda     #$5D
        pha
        !byte   $4C
        !byte   $D1
L7F08:  nop
L7F09:  pha
L7F0A:  lda     #$2A
        ldy     #$00
L7F0E:  sta     L7FA0,y
        iny
        cpy     #$05
        bmi     L7F0E
        pla
        sta     L7FA5
        ldy     #$01
        sty     L7FB1
        jsr     LEE9E
        rts

        lda     #<L7A62
        ldy     #>L7A62
        jsr     puts

        ldy     #$00
L7F2C:  jsr     chrin
        cmp     #$3A
        beq     L7F3B
        sta     L7FA0,y
        iny
        cpy     #$07
        bmi     L7F2C
L7F3B:  lda     #$20
L7F3D:  cpy     #$06
        bpl     L7F47
        sta     L7FA0,y
        iny
        bne     L7F3D
L7F47:  jsr     chrin
        jsr     L7ADB
        sta     L7FB1
        rts

L7F51:  lda     #<L7A6A
        ldy     #>L7A6A
        jsr     puts

        jsr     l_ef59  ;Get a character and test for {STOP}
        cmp     #'0'
        bmi     L7F51
        cmp     #'3'
        bpl     L7F51
        and     #$03
        tax
        lda     $EA2F,x
        rts
        jsr     L7AF0
        jmp     L7A05
        jsr     L7AA3
        jsr     LEE9E
        txa
        bne     L7F91
        ldy     #$0A
        lda     ($22),y
        cmp     #$05
        beq     L7F84
        jmp     L7A25
L7F84:  ldy     #$06
        lda     ($22),y
        !byte   $85
L7F89:  !byte   $66
L7F8A:  iny
L7F8B:  !byte   $B1
L7F8C:  !byte   $22
        sta     $67
L7F8F:  lda     #$00
L7F91:  rts
L7F92:  !byte   $20
L7F93:  beq     L800F
        !byte   $D0
L7F96:  asl     $224C
        !byte   $7B
        lda     #$0D
        jsr     chrout
        !byte   $20
L7FA0:  !byte   $FB
        inc     $2820
        !byte   $7B
L7FA5:  !byte   $4C
L7FA6:  !byte   $05
L7FA7:  !byte   $7A
L7FA8:  !byte   $6C
L7FA9:  !byte   $66
L7FAA:  brk
L7FAB:  !byte   $20
L7FAC:  !byte   $A3
L7FAD:  !byte   $7A
L7FAE:  !byte   $A9
L7FAF:  !byte   $0D
        !byte   $20
L7FB1:  !byte   $D2
L7FB2:  !byte   $FF
L7FB3:  !byte   $20
        !byte   $FB
L7FB5:  inc     $66A5
        !byte   $8D
        tay
L7FBA:  !byte   $7F
L7FBB:  !byte   $A5
L7FBC:  !byte   $67
L7FBD:  sta     L7FA9
        lda     #$2D
        jsr     chrout
        jsr     LEF08
        lda     $66
        clc
        adc     #$7F
        php
        sec
        sbc     L7FA8
        sta     $26
        lda     $67
        sbc     L7FA9
        plp
        adc     #$00
        asl     $26
        rol     ;a
        !byte   $8D
L7FE0:  ldx     $A97F
        brk
        sta     L7FAF

        lda     #<L7A74
        ldy     #>L7A74
        jsr     puts

        jsr     LEF08
        lda     #$0D
        jsr     chrout
        lda     $66
        sta     L7FA6
        lda     $67
        sta     L7FA7
        lda     #$05
        sta     L7FAA
        jsr     LEE33

        bmi     L8010
        tax
        beq     L8062
        !byte   $20
        !byte   $57

L800F:  sei
L8010:  jmp     L7A05

        lda     #<L7BB4
        ldy     #>L7BB4
        jsr     puts

        jsr     L7AA3
        jsr     LEE33
        tax
        bmi     L802E
        bne     L8031
        lda     #$FF
        ldy     #$05
        sta     ($22),y
        jsr     LED3A
L802E:  jmp     L7A05
L8031:  jmp     L7A25

        !text $0d,"** DELETE-",0

        !text $0d,"DUPLICATE FILE NAME-CANNOT SAVE",$0d,0

L8062:  lda     #<L7BC0
        ldy     #>L7BC0
        jsr     puts

        jmp     L7A05
        cmp     $E981
        bne     L8072
        rts
L8072:  lda     #$03
        jsr     LEC0D
        dec     L7F8C
        bne     $8053
        lda     #$10
        !byte   $2C
        !byte   $A9
