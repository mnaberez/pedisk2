;This is a bit correct disassembly of the PEDISK II ROM
;Lee Davison 2013/07/02

lab_30      = $30       ;BASIC end of strings low byte
lab_31      = $31       ;BASIC end of strings high byte
lab_32      = $32       ;utility string pointer low byte
lab_33      = $33       ;utility string pointer high byte
lab_34      = $34       ;BASIC top of memory low byte
lab_35      = $35       ;BASIC top of memory high byte

lab_0070    = $0070     ;get the next BASIC byte
lab_77      = $77       ;BASIC byte pointer low byte
lab_78      = $78       ;BASIC byte pointer high byte
lab_79      = $79       ;patch get BASIC byte JMP
lab_7a      = $7a       ;patch get BASIC byte address low byte
lab_7b      = $7b       ;patch get BASIC byte address high byte
lab_007d    = $007d     ;return from get BASIC byte patch

lab_b7      = $b7       ;memory pointer low byte
lab_b8      = $b8       ;memory pointer high byte

lab_c12b    = $c12b     ;find variable
lab_d722    = $d722     ;output A as a two digit hex Byte
lab_d78d    = $d78d     ;evaluate a hex digit

lab_ffd2    = $ffd2     ;character out to screen
lab_ffe4    = $ffe4     ;character in from keyboard

    *=$e800

;LAB_E800
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

lab_e900:
    !byte $c5           ;drive select latch ??
                        ;bit function
                        ;=== ======
                        ;7-4 not used
                        ;3  motor ??
                        ;2  drive 3 select
                        ;1  drive 2 select
                        ;0  drive 1 select

;LAB_E901
    !byte $25,$c5,$c5,$c1,$25,$64,$21,$df,$ff,$ff,$fb,$fe,$ff,$df,$ff
    !byte $01,$65,$04,$05,$91,$14,$04,$01,$fa,$fe,$ff,$ff,$ff,$ff,$f7,$fb
    !byte $85,$02,$07,$40,$46,$20,$04,$01,$ff,$ff,$fb,$bf,$ff,$fb,$df,$ff
    !byte $80,$01,$44,$40,$05,$40,$04,$04,$ff,$bf,$ff,$ff,$df,$bf,$ff,$fb
    !byte $ff,$7a,$9a,$79,$ca,$ba,$bb,$ab,$00,$41,$00,$00,$00,$00,$44,$00
    !byte $fb,$f3,$fb,$ab,$3e,$fa,$b8,$bb,$00,$40,$04,$04,$00,$00,$40,$84
    !byte $8a,$fa,$3f,$fb,$3b,$7a,$7f,$5b,$44,$20,$00,$04,$00,$00,$00,$c0
    !byte $ff,$ba,$ff,$fb,$7e,$fa,$fe,$fe,$44,$00,$04,$41,$04,$44,$08,$00

;WD1793 floppy disk controller
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

;status bits            ;bit when 1
                        ;=== ======
                        ; 7  drive not ready
                        ; 6  write protect
                        ; 5  write error
                        ; 4  seek error
                        ; 3  crc error
                        ; 2  track zero/lost data
                        ; 1  data request
                        ; 0  busy

lab_e980:
    !byte $05           ;command/status register
lab_e981:
    !byte $40           ;track register
lab_e982:
    !byte $45           ;sector register
lab_e983:
    !byte $8d           ;data register

;LAB_E984
    !byte $04,$d5,$67,$44,$ff,$ff,$ff,$bf,$fb,$bf,$fa,$ff
    !byte $20,$05,$05,$04,$55,$e6,$85,$44,$bb,$ff,$bf,$ff,$ff,$ff,$ff,$ff
    !byte $24,$45,$84,$45,$05,$45,$41,$04,$ff,$fb,$ff,$ff,$ff,$ff,$bb,$ff
    !byte $00,$af,$c5,$05,$81,$85,$21,$05,$df,$ff,$ff,$ef,$fb,$fb,$ef,$ff
    !byte $ff,$7a,$fa,$fe,$ff,$fe,$fa,$da,$00,$44,$00,$04,$00,$00,$40,$05
    !byte $fa,$ba,$6a,$ba,$db,$bb,$bf,$fe,$04,$40,$00,$04,$00,$00,$04,$20
    !byte $bb,$9a,$bf,$fa,$5b,$fb,$7a,$7b,$00,$00,$00,$02,$40,$00,$00,$00
    !byte $da,$aa,$fb,$bf,$fe,$fe,$7e,$3e,$04,$04,$00,$44,$00,$00,$04,$20

lab_ea00:
    jmp lab_ea9a        ;initialization is done with a SYS call to here
    jmp lab_ef83
    jmp lab_ece4        ;read <n> sector(s) to memory ??
    jmp lab_ed3f        ;write <n> sector(s) to disk ??
    jmp lab_ee33
    jmp lab_ee9e

lab_ea12:
    !word $7812-1
    !word lab_ee98-1
    !word $7800-1
    !word $7803-1
    !word $7806-1
    !word $7809-1
    !word $780c-1
    !word $780f-1
    !word $7815-1

lab_ea24:
    !byte $9e           ;token for SYS
    !byte $93           ;token for LOAD
    !byte $94           ;token for SAVE
    !byte $9f           ;token for OPEN
    !byte $a0           ;token for CLOSE
    !byte $85           ;token for INPUT
    !byte $99           ;token for PRINT
    !byte $8a           ;token for RUN
    !byte $9b           ;token for LIST
    !byte $ff,$00

lab_ea2f:
    !byte $01,$02,$04


lab_ea32:
;get BASIC byte patch
;
    CMP #'!'            ;compare the character with "!";compare the character with "!"
    bne lab_ea44        ;if not "!" go test ":"

; found a "!" character

    sty $7f8a           ;save Y

    ldy #$01            ;set the index to the following byte
    lda (lab_77),y      ;get the following byte
    bmi lab_ea4c        ;if it's a token go test it

    ldy $7f8a           ;restore Y
    lda #$21            ;restore A
lab_ea44:
    CMP #':'            ;compare the character with ":";compare the character with ":"
    bcs lab_ea4b        ;if >= ":" just exit

    jmp lab_007d        ;else return to get BASIC byte routine

lab_ea4b:
    rts


lab_ea4c:
;test a token following a "!" character
;
    cld                 ;clear decimal mode
    stx $7f89
    tsx
    stx $7f8b
    ldx #$1f
    sei                 ;disable interrupts
lab_ea57:
    lda $01e0,x
    sta $7fe0,x
    dex
    bpl lab_ea57

    txs
    cli                 ;enable interrupts
    jsr lab_0070        ;get the next BASIC byte
    ldx #$08            ;set the test index to the last entry
lab_ea67:
    cmp lab_ea24,x      ;compare the token byte with a table token
    beq lab_ea71        ;if they match go ??

    dex
    bpl lab_ea67

    bmi lab_ea87

lab_ea71:
    cpx #$08
    beq lab_ea84

    cpx #$02
    bcs lab_ea8c        ;X <= $02

    ldy $37
    iny
    bne lab_ea87

    txa
    bne lab_ea8c

    jmp $7812

lab_ea84:
    jmp $7815

lab_ea87:
    lda #$01
    jmp lab_ec8e

lab_ea8c:
    txa
    asl
    tax
    lda lab_ea12+1,x
    pha
    lda lab_ea12,x
    pha
    jmp lab_edbd


lab_ea9a:
; initialization routine
;
    cld
    lda #<$7800
    sta lab_34          ;BASIC top of memory low byte
    sta lab_30          ;BASIC end of strings low byte
    lda #>$7800
    sta lab_35          ;BASIC top of memory high byte
    sta lab_31          ;BASIC end of strings high byte

    lda #<$77ff
    sta lab_32          ;utility string pointer low byte
    lda #>$77ff
    sta lab_33          ;utility string pointer high byte

    lda #<lab_eb11      ;set the message pointer low byte
    ldy #>lab_eb11      ;set the message pointer high byte
    jsr lab_efe7        ;message out

    ldx #$f2
lab_eab8:
    txa
    eor #$ff
    sta $7800,x
    dex
    bpl lab_eab8

    ldx #$f2
lab_eac3:
    txa
    eor #$ff
    cmp $7800,x
    beq lab_eace

    jmp lab_eb57        ;do "MEM ERROR" message and return

lab_eace:
    dex
    bpl lab_eac3

    lda #$ff
    sta $7e80
    sta $7ea0
    sta $7ec0
    sta $7ee0

    ; load the boot code into memory @ $7800 ??

    lda #<$7800         ;set the memory pointer low byte
    sta lab_b7          ;save the memory pointer low byte
    lda #>$7800         ;set the memory pointer high byte
    sta lab_b8          ;save the memory pointer high byte

    ldx #$00            ;set track zero
    stx $7f92           ;save the WD1793 track number

    inx                 ;set drive 1
    stx $7f91           ;save the drive number ??

    ldx #$0d            ;set the sector count
    stx $7f96           ;save the sector count

    ldx #$09            ;set the sector number
    stx $7f93           ;save the WD1793 sector number

    jsr lab_ece4        ;read <n> sector(s) to memory ??
    bne lab_eb0b        ;if ?? go deselect the drives and stop the motors ??

    lda #$4c            ;set JMP opcode
    sta lab_79          ;save the JMP opcode
    lda #<lab_ea32      ;set the JMP address low byte
    sta lab_7a          ;save the JMP address low byte
    lda #>lab_ea32      ;set the JMP address high byte
    sta lab_7b          ;save the JMP address high byte


lab_eb0b:
; deselect the drives and stop the motors ??
;
    lda #$08
    sta lab_e900
    rts


lab_eb11:
; startup message
;
    !byte $93
    !text "PEDISK II SYSTEM"
    !byte $0d
    !text "CGRS MICROTECH"
    !byte $0d
    !text "LANGHORNE,PA.19047 C1981"
    !byte $0d
    !byte $00           ;end marker


lab_eb4c:
; memory error message
;
    !byte $0d
    !text "MEM ERROR"
    !byte $00           ;end marker


lab_eb57:
; do "MEM ERROR" message
;
    lda #<lab_eb4c      ;set the message pointer low byte
    ldy #>lab_eb4c      ;set the message pointer high byte
    jmp lab_efe7        ;message out and return


lab_eb5e:
;TODO ??
;
    ldx #$1f            ;set the byte count
    sei                 ;disable interrupts
lab_eb61:
    lda $7fe0,x
    sta $01e0,x
    dex                 ;decrement the byte count
    bpl lab_eb61        ;loop if more to do

    ldx $7f8b
    txs
    cli                 ;enable interrupts
    ldy $7f8a
    ldx $7f89
    lda #$00
    jmp lab_ea44


lab_eb7a:
; output a [SPACE] character
;
    lda #$20            ;set [SPACE]
    jmp lab_ffd2        ;do character out and return


lab_eb7f:
;output [SPACE] <A> as a two digit hex Byte
;
    pha                 ;save A
    jsr lab_eb7a        ;output a [SPACE] character
    pla                 ;restore A


lab_eb84:
;output A as a two digit hex Byte
;
    sta $7f8d           ;save X
    stx $7f8e           ;save A
    jsr lab_d722        ;output A as a two digit hex Byte
    ldx $7f8e           ;restore X
    lda $7f8d           ;restore A
    rts


;***********************************************************************************;
;

lab_eb94:
;disk error message
;
    !byte $0d
    !text "DISK ERROR"
    !byte $00           ;end marker


lab_eba0:
;TODO ?
;
    lda #$00            ;clear A
    sta $7f94           ;clear the WD1793 status register copy
    sei                 ;disable interrupts

    lda $7f91           ;get the drive number ??
    beq lab_ec08        ;if zero go do disk error $14

    lda lab_e900
    and #$07
    cmp $7f91           ;compare it with the drive number ??
    beq lab_ebcd

    lda $7f91           ;get the drive number ??
    cmp #$07
    bcs lab_ec08        ;if ?? go do disk error $14

    ora #$08
    sta lab_e900

    lda #$23
    jsr lab_ec55        ;delay for A * $C6 * ?? cycles

    lda lab_e980        ;get the WD1793 status register
    and #$80            ;mask x000 0000, drive not ready
    bne lab_ec05        ;if the drive is not ready go do disk error $13

lab_ebcd:
    rts


lab_ebce:
;seek to track with retries ??
;
    lda #$03            ;set the retry count
    sta $7f8c           ;save the retry count
lab_ebd3:
    lda $7f92           ;get the WD1793 track number
    cmp #$4d            ;compare it with max + 1
    bpl lab_ebff        ;if > max go do disk error $15

    sta lab_e983        ;write the target track to the WD1793 data register
    lda #$98            ;mask x00x x000,
                        ;x          drive not ready
                        ;x       record not found
                        ;x     CRC error
    sta $7f90           ;save the WD1793 status byte mask

    lda #$16            ;set seek command, verify track, 20ms step rate
    jsr lab_ec0d        ;wait for WD1793 not busy and do command A
    bne lab_ebf2        ;go handle any returned error

    lda $7f92           ;get the WD1793 track number
    cmp lab_e981        ;compare it with the WD1793 track register
    bne lab_ebf2        ;go handle any difference

    rts

    ; there was an error or the track numbers differ

lab_ebf2:
    lda #$02            ;set restore command, 20ms step rate
    jsr lab_ec0d        ;wait for WD1793 not busy and do command A

    dec $7f8c           ;decrement the retry count
    bne lab_ebd3        ;if not all done go try again

    ; else do disk error $10

    lda #$10            ;set error $10
    !byte $2c           ;makes next line BIT $xxxx

    ; do disk error $15

lab_ebff:
    lda #$15            ;set error $15
    !byte $2c           ;makes next line BIT $xxxx

    ; do disk error $17

lab_ec02:
    lda #$17            ;set error $17
    !byte $2c           ;makes next line BIT $xxxx

    ; do disk error $13, drive not ready

lab_ec05:
    lda #$13            ;set error $13
    !byte $2c           ;makes next line BIT $xxxx

    ; do disk error $14

lab_ec08:
    lda #$14            ;set error $14
    jmp lab_ec96        ;do "DISK ERROR" message and ??


lab_ec0d:
; wait for WD1793 not busy and do command A
;
    jsr lab_ec1e        ;wait for WD1793 not busy
    bcs lab_ec02        ;if counted out go do disk error $17

    sta $7f95           ;save the WD1793 command register copy
    sta lab_e980        ;save the WD1793 command

    jsr lab_ec53        ;delay for $C6 * ?? cycles
    jmp lab_ecd0        ;wait for WD1793 not busy mask the status and return


lab_ec1e:
; wait for WD1793 not busy
;
    pha                 ;save A
    txa                 ;copy X
    pha                 ;save X
    tya                 ;copy Y
    pha                 ;save Y

    ldy #$20            ;set the outer loop count
lab_ec25:
    ldx #$ff            ;set the inner loop count
lab_ec27:
    lda lab_e980        ;get the WD1793 status register
    and #$01            ;mask 0000 000x, busy
    beq lab_ec4c        ;if not busy go return not counted out

    lda #$23            ;set the wait count
    sta $7f8d           ;save the wait count
lab_ec33:
    dec $7f8d           ;decrement the wait count
    bne lab_ec33        ;loop if more to do

    dex                 ;decrement the inner loop count
    bne lab_ec27        ;loop if more to do

    dey                 ;decrement the outer loop count
    bne lab_ec25        ;loop if more to do

    lda #$d8            ;set force interrupt command, immediate interrupt
    sta $7f95           ;save the WD1793 command register copy
    sta lab_e980        ;save the WD1793 command
    jsr lab_ec53        ;delay for $C6 * ?? cycles
    sec                 ;flag counted out
    bcs lab_ec4d        ;return the flag, branch always

lab_ec4c:
    clc                 ;flag not counted out
lab_ec4d:
    pla                 ;pull Y
    tay                 ;restore Y
    pla                 ;pull X
    tax                 ;restore X
    pla                 ;restore A
    rts


lab_ec53:
; delay for $C6 * ?? cycles
;
    lda #$01            ;set the outer loop count


lab_ec55:
; delay for A * $C6 * ?? cycles
;
    sta $7f8d           ;save the outer loop count
    stx $7f8e           ;save X
lab_ec5b:
    ldx #$c6            ;set the inner loop count
lab_ec5d:
    dex                 ;decrement the inner loop count
    bne lab_ec5d        ;loop if more to do

    dec $7f8d           ;decrement the outer loop count
    bne lab_ec5b        ;loop if more to do

    ldx $7f8e           ;restore X
    rts


lab_ec69:
; increment pointers to the next sector ??
;
    lda lab_b7          ;get the memory pointer low byte
    clc                 ;clear carry for add
    adc #$80            ;add the sector byte count
    sta lab_b7          ;save the memory pointer low byte
    bcc lab_ec74        ;if no carry skip the highbyte increment

    inc lab_b8          ;else increment the memory pointer high byte
lab_ec74:
    ldx $7f93           ;get the WD1793 sector number
    inx                 ;increment the sector number
    cpx #$1b            ;compare it with max + 1
    bmi lab_ec89        ;if < max + 1 just exit

    ldx $7f92           ;get the WD1793 track number
    inx                 ;increment the track number
    stx $7f92           ;save the WD1793 track number
    cpx #$4d            ;compare it with max + 1
    bpl lab_ec94        ;if > max go do disk error $11

    ldx #$01
lab_ec89:
    stx $7f93           ;save the WD1793 sector number
    clc                 ;flag ok
    rts


lab_ec8e:
;TODO ??
;
    jsr lab_ec96        ;do "DISK ERROR" message and ??
    jmp lab_eb5e


lab_ec94:
;TODO do disk error $11
;
    lda #$11


lab_ec96:
; do "DISK ERROR" message and ??
;
    pha                 ;save A
    tya                 ;copy Y
    pha                 ;save Y

    ; do "DISK ERROR" message

    lda #<lab_eb94      ;set the message pointer low byte
    ldy #>lab_eb94      ;set the message pointer high byte
    jsr lab_efe7        ;message out

    pla                 ;pull Y
    tay                 ;restore Y
    pla                 ;restore A

    jsr lab_eb7f        ;output [SPACE] <A> as a two digit hex Byte

    ldx #$00            ;clear the index
lab_eca8:
    lda $7f90,x
    jsr lab_eb7f        ;output [SPACE] <A> as a two digit hex Byte
    inx                 ;increment the index
    cpx #$07            ;compare it with max + 1
    bmi lab_eca8        ;loop if more to do

    lda #$02            ;set restore command, 20ms step rate
    sta lab_e980        ;save the WD1793 command

    cli                 ;enable interrupts
    jsr lab_eb0b        ;deselect the drives and stop the motors ??
    sec
lab_ecbd:
    lda #$ff
    rts


lab_ecc0:
; write a WD1793 command and wait a bit
;
    sta $7f95           ;save the WD1793 command register copy
    sta lab_e980        ;save the WD1793 command

    ldy #$00            ;clear Y
    ldx #$12            ;set the delay count
lab_ecca:
    dex                 ;decrement the delay count
    bne lab_ecca        ;loop if more to do

    ldx #$80            ;set the byte count ??
    rts


lab_ecd0:
; wait for WD1793 not busy and mask the status
;
    jsr lab_ec1e        ;wait for WD1793 not busy
    bcs lab_ecbd        ;if counted out go return $FF

    lda lab_e980        ;get the WD1793 status register
    sta $7f94           ;save the WD1793 status register copy
    and $7f90           ;AND it with the WD1793 status byte mask
    rts


lab_ecdf:
; read one sector to memory ??
;
    lda #$01            ;set the sector count
    sta $7f96           ;save the sector count


lab_ece4:
; read <n> sector(s) to memory ??
;
    jsr lab_eba0
    bne lab_ed38        ;if there was any error just exit

lab_ece9:
    jsr lab_ebce        ;seek to track with retries ??
    bne lab_ed38

lab_ecee:
    lda #$0a
    sta $7f8c
lab_ecf3:
    lda #$de            ;mask xx0x xxx0,
                        ;x          drive not ready
                        ;x         write protected
                        ;x       record not found
                        ;x     CRC error
                        ;x    lost data
                        ;x   data request
    sta $7f90           ;save the WD1793 status byte mask

    lda $7f93           ;get the WD1793 sector number
    beq lab_ed33        ;if zero go do disk error $40

    sta lab_e982        ;save the WD1793 sector register

    lda #$88            ;set read single sector command, side 1
    jsr lab_ecc0        ;write a WD1793 command and wait a bit
lab_ed05:
    lda lab_e980        ;get the WD1793 status register
    and #$16            ;mask 000x 0xx0,
                        ;x       record not found
                        ;x    lost data
                        ;x   data request
    beq lab_ed05        ;if no data request or error go try again

    lda lab_e983        ;read the WD1793 data register
    sta (lab_b7),y      ;save the byte to memory
    iny                 ;increment the index
    dex                 ;decrement the count
    bne lab_ed05        ;loop if more to do

    jsr lab_ecd0        ;wait for WD1793 not busy and mask the status
    bne lab_ed2e        ;if any bits set go ??

    dec $7f96           ;deccrement the sector count
    beq lab_ed38        ;if all done just exit

    jsr lab_ec69        ;increment pointers to the next sector ??
    bcs lab_ed38        ;if error just exit

    lda $7f92           ;get the WD1793 track number
    cmp lab_e981        ;WD1793 track register
    beq lab_ecee

    bne lab_ece9

lab_ed2e:
    dec $7f8c
    bne lab_ecf3

    ; do disk error $40

lab_ed33:
    lda #$40
    jmp lab_ec96        ;do "DISK ERROR" message and ??

    ; no error exit

lab_ed38:
    cli                 ;enable interrupts
    rts


lab_ed3a:
; write one sector to disk ??
;
    lda #$01            ;set a single sector
    sta $7f96           ;save the sector count


lab_ed3f:
; write <n> sector(s) to disk ??
;
    jsr lab_eba0
    bne lab_ed38

lab_ed44:
    jsr lab_ebce        ;seek to track with retries ??
    bne lab_ed38

    lda lab_e980        ;get the WD1793 status register
    and #$40            ;mask 0x00 0000, write protected
    bne lab_eda7        ;if write protected go do "PROTECTED!" message and exit

lab_ed50:
    lda #$0a
    sta $7f8c
lab_ed55:
    lda #$fc            ;mask xxxx xx00,
                        ;x          drive not ready
                        ;x         write protected
                        ;x        write fault
                        ;x       record not found
                        ;x     CRC error
                        ;x    lost data
    sta $7f90           ;save the WD1793 status byte mask

    lda $7f93           ;get the WD1793 sector number
    beq lab_eda2        ;if zero go do disk error $50

    sta lab_e982        ;save the WD1793 sector register
    lda #$a8            ;set write single sector command, side 1
    jsr lab_ecc0        ;write a WD1793 command and wait a bit
lab_ed67:
    lda lab_e980        ;get the WD1793 status register
    and #$d6            ;mask xx0x 0xx0,
                        ;x          drive not ready
                        ;x         write protected
                        ;x       record not found
                        ;x    lost data
                        ;x   data request
    beq lab_ed67        ;if no flags set go wait some more

    cmp #$02            ;compare it with data request
    beq lab_ed7b        ;if data request go send the next byte

    bne lab_ed84        ;else go handle everything else, branch always

lab_ed74:
    lda lab_e980        ;get the WD1793 status register
    and #$96            ;mask x00x 0xx0,
                        ;x          drive not ready
                        ;x       record not found
                        ;x    lost data
                        ;x   data request
    beq lab_ed74        ;if no flags set go wait some more

lab_ed7b:
    lda (lab_b7),y      ;get a byte from memory
    sta lab_e983        ;write the WD1793 data register
    iny                 ;inccrement the index
    dex                 ;decrement the byte count
    bne lab_ed74        ;loop if more to do

lab_ed84:
    jsr lab_ecd0        ;wait for WD1793 not busy and mask the status
    bne lab_ed9d        ;if any bits set go ??

    dec $7f96           ;deccrement the sector count
    beq lab_ed38        ;if all done just exit

    jsr lab_ec69        ;increment pointers to the next sector ??
    bcs lab_ed38        ;if error just exit

    lda $7f92           ;get the WD1793 track number
    cmp lab_e981        ;WD1793 track register
    beq lab_ed50

    bne lab_ed44

lab_ed9d:
    dec $7f8c
    bne lab_ed55

    ; do disk error $50

lab_eda2:
    lda #$50            ;set disk error $50
    jmp lab_ec96        ;do "DISK ERROR" message and ??


lab_eda7:
; do "PROTECTED!" message
;
    lda #<lab_edb1      ;set the message pointer low byte
    ldy #>lab_edb1      ;set the message pointer high byte
    jsr lab_efe7        ;message out
    clc
    bcc lab_eda2        ;do disk error $50, branch always


lab_edb1:
; "PROTECTED!" message
;
    !byte $0d
    !text "PROTECTED!"
    !byte $00           ;end marker


lab_edbd:
;TODO ??
;
    jsr lab_0070        ;get the next BASIC byte
    cmp #$22
    php
    bne lab_edd3

    jsr lab_0070        ;get the next BASIC byte
    lda lab_77
    sta $24
    lda lab_78
    sta $25
    jmp lab_edea

lab_edd3:
    jsr lab_c12b        ;find variable
    bit $07
    bmi lab_eddf

    lda #$03


lab_eddc:
;TODO ??
;
    jmp lab_ec8e

lab_eddf:
    ldy #$01
    lda ($44),y
    sta $24
    iny
    lda ($44),y
    sta $25


lab_edea:
;TODO ??
;
    ldy #$00
lab_edec:
    lda ($24),y
    cmp #$3a
    beq lab_ee01

    cpy #$06
    bcc lab_edfb

lab_edf6:
    lda #$04
    jmp lab_eddc

lab_edfb:
    sta $7fa0,y
    iny
    bpl lab_edec

lab_ee01:
    tya
    tax
    lda #$20
lab_ee05:
    cpx #$06
    bcs lab_ee0f

    sta $7fa0,x
    inx
    bpl lab_ee05

lab_ee0f:
    iny
    lda ($24),y
    and #$03
    tax
    lda lab_ea2f,x
    sta $7fb1
    plp
    bne lab_ee32

    tya
    clc
    adc lab_77
    sta lab_77
    bcc lab_ee28

    inc lab_78
lab_ee28:
    jsr lab_0070        ;get the next BASIC byte
    cmp #$22
    bne lab_edf6

    jsr lab_0070        ;get the next BASIC byte
lab_ee32:
    rts


lab_ee33:
;TODO ??
;
    lda $7fb1
    sta $7f91           ;save the drive number ??
    ldy #$00
    sty $7f92           ;save the WD1793 track number
    iny
    sty $7f93           ;save the WD1793 sector number
    lda #$00
    sta lab_b7          ;save the memory pointer low byte
    lda #$7f
    sta lab_b8          ;save the memory pointer high byte
    sta $23
    jsr lab_ecdf        ;read one sector to memory ??
    bne lab_ee94

    lda $7f09
    sta $56
    lda $7f0a
    sta $57
    lda #$10
lab_ee5d:
    sta $22
lab_ee5f:
    ldy #$00
    lda ($22),y
    cmp #$ff
    beq lab_ee95


lab_ee67:
;TODO ??
;
    cmp $7fa0,y
    bne lab_ee76

    iny
    cpy #$06
    bpl lab_ee92

    lda ($22),y
    jmp lab_ee67

lab_ee76:
    lda $22
    clc
    adc #$10
    sta $22
    bpl lab_ee5f

    inc $7f93           ;increment the WD1793 sector number
    lda $7f93           ;get the WD1793 sector number
    cmp #$09
    bpl lab_ee95

    jsr lab_ecdf        ;read one sector to memory ??
    bne lab_ee94

    lda #$00
    beq lab_ee5d

lab_ee92:
    lda #$00
lab_ee94:
    rts

lab_ee95:
    lda #$7f
    rts


lab_ee98:
;LOAD ??
;
    jsr lab_ee9e
    jmp lab_eb5e


lab_ee9e:
;TODO ??
;
    jsr lab_ee33
    tax
    bne lab_eee6

    ldy #$0a
    lda ($22),y
    cmp #$03
    bmi lab_eee6

    bne lab_eebe

    ldy #$06
    lda ($22   ),y
    clc
    adc $28
    sta $2a
    iny
    lda ($22   ),y
    adc $29
    sta $2b
lab_eebe:
    ldy #$08
    lda ($22),y
    sta lab_b7          ;save the memory pointer low byte
    iny
    lda ($22),y
    sta lab_b8          ;save the memory pointer high byte
    ldy #$0c
    lda ($22),y
    sta $7f92           ;save the WD1793 track number
    iny
    lda ($22),y
    sta $7f93           ;save the WD1793 sector number
    iny
    lda ($22),y
    sta $7f96           ;save the sector count
    jsr lab_ece4        ;read <n> sector(s) to memory ??
    bne lab_eef0

    ldx #$00
lab_eee3:
    jmp lab_eb0b        ;deselect the drives and stop the motors ??

; output "??????"

lab_eee6:
    ldx #$06            ;set the "?" count
    lda #$3f            ;set "?"
lab_eeea:
    jsr lab_ffd2        ;do character out
    dex                 ;decrement the count
    bne lab_eeea        ;loop if more to do

lab_eef0:
    ldx #$ff
    bne lab_eee3        ;branch always


lab_eef4:
;monitor prompt
;
    !byte $0d
    !text "ADDR?"
    !byte $00           ;end marker


lab_eefb:
; get a hex address into $66   /67
;
    pha                 ;save A
    tya                 ;copy Y
    pha                 ;save Y

    lda #<lab_eef4      ;set the message pointer low byte
    ldy #>lab_eef4      ;set the message pointer high byte
    jsr lab_efe7        ;message out

    pla                 ;pull Y
    tay                 ;restore Y
    pla                 ;restore A
lab_ef08:
    jsr lab_ef1b        ;get and evaluate a hex byte
    bcs lab_ef08        ;if error get another byte

    sta $67             ;save the address high byte
    jsr lab_ef1b        ;get and evaluate a hex byte
    sta $66             ;save the address low byte
    bcc lab_ef2e        ;if no error just exit

    jsr lab_ef2f
    bcs lab_ef08        ;go get another word


lab_ef1b:
; get and evaluate a hex byte
;
    jsr lab_ef41        ;get and evaluate a hex character


lab_ef1e:
; get and evaluate a hex byte second character
;
    bcs lab_ef32        ;if not hex go output a "?"

    asl                 ;shift the ..
    asl                 ;.. low nibble ..
    asl                 ;.. to the ..
    asl                 ;.. high nibble
    sta $26
    jsr lab_ef41        ;get and evaluate a hex character
    bcs lab_ef2f

    ora $26             ;OR it with the high nibble
    clc                 ;flag ok
lab_ef2e:
    rts


lab_ef2f:
; ??
;
    jsr lab_ef32


lab_ef32:
; ??
;
    lda #$3f            ;set "?"
    jsr lab_ffd2        ;do character out
    lda #$9d
    jsr lab_ffd2        ;do character out
    jsr lab_ffd2        ;do character out
lab_ef3f:
    sec                 ;flag error
    rts


lab_ef41:
; get and evaluate a hex character
;
    jsr lab_ef59        ;get a character and ??


lab_ef44:
; test and evaluate a hex digit
;
    CMP #'0'            ;compare the character with "0";compare the character with "0"
    bcc lab_ef3f        ;if < "0" go return non hex

    CMP #'9'+1          ;compare the character with "9"+1;compare the character with "9"+1
    bcc lab_ef54        ;if < "9"+1 go evaluate the hex digit

    CMP #'A'            ;compare the character with "A";compare the character with "A"
    bcc lab_ef3f        ;if < "A" go return non hex

    CMP #'F'+1          ;compare the character with "F"+1;compare the character with "F"+1
    bcs lab_ef3f        ;if >= "F"+1 go return non hex

    ; evaluate the hex digit

lab_ef54:
    jsr lab_d78d        ;evaluate a hex digit
    clc                 ;flag a hex digit
lab_ef58:
    rts


lab_ef59:
; get a character and ??
;
    txa                 ;copy X
    pha                 ;save X
    tya                 ;copy Y
    pha                 ;save Y

    lda #$e6
    jsr lab_ffd2        ;do character out
    lda #$9d
    jsr lab_ffd2        ;do character out

    jsr lab_ef7b        ;wait for and echo a character
    sta $7f88           ;save the charater

    pla                 ;pull Y
    tay                 ;restore Y
    pla                 ;pull X
    tax                 ;restore X

    lda $7f88           ;restore the charater
    cmp #$03            ;compare it with ??
    bne lab_ef58        ;if ?? just exit

    jmp $7a00


lab_ef7b:
; wait for and echo a character
;
    jsr lab_ffe4        ;do character in
    beq lab_ef7b        ;if no character just wait

    jmp lab_ffd2        ;do character out


lab_ef83:
; ??
;
    jsr lab_eefb        ;get a hex address into $66   /67
lab_ef86:
    lda #$0d            ;set [CR]
    jsr lab_ffd2        ;do character out

    lda $67             ;get the address high byte
    jsr lab_eb7f        ;output [SPACE] <A> as a two digit hex Byte
    lda $66             ;get the address low byte
    jsr lab_eb84        ;output A as a two digit hex Byte

    ldy #$00            ;clear the index
lab_ef97:
    lda ($66),y         ;get a byte from memory
    jsr lab_eb7f        ;output [SPACE] <A> as a two digit hex Byte
    iny                 ;increment the index
    cpy #$08            ;compare it with max + 1
    bmi lab_ef97        ;loop if more to do

    lda #$0d            ;set [CR]
    jsr lab_ffd2        ;do character out
    ldx #$06            ;set the [SPACE] count
lab_efa8:
    jsr lab_eb7a        ;output a [SPACE] character
    dex                 ;decrement the [SPACE] count
    bne lab_efa8        ;loop if more to do

lab_efae:
    stx $27             ;save the line index
    jsr lab_ef59        ;get a character and ??
    cmp #$0d            ;compare it with [CR]
    beq lab_ef83        ;if [CR] go get another hex address

    cmp #$20            ;compare it with [SPACE]
    bne lab_efc0        ;if not [SPACE] go evaluate a hex digit

    jsr lab_eb7a        ;output a [SPACE] character
    bne lab_efd0        ;go increment the address, branch always

lab_efc0:
    jsr lab_ef44        ;test and evaluate a hex digit
    jsr lab_ef1e        ;get and evaluate a hex byte second character
    bcs lab_efae        ;if error go ??

    ldy #$00            ;clear the index
    sta ($66),y         ;save the byte
    cmp ($66),y         ;compare the byte with the saved copy
    bne lab_efe2        ;if not the same go ??

; the byte saved or [SPACE] was returned

lab_efd0:
    jsr lab_eb7a        ;output a [SPACE] character
    inc $66             ;inrement the address low byte
    bne lab_efd9        ;if no rollover skip the high byte increment

    inc $67             ;else increment the high byte
lab_efd9:
    ldx $27             ;get the line index
    inx                 ;inccrement it
    cpx #$08            ;compare it with max + 1
    bmi lab_efae        ;if not there yet go ??

    bpl lab_ef86        ;else ??, branch always

; the byte didn't save to memory correctly

lab_efe2:
    jsr lab_ef2f
    bcs lab_ef86        ;branch always


lab_efe7:
; message out
;
    sta $6c             ;save the message pointer low byte
    sty $6d             ;save the message pointer high byte
    ldy #$ff            ;set -1 for pre increment
lab_efed:
    iny                 ;increment the index
    lda ($6c),y         ;get the next character
    beq lab_eff8        ;if it's the end marker just exit

    jsr lab_ffd2        ;do character out
    clc                 ;clear carry
    bcc lab_efed        ;go do the next character, branch always

lab_eff8:
    rts

    ; unused ??
    !byte $68,$07,$01,$2b,$ff,$09,$5e
