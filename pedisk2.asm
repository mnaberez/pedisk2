;This is a bit correct disassembly of the PEDISK II ROM
;Based on work by Lee Davison 2013-07-04

latch        = $e900    ;Drive Select Latch
                        ;  bit function
                        ;  === ======
                        ;  7-4 not used
                        ;  3   motor ??
                        ;  2   drive 3 select
                        ;  1   drive 2 select
                        ;  0   drive 1 select

fdc          = $e980    ;WD1793 Floppy Disk Controller
fdc_cmdst    = fdc+0    ;  Command/status register
fdc_track    = fdc+1    ;  Track register
fdc_sector   = fdc+2    ;  Sector register
fdc_data     = fdc+3    ;  Data register

;WD1793 Floppy Disk Controller
;
;    Command           b7 b6 b5 b4 b3 b2 b1 b0
;I   Restore           0  0  0  0  h  V  r1 r0
;I   Seek              0  0  0  1  h  V  r1 r0
;I   Step              0  0  1  T  h  V  r1 r0
;I   Step-In           0  1  0  T  h  V  r1 r0
;I   Step-Out          0  1  1  T  h  V  r1 r0
;II  Read Sector       1  0  0  m  S  E  C  0
;II  Write Sector      1  0  1  m  S  E  C  a0
;III Read Address      1  1  0  0  0  E  0  0
;III Read Track        1  1  1  0  0  E  0  0
;III Write Track       1  1  1  1  0  E  0  0
;IV  Force Interrupt   1  1  0  1  i3 i2 i1 i0
;
;   r1 r0  Stepping Motor Rate
;    1  1   30 ms
;    1  0   20 ms
;    0  1   12 ms
;    0  0   6 ms
;     V      Track Number Verify Flag (0: no verify, 1: verify on dest track)
;     h      Head Load Flag (1: load head at beginning, 0: unload head)
;       T      Track Update Flag (0: no update, 1: update Track Register)
;       a0     Data Address Mark (0: FB, 1: F8 (deleted DAM))
;       C      Side Compare Flag (0: disable side compare, 1: enable side comp)
;       E      15 ms delay (0: no 15ms delay, 1: 15 ms delay)
;       S      Side Compare Flag (0: compare for side 0, 1: compare for side 1)
;       m      Multiple Record Flag (0: single record, 1: multiple records)
;           i3 i2 i1 i0    Interrupt Condition Flags
;              i3-i0 = 0 Terminate with no interrupt (INTRQ)
;                    i3 = 1 Immediate interrupt, requires a reset
;                    i2 = 1 Index pulse
;                    i1 = 1 Ready to not ready transition
;                    i0 = 1 Not ready to ready transition
;
;status bits         bit when 1
;                    === ======
;                     7  drive not ready
;                     6  write protect
;                     5  write error
;                     4  seek error
;                     3  crc error
;                     2  track zero/lost data
;                     1  data request
;                     0  busy

;In the zero page locations below, ** indicates the PEDISK destroys
;a location that is used for some other purpose by CBM BASIC 4.

valtyp      = $07       ;Data type of value: 0=numeric, $ff=string
dir_ptr     = $22       ;Pointer: PEDISK directory **
fname_ptr   = $24       ;Pointer: PEDISK filename **
hex_save_a  = $26       ;PEDISK temporarily saves A during hex conversion **
edit_pos    = $27       ;PEDISK memory editor position on current line **
txttab      = $28       ;Pointer: Start of BASIC text
vartab      = $2a       ;Pointer: Start of BASIC variables
fretop      = $30       ;Pointer: Bottom of string storage
frespc      = $32       ;Pointer: Utility string
memsiz      = $34       ;Pointer: Highest address used by BASIC
curlin      = $36       ;Current BASIC line number (2 bytes)
varpnt      = $44       ;Pointer: Current BASIC variable
oldlin      = $56       ;Previous BASIC line number (2 bytes)
edit_ptr    = $66       ;Pointer: PEDISK current address of memory editor **
puts_ptr    = $6c       ;Pointer: PEDISK string to print for puts **
chrget      = $70       ;Subroutine: Get Next Byte of BASIC Text
txtptr      = $77       ;Pointer: Current Byte of BASIC Text
target_ptr  = $b7       ;Pointer: PEDISK target address for memory ops **
dos         = $7800     ;Base address for the RAM-resident portion
dos_save    = dos+$0000 ;Entry point for !SAVE
dos_open    = dos+$0003 ;Entry point for !OPEN
dos_close   = dos+$0006 ;Entry point for !CLOSE
dos_input   = dos+$0009 ;Entry point for !INPUT
dos_print   = dos+$000c ;Entry point for !PRINT
dos_run     = dos+$000f ;Entry point for !RUN (load and run)
dos_sys     = dos+$0012 ;Entry point for !SYS (disk monitor)
dos_list    = dos+$0015 ;Entry point for !LIST (directory)
dos_stop    = dos+$0200 ;Unknown, PEDISK monitor jumps here if STOP pressed
buf_1       = dos+$0680 ;Unknown, possible buffer area #1
buf_2       = dos+$06a0 ;Unknown, possible buffer area #2
buf_3       = dos+$06c0 ;Unknown, possible buffer area #3
buf_4       = dos+$06e0 ;Unknown, possible buffer area #4
dir_sector  = dos+$0700 ;128 bytes for directory sector used by find_file
save_char   = dos+$0788 ;Temp storage for char read at PEDISK monitor prompt
wedge_x     = dos+$0789 ;Temp storage for X register used by the wedge
wedge_y     = dos+$078a ;Temp storage for Y register used by the wedge
wedge_sp    = dos+$078b ;Temp storage for stack pointer used by the wedge
retries     = dos+$078c ;Counts down retries remaining for disk operations
save_a      = dos+$078d ;Temp storage for A reg used by several routines
save_x      = dos+$078e ;Temp storage for X reg used by several routines
status_mask = dos+$0790 ;Mask to apply when checking WD1793 status register
drive_sel   = dos+$0791 ;Drive select bit pattern to write to the latch
track       = dos+$0792 ;Track number to write to WD1793 (0-76 or $00-4c)
sector      = dos+$0793 ;Sector number to write to WD1793 (1-26 or $01-1a)
status      = dos+$0794 ;Last status byte read from WD1793 (no masking)
command     = dos+$0795 ;Last command byte written to WD1793
num_sectors = dos+$0796 ;Number of sectors to read or write
filename    = dos+$07a0 ;Buffer used to store filename (6 bytes)
drive_sel_f = dos+$07b1 ;Drive select bit pattern parsed from a filename
wedge_stack = dos+$07e0 ;32 bytes for preserving the stack used by the wedge
ptrget      = $c12b     ;BASIC Find a variable
wrob        = $d722     ;Monitor Write byte in A out as a two digit hex
hexit       = $d78d     ;Monitor Evaluate char in A to a hex nibble
chrout      = $ffd2     ;KERNAL Send a char to the current output device
getin       = $ffe4     ;KERNAL Read a char from the current input device

stop        = $03       ;PETSCII STOP
cr          = $0d       ;PETSCII Carriage return
space       = $20       ;PETSCII Space
quote       = $22       ;PETSCII Quotation mark
clear       = $93       ;PETSCII Clear screen
crsr_left   = $9d       ;PETSCII Cursor left
checker     = $e6       ;PETSCII Checkerboard

tracks      = 77        ;8" disk has 77 tracks numbered 0-76
sectors     = 26        ;8" disk has 26 sectors per track numbered 1-26
sector_size = 128       ;Always 128 bytes per sector for all disk types

dos_num_sec = 13        ;Number of DOS sectors
dos_track   = 0         ;Track where DOS is stored (always one track)
dos_sector  = 9         ;First sector of the DOS

dir_num_sec = 8         ;Number of directory sectors
dir_track   = 0         ;Track where directory is stored (always one track)
                        ;First sector of dir is hardcoded (see find_file)

e_illegal   = $01       ;Illegal Command or Mode
e_no_fname  = $03       ;No Filename
e_bad_fname = $04       ;Bad Filename
e_seek_err  = $10       ;Seek Error
e_end_disk  = $11       ;End of Disk
e_not_ready = $13       ;Drive Not Ready
e_no_drive  = $14       ;No Drive Selected
e_bad_track = $15       ;Bad Track Number
e_not_resp  = $17       ;Drive Not Responding
e_read_err  = $40       ;Read Error
e_writ_err  = $50       ;Write Error

    *=$e800

under_io:
;these two pages are under the I/O area ($e800-e9ff) area and can't be
;read.  the contents should not matter.
    !byte $04,$45,$45,$05,$07,$80,$c5,$44,$7f,$ff,$df,$ff,$f7,$df,$fb,$ff
    !byte $00,$04,$01,$04,$41,$05,$80,$05,$fe,$ff,$ff,$fb,$ff,$fb,$fb,$bf
    !byte $44,$41,$45,$45,$05,$24,$24,$25,$ff,$ff,$d7,$ff,$ff,$ff,$ff,$ff
    !byte $04,$04,$01,$45,$05,$04,$80,$04,$ff,$ff,$fd,$ff,$ff,$ff,$fe,$fb
    !byte $7b,$fa,$7a,$fe,$ba,$ff,$fb,$3a,$00,$00,$04,$00,$00,$05,$45,$40
    !byte $fa,$7a,$be,$de,$fb,$bb,$be,$bb,$04,$20,$00,$40,$01,$01,$04,$00
    !byte $3e,$16,$bf,$fa,$fe,$bf,$fa,$fe,$00,$00,$00,$01,$00,$00,$00,$04
    !byte $d2,$ba,$7a,$ff,$fa,$da,$7a,$fa,$01,$01,$00,$04,$40,$00,$40,$05
    !byte $46,$c4,$95,$05,$c4,$02,$43,$44,$ff,$ff,$ff,$fb,$ff,$ff,$ff,$ff
    !byte $21,$23,$81,$41,$45,$05,$45,$c0,$bf,$bf,$ff,$bf,$ff,$ff,$ff,$ff
    !byte $a7,$65,$0c,$24,$10,$01,$04,$01,$ff,$ff,$eb,$ff,$ff,$fb,$9f,$bb
    !byte $05,$c5,$42,$04,$95,$84,$14,$00,$ff,$fb,$fe,$fb,$bb,$ff,$ff,$fb
    !byte $fe,$dc,$fa,$bc,$9a,$4b,$fa,$7b,$00,$00,$00,$00,$00,$40,$00,$04
    !byte $b3,$fa,$7a,$fe,$ff,$1a,$fa,$ba,$00,$04,$2c,$04,$80,$00,$44,$04
    !byte $7a,$1a,$f2,$78,$ff,$3e,$3a,$5a,$00,$00,$20,$00,$00,$00,$00,$01
    !byte $fa,$fe,$3e,$fa,$fb,$ff,$be,$ba,$00,$20,$48,$0c,$00,$20,$00,$05
    !byte $c5,$25,$c5,$c5,$c1,$25,$64,$21,$df,$ff,$ff,$fb,$fe,$ff,$df,$ff
    !byte $01,$65,$04,$05,$91,$14,$04,$01,$fa,$fe,$ff,$ff,$ff,$ff,$f7,$fb
    !byte $85,$02,$07,$40,$46,$20,$04,$01,$ff,$ff,$fb,$bf,$ff,$fb,$df,$ff
    !byte $80,$01,$44,$40,$05,$40,$04,$04,$ff,$bf,$ff,$ff,$df,$bf,$ff,$fb
    !byte $ff,$7a,$9a,$79,$ca,$ba,$bb,$ab,$00,$41,$00,$00,$00,$00,$44,$00
    !byte $fb,$f3,$fb,$ab,$3e,$fa,$b8,$bb,$00,$40,$04,$04,$00,$00,$40,$84
    !byte $8a,$fa,$3f,$fb,$3b,$7a,$7f,$5b,$44,$20,$00,$04,$00,$00,$00,$c0
    !byte $ff,$ba,$ff,$fb,$7e,$fa,$fe,$fe,$44,$00,$04,$41,$04,$44,$08,$00
    !byte $05,$40,$45,$8d,$04,$d5,$67,$44,$ff,$ff,$ff,$bf,$fb,$bf,$fa,$ff
    !byte $20,$05,$05,$04,$55,$e6,$85,$44,$bb,$ff,$bf,$ff,$ff,$ff,$ff,$ff
    !byte $24,$45,$84,$45,$05,$45,$41,$04,$ff,$fb,$ff,$ff,$ff,$ff,$bb,$ff
    !byte $00,$af,$c5,$05,$81,$85,$21,$05,$df,$ff,$ff,$ef,$fb,$fb,$ef,$ff
    !byte $ff,$7a,$fa,$fe,$ff,$fe,$fa,$da,$00,$44,$00,$04,$00,$00,$40,$05
    !byte $fa,$ba,$6a,$ba,$db,$bb,$bf,$fe,$04,$40,$00,$04,$00,$00,$04,$20
    !byte $bb,$9a,$bf,$fa,$5b,$fb,$7a,$7b,$00,$00,$00,$02,$40,$00,$00,$00
    !byte $da,$aa,$fb,$bf,$fe,$fe,$7e,$3e,$04,$04,$00,$44,$00,$00,$04,$20

entry_points:
    jmp init            ;Initialize the system (SYS 55904)
    jmp edit_memory     ;Display/edit memory ("ADDR?")
    jmp read_sectors    ;Read sectors into memory
    jmp write_sectors   ;Write sectors to disk
    jmp find_file       ;Search for filename in the directory
    jmp load_file       ;Perform !LOAD

cmd_vectors:
;These vectors are in the same order as the cmd_tokens table below.  Each
;vector points to the RAM-resident portion, with the sole exception of
;the one for !LOAD which is in this ROM.  The vectors are all -1 because
;RTS is used to jump to them (push vector onto stack, then RTS).
;
    !word dos_sys-1     ;vector for !SYS
    !word romdos_load-1 ;vector for !LOAD (in this ROM)
    !word dos_save-1    ;vector for !SAVE
    !word dos_open-1    ;vector for !OPEN
    !word dos_close-1   ;vector for !CLOSE
    !word dos_input-1   ;vector for !INPUT
    !word dos_print-1   ;vector for !PRINT
    !word dos_run-1     ;vector for !RUN
    !word dos_list-1    ;vector for !LIST

cmd_tokens:
;PEDISK II commands share the same names as existing Commodore BASIC
;commands but are prefixed with an exclamation point for the wedge.
;
    !byte $9e           ;CBM BASIC token for SYS
    !byte $93           ;CBM BASIC token for LOAD
    !byte $94           ;CBM BASIC token for SAVE
    !byte $9f           ;CBM BASIC token for OPEN
    !byte $a0           ;CBM BASIC token for CLOSE
    !byte $85           ;CBM BASIC token for INPUT
    !byte $99           ;CBM BASIC token for PRINT
    !byte $8a           ;CBM BASIC token for RUN
    !byte $9b           ;CBM BASIC token for LIST

    !byte $ff,$00       ;Unused bytes -- this is not an end marker.  The
                        ;  number of tokens is hardcoded in the wedge.

drive_selects:
;drive select byte
    !byte %00000001     ;drive 0 select bit pattern
    !byte %00000010     ;drive 1 select bit pattern
    !byte %00000100     ;drive 2 select bit pattern

wedge:
;A patch is installed in CHRGET to jump to this wedge.  The next byte in
;the current BASIC line will be in A when the patch jumps here.
;
    cmp #'!'            ;Is it the lead-in char for PEDISK commands?
    bne check_colon     ;  No: skip over the token check

    sty wedge_y         ;Save original Y
    ldy #$01            ;Set Y to look ahead at the next byte
    lda (txtptr),y      ;Get the next byte after the "!"
    bmi handle_token    ;Branch if it has bit 7 set (indicates BASIC token)

    ldy wedge_y         ;Restore original Y
    lda #'!'            ;Restore A to its original value ("!")

check_colon:
    cmp #':'            ;Compare the character with ":"
    bcs bypass_chrget   ;If >= ":" then bail out
    jmp chrget+$0d      ;  else jump back into CHRGET

bypass_chrget:
    rts                 ;Return to the caller directly instead of
                        ;  jumping back to CHRGET

handle_token:
;CHRGET has been called with the PEDISK command lead-in "!" and the
;next byte after the "!" is a BASIC token.  Check if the TOKEN is
;a valid PEDISK command, and either dispatch it or show an error.
;
    cld                 ;Clear decimal mode
    stx wedge_x         ;Save X
    tsx
    stx wedge_sp        ;Save the stack pointer

                        ;Save the top of the stack, must have no IRQs:
    ldx #$1f            ;  Set the byte count/index
    sei                 ;  Disable interrupts
save_stack_loop:        ;
    lda $01e0,x         ;  Get the byte from the stack
    sta wedge_stack,x   ;  Save it off to temporary storage
    dex                 ;  Decrement bytes remaining
    bpl save_stack_loop ;  Loop until 32 bytes are saved
                        ;  X has been decremented past 0 and is now $ff

                        ;Set stack pointer to top of stack, re-enable IRQs:
    txs                 ;  Set the stack pointer to $ff
    cli                 ;  Enable interrupts again

    jsr chrget          ;Get the next byte from the BASIC line
                        ;  (this will be the byte after the "!", which
                        ;     we already know is a valid BASIC token)

                        ;Find the token in the PEDISK tokens table:
    ldx #$08            ;  Index of the last token
find_token_loop:
    cmp cmd_tokens,x    ;Is the token in A the same as this token?
    beq dispatch_token  ;  Yes: dispatch it
    dex                 ;   No: decrement X
    bpl find_token_loop ;         and loop until all have been checked

                        ;Not a PEDISK token:
    bmi illegal_cmd     ;  Branch always to disk error for illegal cmd/mode

dispatch_token:
;A valid PEDISK command token has been found.  Its index to the cmd_tokens
;and cmd_vectors tables is in A.  Dispatch it to perform the command.
;
                        ;Dispatch !LIST:
    cpx #$08            ;  Is it the token index for !LIST?
    beq l_ea84          ;    Yes: dispatch it

                        ;Dispatch !SAVE:
    cpx #$02            ;  Is it the token index for !SAVE?
    bcs l_ea8c          ;    Yes: dispatch it

;!SYS and !LOAD get some special treatment
;
;check we're in immediate mode or go do an error

    ldy curlin+1        ;get the current BASIC line number high byte
    iny                 ;increment it
    bne illegal_cmd     ;if executing a program go do disk error $01, illegal
                        ;  command/mode

;else we're in immediate mode

    txa                 ;copy the index
    bne l_ea8c          ;if it's !LOAD go handle it like any other command

    jmp dos_sys         ;else go do !SYS


l_ea84:
;go do !LIST
    jmp dos_list        ;do !LIST


illegal_cmd:
;do disk error $01, illegal command/mode
    lda #e_illegal
    jmp dsk_err_restore


l_ea8c:
;found a match and the execution mode is ok
    txa                 ;copy the index
    asl                 ;* 2 bytes per vector
    tax                 ;back to the index
    lda cmd_vectors+1,x ;get the vector high byte
    pha                 ;push it on the stack
    lda cmd_vectors,x   ;get the vector low byte
    pha                 ;push it on the stack
    jmp l_edbd          ;get a filename from a string or variable then do RTS
                        ;to call the vector

init:
;Initialize the system
;
    cld                 ;clear decimal mode
    lda #<dos
    sta memsiz          ;BASIC top of memory low byte
    sta fretop          ;BASIC end of strings low byte
    lda #>dos
    sta memsiz+1        ;BASIC top of memory high byte
    sta fretop+1        ;BASIC end of strings high byte

    lda #<dos-1
    sta frespc          ;utility string pointer low byte
    lda #>dos-1
    sta frespc+1        ;utility string pointer high byte

;display the startup message

    lda #<banner        ;set the message pointer low byte
    ldy #>banner        ;set the message pointer high byte
    jsr puts            ;message out

;test the RAM, well one byte of it at dos+$00f2 anyway

    ldx #$f2            ;set the index/test byte
l_eab8:
    txa                 ;copy X
    eor #$ff            ;invert it
    sta dos,x           ;save it to RAM
    dex                 ;decrement the index
    bpl l_eab8          ;loop if more to do, branch never

    ldx #$f2            ;set the index/test byte
l_eac3:
    txa                 ;copy X
    eor #$ff            ;invert it
    cmp dos,x           ;compare it with the previously saved version
    beq l_eace          ;if they're the same just continue

    jmp puts_mem_err    ;else do "MEM ERROR" message and return

l_eace:
    dex                 ;loop if more to do, branch never
    bpl l_eac3

    lda #$ff
    sta buf_1
    sta buf_2
    sta buf_3
    sta buf_4

load_dos:
;Load the RAM-resident portion from disk into memory
;
;The DOS is stored in 13 sectors on track 0: sectors 9 through 21.  Each
;sector is 128 bytes, so the DOS code is 1664 bytes.  It is loaded into
;RAM from dos+$0000 to dos+$067f.  The first 24 bytes are a jump table
;(see cmd_vectors).  See find_file for more on the DOS code.
;
;The DOS sectors can contain anything.  There's no check on the contents,
;and no jump to any sort of init routine in the DOS.  If the sectors read
;without error from the WD1793, the DOS is considered loaded.  The first
;jump into the DOS will be when the user enters a wedge command (e.g. !LIST).
;
    lda #<dos           ;set the memory pointer low byte
    sta target_ptr      ;save the memory pointer low byte
    lda #>dos           ;set the memory pointer high byte
    sta target_ptr+1    ;save the memory pointer high byte

    ldx #dos_track      ;set track zero
    stx track           ;save the requested track number

    inx                 ;set x=1, which is the pattern for selecting drive 0
    stx drive_sel       ;save pattern to write to drive select latch

    ldx #dos_num_sec    ;set the sector count
    stx num_sectors     ;save the requested sector count

    ldx #dos_sector     ;set the sector number
    stx sector          ;save the requested sector number

    jsr read_sectors    ;read <n> sector(s) to memory ??
    bne deselect        ;if any error go deselect the drives,
                        ;  stop the motors and exit to BASIC

install_wedge:
;After the DOS sectors have been loaded into RAM, the CHRGET routine in
;zero page is patched to jump to the wedge.
;
;Before:                            After:
;
;chrget $0070 e6 77    inc $77      chrget $0070 e6 77    inc $77
;       $0072 d0 02    bne $76             $0072 d0 02    bne $76
;       $0074 e6 78    inc $78             $0074 e6 78    inc $78
;       $0076 ad xx xx lda $xxxx           $0076 ad xx xx lda $xxxx
;       $0079 c9 ea    cmp #$ea            $0079 4c 32 ea jmp $ea32  <--
;       $007b b0 0a    bcs $0087
;       $007d c9 20    cmp #$20            $007d c9 20    cmp #$20
;       $007f f0 ef    beq $0070           $007f f0 ef    beq $0070
;
;When the wedge is done, it will either return to the caller directly with
;RTS, or it will JMP $007D to continue CHRGET processing.
;
    lda #$4c
    sta chrget+$09      ;Patch opcode for JMP
    lda #<wedge
    sta chrget+$0a      ;Patch low byte of wedge address
    lda #>wedge
    sta chrget+$0b      ;Patch high byte of wedge address

                        ;Fall through into deselect

deselect:
;deselect the drives and stop the motors ??
;
    lda #%00001000
    sta latch           ;save the drive select latch
    rts


banner:
    !text clear,"PEDISK II SYSTEM",cr
    !text "CGRS MICROTECH",cr
    !text "LANGHORNE,PA.19047 C1981",cr,0


mem_error:
    !text cr,"MEM ERROR",0


puts_mem_err:
    lda #<mem_error     ;set the message pointer low byte
    ldy #>mem_error     ;set the message pointer high byte
    jmp puts            ;message out and return


restore:
;restore the top 32 bytes of the stack page and return EOT
;
    ldx #$1f            ;set the byte count/index
    sei                 ;disable interrupts
l_eb61:
    lda wedge_stack,x   ;get a saved stack page byte
    sta $01e0,x         ;restore it
    dex                 ;decrement the byte count/index
    bpl l_eb61          ;loop if more to do

    ldx wedge_sp        ;get the saved stack pointer
    txs                 ;restore it
    cli                 ;enable interrupts
    ldy wedge_y         ;restore Y
    ldx wedge_x         ;restore X
    lda #0              ;return an End Of Text byte
    jmp check_colon     ;Jump out to the wedge


put_spc:
;Output a space character
;
    lda #space          ;set [SPACE]
    jmp chrout          ;do character out and return


put_spc_hex:
;Output a space char followed by the byte in A as a two digit hex number
;
    pha                 ;save A
    jsr put_spc         ;output a [SPACE] character
    pla                 ;restore A
                        ;Fall through into put_hex_byte

put_hex_byte:
;Output the byte in A as a two digit hex number
;
    sta save_a          ;save A
    stx save_x          ;save X
    jsr wrob            ;Print A as a two digit hex number
    ldx save_x          ;restore X
    lda save_a          ;restore A
    rts


disk_err_msg:
    !text cr,"DISK ERROR",0


select_drive:
;Select a drive
;
;Sets the Z flag on success, clears Z on failure.
;
    lda #0              ;clear A
    sta status          ;clear the WD1793 status register copy
    sei                 ;disable interrupts

    lda drive_sel       ;get pattern to write to drive select latch
    beq no_drive_sel    ;if zero go do disk error $14, no drive selected

    lda latch           ;read the drive select latch
    and #%00000111      ;mask the drive select bits
    cmp drive_sel       ;compare it with select pattern we want to write
    beq select_done     ;if the same just exit

    lda drive_sel       ;get pattern to write to drive select latch
    cmp #%00000111      ;compare it with all drives selected
    bcs no_drive_sel    ;if >= $07 go do disk error $14, no drive selected

    ora #%00001000      ;mask xxxx 1xxx, set ?? bit
    sta latch           ;save the drive select latch

    lda #35             ;set the delay count, 35ms
    jsr delay           ;delay for A * 1000 cycles

    lda fdc_cmdst       ;Read the WD1793 status register
    and #%10000000      ;mask x000 0000, drive not ready
    bne drv_not_rdy     ;if the drive is not ready go do disk error $13,
select_done:
    rts


seek_track:
;Seek to track with retries
;
;Sets the Z flag on success, clears Z on failure.
;
    lda #$03            ;set the retry count
    sta retries         ;save the retry count
l_ebd3:
    lda track           ;get the requested track number
    cmp #tracks         ;compare it with max + 1
    bpl bad_track       ;if > max go do disk error $15

    sta fdc_data        ;Write target track to the WD1793 data register
    lda #%10011000      ;mask x00x x000,
                        ;     x--- ----  drive not ready
                        ;     ---x ----  record not found
                        ;     ---- x---  CRC error
    sta status_mask     ;save the WD1793 status byte mask

    lda #$16            ;set seek command, verify track, 20ms step rate
    jsr l_ec0d          ;wait for WD1793 not busy and do command A
    bne l_ebf2          ;go handle any returned error

    lda track           ;get the requested track number
    cmp fdc_track       ;compare it with the requested track register
    bne l_ebf2          ;go handle any difference
    rts

    ;there was an error or the track numbers differ

l_ebf2:
    lda #$02            ;set restore command, 20ms step rate
    jsr l_ec0d          ;wait for WD1793 not busy and do command A

    dec retries         ;decrement the retry count
    bne l_ebd3          ;if not all done go try again

;else do disk error $10, seek error
;
    lda #e_seek_err     ;set error $10
    !byte $2c           ;makes next line BIT $xxxx

bad_track:
;do disk error $15, track error during seek
;
    lda #e_bad_track    ;set error $15
    !byte $2c           ;makes next line BIT $xxxx

drv_not_resp:
;do disk error $17, drive not responding
;
    lda #e_not_resp     ;set error $17
    !byte $2c           ;makes next line BIT $xxxx

drv_not_rdy:
;do disk error $13, drive not ready
;
    lda #e_not_ready    ;set error $13
    !byte $2c           ;makes next line BIT $xxxx

no_drive_sel:
;do disk error $14, no drive selected
;
    lda #e_no_drive     ;set error $14
    jmp disk_error      ;do "DISK ERROR" message and ??


l_ec0d:
;wait for WD1793 not busy and do command A
;
    jsr l_ec1e          ;wait for WD1793 not busy
    bcs drv_not_resp    ;if counted out go do disk error $17

    sta command         ;Remember this command as the last one written
    sta fdc_cmdst       ;Write to the WD1793 command register

    jsr delay_1ms       ;Delay 1ms
    jmp l_ecd0          ;wait for WD1793 not busy mask the status and return


l_ec1e:
;wait for WD1793 not busy
;
    pha                 ;save A
    txa                 ;copy X
    pha                 ;save X
    tya                 ;copy Y
    pha                 ;save Y

    ldy #$20            ;set the outer loop count
l_ec25:
    ldx #$ff            ;set the inner loop count
l_ec27:
    lda fdc_cmdst       ;Read the WD1793 status register
    and #%00000001      ;mask 0000 000x, busy
    beq l_ec4c          ;if not busy go return not counted out

    lda #$23            ;set the wait count
    sta save_a          ;save the wait count
l_ec33:
    dec save_a          ;decrement the wait count
    bne l_ec33          ;loop if more to do

    dex                 ;decrement the inner loop count
    bne l_ec27          ;loop if more to do

    dey                 ;decrement the outer loop count
    bne l_ec25          ;loop if more to do

    lda #$d8            ;set force interrupt command, immediate interrupt
    sta command         ;Remember this command as the last one written
    sta fdc_cmdst       ;Write to the WD1793 command register

    jsr delay_1ms       ;Delay 1ms
    sec                 ;flag counted out
    bcs l_ec4d          ;return the flag, branch always

l_ec4c:
    clc                 ;flag not counted out
l_ec4d:
    pla                 ;pull Y
    tay                 ;restore Y
    pla                 ;pull X
    tax                 ;restore X
    pla                 ;restore A
    rts


delay_1ms:
;Delay for 1 millisecond.
;
    lda #$01            ;set the outer loop count
                        ;Fall through into delay

delay:
;Delay for number of millseconds in A.
;
    sta save_a          ;save the outer loop count
    stx save_x          ;save X
delay_outer:
    ldx #$c6            ;set the inner loop count
delay_inner:
    dex                 ;decrement the inner loop count
    bne delay_inner     ;loop if more to do

    dec save_a          ;decrement the outer loop count
    bne delay_outer     ;loop if more to do

    ldx save_x          ;restore X
    rts


next_sector:
;increment pointers to the next sector
;
    lda target_ptr      ;get the memory pointer low byte
    clc                 ;clear carry for add
    adc #sector_size    ;add the sector byte count
    sta target_ptr      ;save the memory pointer low byte
    bcc next_incr       ;if no carry skip the high byte increment
    inc target_ptr+1    ;else increment the memory pointer high byte
next_incr:
    ldx sector          ;get the requested sector number
    inx                 ;increment the sector number
    cpx #sectors+1      ;compare it with max + 1
    bmi next_done       ;if < max + 1 just exit

    ldx track           ;get the requested track number
    inx                 ;increment the track number
    stx track           ;save the requested track number
    cpx #tracks         ;compare it with max + 1
    bpl end_of_disk     ;if > max go do disk error $11
    ldx #$01
next_done:
    stx sector          ;save the requested sector number
    clc                 ;flag ok
    rts


dsk_err_restore:
;do disk error and restore the stack
;
    jsr disk_error      ;do "DISK ERROR" message and stop the disk
    jmp restore         ;restore top 32 bytes of stack page and return EOT


end_of_disk:
;do disk error $14, end of disk
;
    lda #e_end_disk     ;set error $11
                        ;Fall through into disk_error

disk_error:
;do "DISK ERROR" message and and stop the disk (??)
;
;Call with the error code in A.  See the e_* constants at
;the top of this file for the error codes.
;
    pha                 ;save A
    tya                 ;copy Y
    pha                 ;save Y

    ;do "DISK ERROR" message

    lda #<disk_err_msg  ;set the message pointer low byte
    ldy #>disk_err_msg  ;set the message pointer high byte
    jsr puts            ;message out

    pla                 ;pull Y
    tay                 ;restore Y
    pla                 ;restore A

    jsr put_spc_hex     ;output [SPACE] <A> as a two digit hex Byte

    ldx #0              ;clear the index
l_eca8:
    lda status_mask,x
    jsr put_spc_hex     ;output [SPACE] <A> as a two digit hex Byte
    inx                 ;increment the index
    cpx #$07            ;compare it with max + 1
    bmi l_eca8          ;loop if more to do

    lda #$02            ;set restore command, 20ms step rate
    sta fdc_cmdst       ;Write to the WD1793 command register

    cli                 ;enable interrupts
    jsr deselect        ;deselect the drives and stop the motors ??
    sec
l_ecbd:
    lda #$ff
    rts


l_ecc0:
;write a WD1793 command and wait a bit
;
    sta command         ;Remember this command as the last one written
    sta fdc_cmdst       ;Write to the WD1793 command register

    ldy #0              ;clear Y
    ldx #$12            ;set the delay count
l_ecca:
    dex                 ;decrement the delay count
    bne l_ecca          ;loop if more to do

    ldx #sector_size    ;set the byte count ??
    rts


l_ecd0:
;wait for WD1793 not busy and mask the status
;
    jsr l_ec1e          ;wait for WD1793 not busy
    bcs l_ecbd          ;if counted out go return $FF

    lda fdc_cmdst       ;Read the WD1793 status register
    sta status          ;save the WD1793 status register copy
    and status_mask     ;AND it with the WD1793 status byte mask
    rts


read_a_sector:
;read one sector to memory ??
;
    lda #$01            ;set the sector count
    sta num_sectors     ;save the requested sector count
                        ;Fall through into read_sectors

read_sectors:
;read <n> sector(s) to memory ??
;
    jsr select_drive
    bne l_ed38          ;if there was any error just exit

l_ece9:
    jsr seek_track      ;seek to track with retries
    bne l_ed38

l_ecee:
    lda #$0a
    sta retries
l_ecf3:
    lda #%11011110      ;mask xx0x xxx0,
                        ;     x--- ----  drive not ready
                        ;     -x-- ----  write protected
                        ;     ---x ----  record not found
                        ;     ---- x---  CRC error
                        ;     ---- -x--  lost data
                        ;     ---- --x-  data request
    sta status_mask     ;save the WD1793 status byte mask

    lda sector          ;get the requested sector number
    beq read_error      ;if 0, goto disk error $40 because sectors start at 1

    sta fdc_sector      ;Write to the WDC1793 sector register

    lda #$88            ;set read single sector command, side 1
    jsr l_ecc0          ;write a WD1793 command and wait a bit
l_ed05:
    lda fdc_cmdst       ;Read the WD1793 status register
    and #%00010110      ;mask 000x 0xx0,
                        ;     ---x ----  record not found
                        ;     ---- -x--  lost data
                        ;     ---- --x-  data request
    beq l_ed05          ;if no data request or error go try again

    lda fdc_data        ;Read the WD1793 data register
    sta (target_ptr),y  ;save the byte to memory
    iny                 ;increment the index
    dex                 ;decrement the count
    bne l_ed05          ;loop if more to do

    jsr l_ecd0          ;wait for WD1793 not busy and mask the status
    bne l_ed2e          ;if any bits set go ??

    dec num_sectors     ;decrement the requested sector count
    beq l_ed38          ;if all done just exit

    jsr next_sector     ;increment pointers to the next sector
    bcs l_ed38          ;if error just exit

    lda track           ;get the requested track number
    cmp fdc_track       ;requested track register
    beq l_ecee

    bne l_ece9

l_ed2e:
    dec retries
    bne l_ecf3

read_error:
;Read Error
;
    lda #e_read_err
    jmp disk_error      ;do "DISK ERROR" message and ??

    ;no error exit

l_ed38:
    cli                 ;enable interrupts
    rts


write_a_sector:
;write one sector to disk ??
;
    lda #$01            ;set a single sector
    sta num_sectors     ;save the requested sector count
                        ;Fall through into write_sectors

write_sectors:
;write <n> sector(s) to disk ??
;
    jsr select_drive
    bne l_ed38

l_ed44:
    jsr seek_track      ;seek to track with retries ??
    bne l_ed38          ;if there was any error just enable interrupts and exit

    lda fdc_cmdst       ;Read the WD1793 status register
    and #%01000000      ;mask 0x00 0000, write protected
    bne do_protected    ;if write protected go do "PROTECTED!" message and exit

l_ed50:
    lda #$0a
    sta retries
l_ed55:
    lda #%11111100      ;mask xxxx xx00,
                        ;     x--- ----  drive not ready
                        ;     -x-- ----  write protected
                        ;     --x- ----  write fault
                        ;     ---x ----  record not found
                        ;     ---- x---  CRC error
                        ;     ---- -x--  lost data
    sta status_mask     ;save the WD1793 status byte mask

    lda sector          ;get the requested sector number
    beq write_error     ;if 0, goto disk error $50 because sectors start at 1

    sta fdc_sector      ;Write to the WD1793 sector register

    lda #$a8            ;set write single sector command, side 1
    jsr l_ecc0          ;write a WD1793 command and wait a bit
l_ed67:
    lda fdc_cmdst       ;Read the WD1793 status register
    and #%11010110      ;mask xx0x 0xx0,
                        ;     x--- ----  drive not ready
                        ;     -x-- ----  write protected
                        ;     ---x ----  record not found
                        ;     ---- -x--  lost data
                        ;     ---- --x-  data request
    beq l_ed67          ;if no flags set go wait some more

    cmp #$02            ;compare it with data request
    beq l_ed7b          ;if data request go send the next byte

    bne l_ed84          ;else go handle everything else, branch always

l_ed74:
    lda fdc_cmdst       ;Read the WD1793 status register
    and #%10010110      ;mask x00x 0xx0,
                        ;     x--- ----  drive not ready
                        ;     ---x ----  record not found
                        ;     ---- -x--  lost data
                        ;     ---- --x-  data request
    beq l_ed74          ;if no flags set go wait some more

l_ed7b:
    lda (target_ptr),y  ;get a byte from memory
    sta fdc_data        ;Write to the WD1793 data register
    iny                 ;increment the index
    dex                 ;decrement the byte count
    bne l_ed74          ;loop if more to do

l_ed84:
    jsr l_ecd0          ;wait for WD1793 not busy and mask the status
    bne l_ed9d          ;if any bits set go ??

    dec num_sectors     ;decrement the requested sector count
    beq l_ed38          ;if all done just exit

    jsr next_sector     ;increment pointers to the next sector
    bcs l_ed38          ;if error just exit

    lda track           ;get the requested track number
    cmp fdc_track       ;requested track register
    beq l_ed50

    bne l_ed44

l_ed9d:
    dec retries
    bne l_ed55

write_error:
;Write Error
;
    lda #e_writ_err     ;set disk error $50
    jmp disk_error      ;do "DISK ERROR" message and ??


do_protected:
;do "PROTECTED!" message
;
    lda #<protected     ;set the message pointer low byte
    ldy #>protected     ;set the message pointer high byte
    jsr puts            ;message out
    clc
    bcc write_error   ;do disk error $50, branch always


protected:
    !text cr,"PROTECTED!",0


l_edbd:
;get a filename from a string or variable
;
;however the filename is presented it seems it must consist of a name of
;zero to six characters, a ":" character and a drive character so as a
;literal string it would be "<name>:<drive>"
;
;when a string variable is used for the filename no check is made to see
;if the string boundary has been passed, as long as there's a ":" character
;six or fewer characters beyond the string start a filename will be returned
;without any error
;
    jsr chrget          ;get the next BASIC byte
    cmp #quote          ;compare it with an open quote character
    php                 ;save the open quote compare status
    bne l_edd3          ;if not an open quote go get a variable

    jsr chrget          ;get the next BASIC byte
    lda txtptr          ;get the BASIC byte pointer low byte
    sta fname_ptr       ;save the filename pointer low byte
    lda txtptr+1        ;get the BASIC byte pointer high byte
    sta fname_ptr+1     ;save the filename pointer high byte
    jmp l_edea          ;get a filename

l_edd3:
    jsr ptrget          ;find variable
    bit valtyp          ;test the datatype
    bmi l_eddf          ;if string type go get a filename from a string

    lda #e_no_fname     ;else set disk error $03, no filename
                        ;Fall through into jmp_dsk_err_res

jmp_dsk_err_res:
;do disk error and restore the stack
;
    jmp dsk_err_restore


l_eddf:
;Get a filename from a string
;
    ldy #$01            ;set the index to the string pointer low byte
    lda (varpnt),y      ;get the string pointer low byte
    sta fname_ptr       ;save the filename pointer low byte
    iny                 ;increment the index to the string pointer high byte
    lda (varpnt),y      ;get the string pointer high byte
    sta fname_ptr+1     ;save the filename pointer high byte

l_edea:
;Get a filename
;
;Filenames are in the format "name:drive".  The name portion is may be up to
;six characters.  Drive is a single digit where 0, 1, or 2 are supported.
;The drive number must always be included ("name" with no drive is an error).
;
;No check is done on the drive number character so any character will be taken
;as a valid drive number.
;
    ldy #0              ;clear the index
l_edec:
    lda (fname_ptr),y   ;get a filename character
    cmp #':'            ;compare it with ":"
    beq l_ee01          ;if it is ":" go get a drive number

    cpy #$06            ;compare the index with max + 1
    bcc l_edfb          ;if not max + 1 continue

bad_filename:
;do disk error $04, bad filename
;
    lda #e_bad_fname    ;set disk error $04, bad filename
    jmp jmp_dsk_err_res ;do disk error and restore the stack

l_edfb:
    sta filename,y      ;save a filename character
    iny                 ;increment the index
    bpl l_edec          ;go get another filename character, branch always

l_ee01:
    tya                 ;copy the index ..
    tax                 ;.. to X

;pad the rest of the filename with spaces

    lda #space          ;set [SPACE]
l_ee05:
    cpx #$06            ;compare the filename index with max + 1
    bcs l_ee0f          ;if done go get the drive number

    sta filename,x      ;save a [SPACE] to the filename
    inx                 ;increment the index
    bpl l_ee05          ;go try another space, branch always

;get the drive number. there seems to be no checking for drive 3 which may break things

l_ee0f:
    iny                 ;increment the index to the drive character
    lda (fname_ptr),y   ;get the drive character
    and #%00000011      ;mask to get the the drive number from the character
    tax                 ;copy it to the index
    lda drive_selects,x ;convert drive number to a drive select bit pattern
    sta drive_sel_f     ;save the drive select bit pattern

    plp                 ;restore the open quote compare status
    bne l_ee32          ;if it wasn't an immediate string just exit

;else it was an immediate string so move the get BASIC byte pointer past it

    tya                 ;copy the index
    clc                 ;clear carry for add
    adc txtptr          ;add the BASIC byte pointer low byte
    sta txtptr          ;save the BASIC byte pointer low byte
    bcc l_ee28          ;if no carry skip the high byte increment

    inc txtptr+1        ;else increment the BASIC byte pointer high byte
l_ee28:
    jsr chrget          ;get the next BASIC byte
    cmp #quote          ;compare it with a close quote character
    bne bad_filename    ;if it's not a close quote go do disk error $04,
                        ;  bad filename

    jsr chrget          ;get the next BASIC byte
l_ee32:
    rts


find_file:
;Search for filename in the directory
;
;Returns dir_ptr pointing to the entry and A with status.
;A=0 means found, A=nonzero means not found.
;
;The directory is 8 sectors on track 0: sectors 1 through 8.  This area
;is 1024 bytes total (8 sectors * 128 bytes).  Each directory entry is
;16 bytes, so there are 64 entries possible.  A directory entry consists of:
;
;  $00-$05   byte  filename
;  $06-$07   word  file length
;  $08-$09   word  load address
;  $0A       byte  file type
;  $0B       byte  ??
;  $0C       byte  file track number
;  $0D       byte  file sector number
;  $0E       byte  file sector count
;  $0F       byte  ??
;
;The first directory entry is special.  This routine will always skip over
;it.  That leaves 63 entries for user files.
;
;We know from load_file that a file consists of N contiguous sectors, where N
;is specified by the byte at offset $0E.  A file can be at most 255 sectors
;(32640 bytes).  A file can span tracks (if the last sector of a track is
;read but the file has has more sectors, it will continue on the first sector
;of the next track).  The first track and sector of the file is specified by
;$0C/$0D.  The file length word at offset $06 seems to be informational only.
;
;Speculation:
;  The first entry (entry 0) may be a special one for the DOS code.  The
;  PEDISK review from the Feb 1981 issue of Compute! magazine! states:
;  "Provision is made when initializing a diskette for omitting the boot,
;  thereby saving more room when only files are stored."
;
;  We know from load_dos that the DOS is always 13 sectors stored right after
;  the directory (track 0, sectors 9 through 21).  If the DOS was written to
;  the disk, then entry 0 would show 13 sectors allocated starting from
;  track 0, sector 9.
;
;  If no DOS code was written to disk, then entry 0 could show 0 sectors
;  allocated.  All 13 sectors normally used for the DOS could then be
;  available for user files, giving an extra 1664 bytes for user files.
;  However, load_dos just blindly loads 13 sectors into RAM and installs the
;  wedge if there's no read error.  Those sectors could contain anything, and
;  if the user tries one of the wedge commands provided by the DOS, the
;  computer will probably crash.
;
;  Another possibility for no DOS code is that entry 0 could show 1 sector
;  allocated (always track 0, sector 9).  The load_dos routine would load
;  this sector at dos+$0000.  The first 24 bytes of the sector would become
;  the DOS jump table (see cmd_vectors), leaving 104 bytes for 6502 code.  It
;  could make the DOS commands a no-op so the computer wouldn't crash if the
;  user tried them.  This approach would leave 12 of the 13 DOS sectors free,
;  giving an extra 1536 bytes for user files.
;
;  The filename in entry 0 may be used to store the disk name.
;
    lda drive_sel_f     ;get drive select bit pattern parsed from filename
    sta drive_sel       ;save pattern to write to drive select latch

    ldy #dir_track      ;set track 0 (first track)
    sty track           ;save the requested track number

    iny                 ;set sector 1 (first sector, sectors start at 1)
    sty sector          ;save the requested sector number

    lda #<dir_sector    ;set the memory pointer low byte
    sta target_ptr      ;save the memory pointer low byte
    lda #>dir_sector    ;set the memory pointer high byte
    sta target_ptr+1    ;save the memory pointer high byte
    sta dir_ptr+1       ;set the search pointer high byte

    jsr read_a_sector   ;read one sector to memory
    bne l_ee94          ;if there was an error just exit

;there was no error

    lda dir_sector+$09  ;TODO what does this do?
    sta oldlin
    lda dir_sector+$0a
    sta oldlin+1

    lda #$10            ;set index to first user-visible directory entry
l_ee5d:
    sta dir_ptr         ;set the directory search pointer low byte
l_ee5f:
    ldy #0              ;clear the index
    lda (dir_ptr),y     ;get a character from the directory
    cmp #$ff            ;compare it with the end marker
    beq l_ee95          ;if end of directory go do the not found exit


l_ee67:
    cmp filename,y      ;compare it with a filename character
    bne l_ee76          ;if not a match go try the next directory entry

    iny                 ;increment the filename index
    cpy #$06            ;compare it with max + 1
    bpl l_ee92          ;if all compared go do the file found exit

    lda (dir_ptr),y     ;else get the next character from the directory
    jmp l_ee67          ;go compare the characters

;no match so try the next entry

l_ee76:
    lda dir_ptr         ;get the directory search pointer low byte
    clc                 ;clear carry for add
    adc #$10            ;add the offset to the next directory entry
    sta dir_ptr         ;save the directory search pointer low byte
    bpl l_ee5f          ;if not past the end of the sector go test the next entry

;else this sector is all done, get the next directory sector

    inc sector          ;increment the requested sector number
    lda sector          ;get the requested sector number
    cmp #dir_num_sec+1  ;compare it with max + 1
    bpl l_ee95          ;if > max go do the not found exit

    jsr read_a_sector   ;read one sector to memory
    bne l_ee94          ;if there was an error just exit

    lda #0              ;set the index to the next directory entry
    beq l_ee5d          ;continue the directory search, branch always

;found the file exit

l_ee92:
    lda #0              ;flag found
l_ee94:
    rts

;not found exit

l_ee95:
    lda #$7f            ;flag not found
    rts


romdos_load:
;Entry point for !LOAD, the only PEDISK II command that is resident
;in the ROM instead of the RAM portion.
;
    jsr load_file       ;perform !LOAD
    jmp restore         ;restore top 32 bytes of stack page and return EOT


load_file:
;Perform !LOAD.  Load a file from disk.
;
;See an explanation of directory entries and files in find_file.
;
    jsr find_file       ;search for filename in the directory
    tax                 ;copy the returned value
    bne not_found       ;if not found go do "??????" message

    ldy #$0a            ;set the index to the file type
    lda (dir_ptr),y     ;get the file type
    cmp #$03            ;compare it with ?? type
    bmi not_found       ;if less than ?? go do "??????" message

    bne l_eebe          ;if not type $03 skip setting the end of program

;the file is type $03

    ldy #$06            ;set the index to the file length low byte
    lda (dir_ptr),y     ;get the file length low byte
    clc                 ;clear carry for add
    adc txttab          ;add BASIC start of program low byte
    sta vartab          ;save BASIC start of variables low byte

    iny                 ;increment the index to the file length high byte
    lda (dir_ptr),y     ;get the file length high byte
    adc txttab+1        ;add BASIC start of program high byte
    sta vartab+1        ;save BASIC start of variables high byte

l_eebe:
    ldy #$08            ;set index to load address low byte
    lda (dir_ptr),y     ;get load address low byte from dir entry
    sta target_ptr      ;save the memory pointer low byte

    iny                 ;increment index to load address high byte
    lda (dir_ptr),y     ;get load address high byte from dir entry
    sta target_ptr+1    ;save the memory pointer high byte

    ldy #$0c            ;set index to file's track number
    lda (dir_ptr),y     ;get track number from dir entry
    sta track           ;save the track number to read

    iny                 ;increment index to file's sector number
    lda (dir_ptr),y     ;get sector number from dir entry
    sta sector          ;save the sector number to read

    iny                 ;increment index to file's sector count
    lda (dir_ptr),y     ;get number of sectors for file from dir entry
    sta num_sectors     ;save the sector count to read

    jsr read_sectors    ;read <n> sector(s) to memory
    bne load_failed     ;if there was an error go flag it and exit

    ldx #0              ;flag no error
                        ;Fall through into load_done
load_done:
    jmp deselect        ;stop the disk and return

;output "??????"

not_found:
    ldx #$06            ;set the "?" count
    lda #'?'            ;set "?"
nf1:
    jsr chrout          ;do character out
    dex                 ;decrement the count
    bne nf1             ;loop if more to do
                        ;Fall through into load_failed

load_failed:
;there was a load error
;
    ldx #$ff            ;flag a load error
    bne load_done       ;go deselect the drives and exit, branch always


addr_prompt:
    !text cr,"ADDR?",0


l_eefb:
;get a hex address into edit_ptr
;
    pha                 ;save A
    tya                 ;copy Y
    pha                 ;save Y

    lda #<addr_prompt   ;set the message pointer low byte
    ldy #>addr_prompt   ;set the message pointer high byte
    jsr puts            ;message out

    pla                 ;pull Y
    tay                 ;restore Y
    pla                 ;restore A
l_ef08:
    jsr l_ef1b          ;get and evaluate a hex byte
    bcs l_ef08          ;if error get another byte

    sta edit_ptr+1      ;save the address high byte
    jsr l_ef1b          ;get and evaluate a hex byte
    sta edit_ptr        ;save the address low byte
    bcc l_ef2e          ;if no error just exit

    jsr l_ef2f          ;output "??" and shift the cursor left
    bcs l_ef08          ;go get another word


l_ef1b:
;get and evaluate a hex byte
;
    jsr l_ef41          ;get and evaluate a hex character


l_ef1e:
;get and evaluate a hex byte second character
;
    bcs l_ef32          ;if not hex output "?" and shift the cursor left

    asl                 ;shift the ..
    asl                 ;.. low nibble ..
    asl                 ;.. to the ..
    asl                 ;.. high nibble
    sta hex_save_a      ;save the high nibble
    jsr l_ef41          ;get and evaluate a hex character
    bcs l_ef2f          ;if there was an error output "??" and cursor left

    ora hex_save_a      ;OR it with the high nibble
    clc                 ;flag ok
l_ef2e:
    rts


l_ef2f:
;output "??" and shift the cursor left
;
    jsr l_ef32          ;output "?" and shift the cursor left


l_ef32:
;output "?" and shift the cursor left
;
    lda #'?'            ;set "?"
    jsr chrout          ;do character out
    lda #crsr_left      ;set cursor left
    jsr chrout          ;do character out
    jsr chrout          ;do character out
l_ef3f:
    sec                 ;flag error
    rts


l_ef41:
;get and evaluate a hex character
;
    jsr l_ef59          ;get a character and test for {STOP}


l_ef44:
;test and evaluate a hex digit
;
    cmp #'0'            ;compare the character with "0"
    bcc l_ef3f          ;if < "0" go return non hex

    cmp #'9'+1          ;compare the character with "9"+1
    bcc l_ef54          ;if < "9"+1 go evaluate the hex digit

    cmp #'A'            ;compare the character with "A"
    bcc l_ef3f          ;if < "A" go return non hex

    cmp #'F'+1          ;compare the character with "F"+1
    bcs l_ef3f          ;if >= "F"+1 go return non hex

    ;evaluate the hex digit

l_ef54:
    jsr hexit           ;evaluate A to a hex nibble
    clc                 ;flag a hex digit
l_ef58:
    rts


l_ef59:
;get a character and test for {STOP}
;
    txa                 ;copy X
    pha                 ;save X
    tya                 ;copy Y
    pha                 ;save Y

    lda #checker        ;set the cursor character
    jsr chrout          ;do character out
    lda #crsr_left      ;set cursor left
    jsr chrout          ;do character out

    jsr l_ef7b          ;wait for and echo a character
    sta save_char       ;save the character

    pla                 ;pull Y
    tay                 ;restore Y
    pla                 ;pull X
    tax                 ;restore X

    lda save_char       ;restore the character
    cmp #stop           ;compare it with {STOP}
    bne l_ef58          ;if not {STOP} just exit

    jmp dos_stop        ;else go do {STOP}


l_ef7b:
;wait for and echo a character
;
    jsr getin           ;do character in
    beq l_ef7b          ;if no character just wait

    jmp chrout          ;do character out


edit_memory:
;display/edit memory
;
    jsr l_eefb          ;get a hex address into edit_ptr
l_ef86:
    lda #cr             ;set [CR]
    jsr chrout          ;do character out

    lda edit_ptr+1      ;get the address high byte
    jsr put_spc_hex     ;output [SPACE] <A> as a two digit hex Byte
    lda edit_ptr        ;get the address low byte
    jsr put_hex_byte    ;output A as a two digit hex Byte

    ldy #0              ;clear the index
l_ef97:
    lda (edit_ptr),y    ;get a byte from memory
    jsr put_spc_hex     ;output [SPACE] <A> as a two digit hex Byte
    iny                 ;increment the index
    cpy #$08            ;compare it with max + 1
    bmi l_ef97          ;loop if more to do

    lda #cr             ;set [CR]
    jsr chrout          ;do character out

;output six spaces

    ldx #$06            ;set the [SPACE] count
l_efa8:
    jsr put_spc         ;output a [SPACE] character
    dex                 ;decrement the [SPACE] count
    bne l_efa8          ;loop if more to do

l_efae:
    stx edit_pos        ;save the line index
    jsr l_ef59          ;get a character and test for {STOP}
    cmp #cr             ;compare the character with [CR]
    beq edit_memory     ;if [CR] go get another hex address

    cmp #space          ;compare it with [SPACE]
    bne l_efc0          ;if not [SPACE] go evaluate a hex digit

;the character was [SPACE]

    jsr put_spc         ;output another [SPACE] character
    bne l_efd0          ;go increment the address, branch always

;evaluate a hex digit

l_efc0:
    jsr l_ef44          ;test and evaluate a hex digit
    jsr l_ef1e          ;get and evaluate a hex byte second character
    bcs l_efae          ;if error go retry this byte

    ldy #0              ;clear the index
    sta (edit_ptr),y    ;save the byte
    cmp (edit_ptr),y    ;compare the byte with the saved copy
    bne l_efe2          ;if not the same go do "??" to show it didn't save

;the byte saved or [SPACE] was returned

l_efd0:
    jsr put_spc         ;output a [SPACE] character
    inc edit_ptr        ;increment the memory address low byte
    bne l_efd9          ;if no rollover skip the high byte increment

    inc edit_ptr+1      ;else increment the memory address high byte
l_efd9:
    ldx edit_pos        ;restore the line index
    inx                 ;increment it
    cpx #$08            ;compare it with max + 1
    bmi l_efae          ;if not there yet go do another byte

    bpl l_ef86          ;else go display a new line, branch always

;the byte didn't save to memory correctly

l_efe2:
    jsr l_ef2f          ;output "??" and shift the cursor left
    bcs l_ef86          ;go display memory from address, branch always


puts:
;Print a null-terminated string.
;
;Call with a pointer to the string in A and Y:
;  A = pointer low byte
;  Y = pointer high byte
;
    sta puts_ptr        ;save the message pointer low byte
    sty puts_ptr+1      ;save the message pointer high byte
    ldy #$ff            ;set -1 for pre increment
puts_loop:
    iny                 ;increment the index
    lda (puts_ptr),y    ;get the next character
    beq puts_done       ;if it's the end marker just exit

    jsr chrout          ;do character out
    clc                 ;clear carry
    bcc puts_loop       ;go do the next character, branch always
puts_done:
    rts

    ;unused
    !byte $68,$07,$01,$2b,$ff,$09,$5e
