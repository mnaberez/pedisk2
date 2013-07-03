; This is a bit correct disassembly of the PEDISK II ROM
; Lee Davison 2013/07/02

LAB_30      = $30       ;BASIC end of strings low byte
LAB_31      = $31       ;BASIC end of strings high byte
LAB_32      = $32       ;utility string pointer low byte
LAB_33      = $33       ;utility string pointer high byte
LAB_34      = $34       ;BASIC top of memory low byte
LAB_35      = $35       ;BASIC top of memory high byte

LAB_0070    = $0070     ;get the next BASIC byte
LAB_77      = $77       ;BASIC byte pointer low byte
LAB_78      = $78       ;BASIC byte pointer high byte
LAB_79      = $79       ;patch get BASIC byte JMP
LAB_7A      = $7A       ;patch get BASIC byte address low byte
LAB_7B      = $7B       ;patch get BASIC byte address high byte
LAB_007D    = $007D     ;return from get BASIC byte patch

LAB_B7      = $B7       ;memory pointer low byte
LAB_B8      = $B8       ;memory pointer high byte

LAB_C12B    = $C12B     ;find variable
LAB_D722    = $D722     ;output A as a two digit hex Byte
LAB_D78D    = $D78D     ;evaluate a hex digit

LAB_FFD2    = $FFD2     ;character out to screen
LAB_FFE4    = $FFE4     ;character in from keyboard

    *=$E800

;LAB_E800
    !byte $04,$45,$45,$05,$07,$80,$C5,$44,$7F,$FF,$DF,$FF,$F7,$DF,$FB,$FF
    !byte $00,$04,$01,$04,$41,$05,$80,$05,$FE,$FF,$FF,$FB,$FF,$FB,$FB,$BF
    !byte $44,$41,$45,$45,$05,$24,$24,$25,$FF,$FF,$D7,$FF,$FF,$FF,$FF,$FF
    !byte $04,$04,$01,$45,$05,$04,$80,$04,$FF,$FF,$FD,$FF,$FF,$FF,$FE,$FB
    !byte $7B,$FA,$7A,$FE,$BA,$FF,$FB,$3A,$00,$00,$04,$00,$00,$05,$45,$40
    !byte $FA,$7A,$BE,$DE,$FB,$BB,$BE,$BB,$04,$20,$00,$40,$01,$01,$04,$00
    !byte $3E,$16,$BF,$FA,$FE,$BF,$FA,$FE,$00,$00,$00,$01,$00,$00,$00,$04
    !byte $D2,$BA,$7A,$FF,$FA,$DA,$7A,$FA,$01,$01,$00,$04,$40,$00,$40,$05
    !byte $46,$C4,$95,$05,$C4,$02,$43,$44,$FF,$FF,$FF,$FB,$FF,$FF,$FF,$FF
    !byte $21,$23,$81,$41,$45,$05,$45,$C0,$BF,$BF,$FF,$BF,$FF,$FF,$FF,$FF
    !byte $A7,$65,$0C,$24,$10,$01,$04,$01,$FF,$FF,$EB,$FF,$FF,$FB,$9F,$BB
    !byte $05,$C5,$42,$04,$95,$84,$14,$00,$FF,$FB,$FE,$FB,$BB,$FF,$FF,$FB
    !byte $FE,$DC,$FA,$BC,$9A,$4B,$FA,$7B,$00,$00,$00,$00,$00,$40,$00,$04
    !byte $B3,$FA,$7A,$FE,$FF,$1A,$FA,$BA,$00,$04,$2C,$04,$80,$00,$44,$04
    !byte $7A,$1A,$F2,$78,$FF,$3E,$3A,$5A,$00,$00,$20,$00,$00,$00,$00,$01
    !byte $FA,$FE,$3E,$FA,$FB,$FF,$BE,$BA,$00,$20,$48,$0C,$00,$20,$00,$05

LAB_E900
    !byte $C5           ;drive select latch ??
                        ;bit function
                        ;=== ======
                        ;7-4 not used
                        ;3  motor ??
                        ;2  drive 3 select
                        ;1  drive 2 select
                        ;0  drive 1 select

;LAB_E901
    !byte $25,$C5,$C5,$C1,$25,$64,$21,$DF,$FF,$FF,$FB,$FE,$FF,$DF,$FF
    !byte $01,$65,$04,$05,$91,$14,$04,$01,$FA,$FE,$FF,$FF,$FF,$FF,$F7,$FB
    !byte $85,$02,$07,$40,$46,$20,$04,$01,$FF,$FF,$FB,$BF,$FF,$FB,$DF,$FF
    !byte $80,$01,$44,$40,$05,$40,$04,$04,$FF,$BF,$FF,$FF,$DF,$BF,$FF,$FB
    !byte $FF,$7A,$9A,$79,$CA,$BA,$BB,$AB,$00,$41,$00,$00,$00,$00,$44,$00
    !byte $FB,$F3,$FB,$AB,$3E,$FA,$B8,$BB,$00,$40,$04,$04,$00,$00,$40,$84
    !byte $8A,$FA,$3F,$FB,$3B,$7A,$7F,$5B,$44,$20,$00,$04,$00,$00,$00,$C0
    !byte $FF,$BA,$FF,$FB,$7E,$FA,$FE,$FE,$44,$00,$04,$41,$04,$44,$08,$00

; WD1793 floppy disk controller

LAB_E980
    !byte $05           ;command/status register

;     Command           b7 b6 b5 b4 b3 b2 b1 b0
; I   Restore           0  0  0  0  h  V  r1 r0
; I   Seek              0  0  0  1  h  V  r1 r0
; I   Step              0  0  1  T  h  V  r1 r0
; I   Step-In           0  1  0  T  h  V  r1 r0
; I   Step-Out          0  1  1  T  h  V  r1 r0
; II  Read Sector       1  0  0  m  S  E  C  0
; II  Write Sector      1  0  1  m  S  E  C  a0
; III Read Address      1  1  0  0  0  E  0  0
; III Read Track        1  1  1  0  0  E  0  0
; III Write Track       1  1  1  1  0  E  0  0
; IV  Force Interrupt   1  1  0  1  i3 i2 i1 i0

;    r1 r0  Stepping Motor Rate
;     1  1   30 ms
;     1  0   20 ms
;     0  1   12 ms
;     0  0   6 ms
;      V      Track Number Verify Flag (0: no verify, 1: verify on dest track)
;      h      Head Load Flag (1: load head at beginning, 0: unload head)
;        T      Track Update Flag (0: no update, 1: update Track Register)
;        a0     Data Address Mark (0: FB, 1: F8 (deleted DAM))
;        C      Side Compare Flag (0: disable side compare, 1: enable side comp)
;        E      15 ms delay (0: no 15ms delay, 1: 15 ms delay)
;        S      Side Compare Flag (0: compare for side 0, 1: compare for side 1)
;        m      Multiple Record Flag (0: single record, 1: multiple records)
;            i3 i2 i1 i0    Interrupt Condition Flags
;               i3-i0 = 0 Terminate with no interrupt (INTRQ)
;                     i3 = 1 Immediate interrupt, requires a reset
;                     i2 = 1 Index pulse
;                     i1 = 1 Ready to not ready transition
;                     i0 = 1 Not ready to ready transition

; status bits                 ; bit when 1
                        ;=== ======
                        ;7  drive not ready
                        ;6  write protect
                        ;5  write error
                        ;4  seek error
                        ;3  crc error
                        ;2  track zero/lost data
                        ;1  data request
                        ;0  busy

LAB_E981
    !byte $40           ;track register
LAB_E982
    !byte $45           ;sector register
LAB_E983
    !byte $8D           ;data register

;LAB_E984
    !byte $04,$D5,$67,$44,$FF,$FF,$FF,$BF,$FB,$BF,$FA,$FF
    !byte $20,$05,$05,$04,$55,$E6,$85,$44,$BB,$FF,$BF,$FF,$FF,$FF,$FF,$FF
    !byte $24,$45,$84,$45,$05,$45,$41,$04,$FF,$FB,$FF,$FF,$FF,$FF,$BB,$FF
    !byte $00,$AF,$C5,$05,$81,$85,$21,$05,$DF,$FF,$FF,$EF,$FB,$FB,$EF,$FF
    !byte $FF,$7A,$FA,$FE,$FF,$FE,$FA,$DA,$00,$44,$00,$04,$00,$00,$40,$05
    !byte $FA,$BA,$6A,$BA,$DB,$BB,$BF,$FE,$04,$40,$00,$04,$00,$00,$04,$20
    !byte $BB,$9A,$BF,$FA,$5B,$FB,$7A,$7B,$00,$00,$00,$02,$40,$00,$00,$00
    !byte $DA,$AA,$FB,$BF,$FE,$FE,$7E,$3E,$04,$04,$00,$44,$00,$00,$04,$20

; initialization is done with a SYS call to here

;LAB_EA00:
    JMP   LAB_EA9A
;LAB_EA03:
    JMP   LAB_EF83
;LAB_EA06:
    JMP   LAB_ECE4      ;read <n> sector(s) to memory ??
;LAB_EA09:
    JMP   LAB_ED3F      ;write <n> sector(s) to disk ??
;LAB_EA0C:
    JMP   LAB_EE33
;LAB_EA0F:
    JMP   LAB_EE9E
LAB_EA12:
    !word $7812-1
    !word LAB_EE98-1
    !word $7800-1
    !word $7803-1
    !word $7806-1
    !word $7809-1
    !word $780c-1
    !word $780f-1
    !word $7815-1
LAB_EA24:
    !byte $9E           ;token for SYS
    !byte $93           ;token for LOAD
    !byte $94           ;token for SAVE
    !byte $9F           ;token for OPEN
    !byte $A0           ;token for CLOSE
    !byte $85           ;token for INPUT
    !byte $99           ;token for PRINT
    !byte $8A           ;token for RUN
    !byte $9B           ;token for LIST
    !byte $FF,$00

LAB_EA2F:
    !byte $01,$02,$04


;***********************************************************************************;
;
; get BASIC byte patch

LAB_EA32:
    CMP   #'!'          ;compare the character with "!"
    BNE   LAB_EA44      ;if not "!" go test ":"

; found a "!" character

    STY   $7f8a         ;save Y

    LDY   #$01          ;set the index to the following byte
    LDA   (LAB_77),Y    ;get the following byte
    BMI   LAB_EA4C      ;if it's a token go test it

    LDY   $7f8a         ;restore Y
    LDA   #$21          ;restore A
LAB_EA44:
    CMP   #':'          ;compare the character with ":"
    BCS   LAB_EA4B      ;if >= ":" just exit

    JMP   LAB_007D      ;else return to get BASIC byte routine

LAB_EA4B:
    RTS


;***********************************************************************************;
;
; test a token following a "!" character

LAB_EA4C:
    CLD                 ;clear decimal mode
    STX   $7f89
    TSX
    STX   $7f8b
    LDX   #$1F
    SEI                 ;disable interrupts
LAB_EA57:
    LDA   $01e0   ,X
    STA   $7fe0,X
    DEX
    BPL   LAB_EA57

    TXS
    CLI                 ;enable interrupts
    JSR   LAB_0070      ;get the next BASIC byte
    LDX   #$08          ;set the test index to the last entry
LAB_EA67:
    CMP   LAB_EA24,X    ;compare the token byte with a table token
    BEQ   LAB_EA71      ;if they match go ??

    DEX
    BPL   LAB_EA67

    BMI   LAB_EA87

LAB_EA71:
    CPX   #$08
    BEQ   LAB_EA84

    CPX   #$02
    BCS   LAB_EA8C      ;X <= $02

    LDY   $37
    INY
    BNE   LAB_EA87

    TXA
    BNE   LAB_EA8C

    JMP   $7812

LAB_EA84:
    JMP   $7815

LAB_EA87:
    LDA   #$01
    JMP   LAB_EC8E

LAB_EA8C:
    TXA
    ASL
    TAX
    LDA   LAB_EA12+1,X
    PHA
    LDA   LAB_EA12,X
    PHA
    JMP   LAB_EDBD


;***********************************************************************************;
;
; initialization routine

LAB_EA9A:
    CLD
    LDA   #<$7800
    STA   LAB_34        ;BASIC top of memory low byte
    STA   LAB_30        ;BASIC end of strings low byte
    LDA   #>$7800
    STA   LAB_35        ;BASIC top of memory high byte
    STA   LAB_31        ;BASIC end of strings high byte

    LDA   #<$77ff
    STA   LAB_32        ;utility string pointer low byte
    LDA   #>$77ff
    STA   LAB_33        ;utility string pointer high byte

    LDA   #<LAB_EB11    ;set the message pointer low byte
    LDY   #>LAB_EB11    ;set the message pointer high byte
    JSR   LAB_EFE7      ;message out

    LDX   #$F2
LAB_EAB8:
    TXA
    EOR   #$FF
    STA   $7800,X
    DEX
    BPL   LAB_EAB8

    LDX   #$F2
LAB_EAC3:
    TXA
    EOR   #$FF
    CMP   $7800,X
    BEQ   LAB_EACE

    JMP   LAB_EB57      ;do "MEM ERROR" message and return

LAB_EACE:
    DEX
    BPL   LAB_EAC3

    LDA   #$FF
    STA   $7e80
    STA   $7ea0
    STA   $7ec0
    STA   $7ee0

; load the boot code into memory @ $7800 ??

    LDA   #<$7800       ;set the memory pointer low byte
    STA   LAB_B7        ;save the memory pointer low byte
    LDA   #>$7800       ;set the memory pointer high byte
    STA   LAB_B8        ;save the memory pointer high byte

    LDX   #$00          ;set track zero
    STX   $7f92         ;save the WD1793 track number

    INX                 ;set drive 1
    STX   $7f91         ;save the drive number ??

    LDX   #$0D          ;set the sector count
    STX   $7f96         ;save the sector count

    LDX   #$09          ;set the sector number
    STX   $7f93         ;save the WD1793 sector number

    JSR   LAB_ECE4      ;read <n> sector(s) to memory ??
    BNE   LAB_EB0B      ;if ?? go deselect the drives and stop the motors ??

    LDA   #$4C          ;set JMP opcode
    STA   LAB_79        ;save the JMP opcode
    LDA   #<LAB_EA32    ;set the JMP address low byte
    STA   LAB_7A        ;save the JMP address low byte
    LDA   #>LAB_EA32    ;set the JMP address high byte
    STA   LAB_7B        ;save the JMP address high byte


;***********************************************************************************;
;
; deselect the drives and stop the motors ??

LAB_EB0B:
    LDA   #$08
    STA   LAB_E900
    RTS


;***********************************************************************************;
;
; startup message

LAB_EB11:
    !byte $93
    !text "PEDISK II SYSTEM"
    !byte $0D
    !text "CGRS MICROTECH"
    !byte $0D
    !text "LANGHORNE,PA.19047 C1981"
    !byte $0D
    !byte $00           ;end marker


;***********************************************************************************;
;
; memory error message

LAB_EB4C:
    !byte $0D
    !text "MEM ERROR"
    !byte $00           ;end marker


;***********************************************************************************;
;
; do "MEM ERROR" message

LAB_EB57:
    LDA   #<LAB_EB4C    ;set the message pointer low byte
    LDY   #>LAB_EB4C    ;set the message pointer high byte
    JMP   LAB_EFE7      ;message out and return


;***********************************************************************************;
;
; ??

LAB_EB5E:
    LDX   #$1F          ;set the byte count
    SEI                 ;disable interrupts
LAB_EB61:
    LDA   $7fe0,X
    STA   $01e0,X
    DEX                 ;decrement the byte count
    BPL   LAB_EB61      ;loop if more to do

    LDX   $7f8b
    TXS
    CLI                 ;enable interrupts
    LDY   $7f8a
    LDX   $7f89
    LDA   #$00
    JMP   LAB_EA44


;***********************************************************************************;
;
; output a [SPACE] character

LAB_EB7A:
    LDA   #$20          ;set [SPACE]
    JMP   LAB_FFD2      ;do character out and return


;***********************************************************************************;
;
; output [SPACE] <A> as a two digit hex Byte

LAB_EB7F:
    PHA                 ;save A
    JSR   LAB_EB7A      ;output a [SPACE] character
    PLA                 ;restore A


;***********************************************************************************;
;
; output A as a two digit hex Byte

LAB_EB84:
    STA   $7f8d         ;save X
    STX   $7f8e         ;save A
    JSR   LAB_D722      ;output A as a two digit hex Byte
    LDX   $7f8e         ;restore X
    LDA   $7f8d         ;restore A
    RTS


;***********************************************************************************;
;
; disk error message

LAB_EB94:
    !byte $0D
    !text "DISK ERROR"
    !byte $00           ;end marker


;***********************************************************************************;
;
; ??

LAB_EBA0:
    LDA   #$00          ;clear A
    STA   $7f94         ;clear the WD1793 status register copy
    SEI                 ;disable interrupts

    LDA   $7f91         ;get the drive number ??
    BEQ   LAB_EC08      ;if zero go do disk error $14

    LDA   LAB_E900
    AND   #$07
    CMP   $7f91         ;compare it with the drive number ??
    BEQ   LAB_EBCD

    LDA   $7f91         ;get the drive number ??
    CMP   #$07
    BCS   LAB_EC08      ;if ?? go do disk error $14

    ORA   #$08
    STA   LAB_E900

    LDA   #$23
    JSR   LAB_EC55      ;delay for A * $C6 * ?? cycles

    LDA   LAB_E980      ;get the WD1793 status register
    AND   #$80          ;mask x000 0000, drive not ready
    BNE   LAB_EC05      ;if the drive is not ready go do disk error $13

LAB_EBCD:
    RTS


;***********************************************************************************;
;
; seek to track with retries ??

LAB_EBCE:
    LDA   #$03          ;set the retry count
    STA   $7f8c         ;save the retry count
LAB_EBD3:
    LDA   $7f92         ;get the WD1793 track number
    CMP   #$4D          ;compare it with max + 1
    BPL   LAB_EBFF      ;if > max go do disk error $15

    STA   LAB_E983      ;write the target track to the WD1793 data register
    LDA   #$98          ;mask x00x x000,
                        ;x          drive not ready
                        ;x       record not found
                        ;x     CRC error
    STA   $7f90         ;save the WD1793 status byte mask

    LDA   #$16          ;set seek command, verify track, 20ms step rate
    JSR   LAB_EC0D      ;wait for WD1793 not busy and do command A
    BNE   LAB_EBF2      ;go handle any returned error

    LDA   $7f92         ;get the WD1793 track number
    CMP   LAB_E981      ;compare it with the WD1793 track register
    BNE   LAB_EBF2      ;go handle any difference

    RTS

; there was an error or the track numbers differ

LAB_EBF2:
    LDA   #$02          ;set restore command, 20ms step rate
    JSR   LAB_EC0D      ;wait for WD1793 not busy and do command A

    DEC   $7f8c         ;decrement the retry count
    BNE   LAB_EBD3      ;if not all done go try again

; else do disk error $10

    LDA   #$10          ;set error $10
    !byte $2C           ;makes next line BIT $xxxx

; do disk error $15

LAB_EBFF
    LDA   #$15          ;set error $15
    !byte $2C           ;makes next line BIT $xxxx

; do disk error $17

LAB_EC02
    LDA   #$17          ;set error $17
    !byte $2C           ;makes next line BIT $xxxx

; do disk error $13, drive not ready

LAB_EC05
    LDA   #$13          ;set error $13
    !byte $2C           ;makes next line BIT $xxxx

; do disk error $14

LAB_EC08
    LDA   #$14          ;set error $14
    JMP   LAB_EC96      ;do "DISK ERROR" message and ??


;***********************************************************************************;
;
; wait for WD1793 not busy and do command A

LAB_EC0D:
    JSR   LAB_EC1E      ;wait for WD1793 not busy
    BCS   LAB_EC02      ;if counted out go do disk error $17

    STA   $7f95         ;save the WD1793 command register copy
    STA   LAB_E980      ;save the WD1793 command

    JSR   LAB_EC53      ;delay for $C6 * ?? cycles
    JMP   LAB_ECD0      ;wait for WD1793 not busy mask the status and return


;***********************************************************************************;
;
; wait for WD1793 not busy

LAB_EC1E:
    PHA                 ;save A
    TXA                 ;copy X
    PHA                 ;save X
    TYA                 ;copy Y
    PHA                 ;save Y

    LDY   #$20          ;set the outer loop count
LAB_EC25:
    LDX   #$FF          ;set the inner loop count
LAB_EC27:
    LDA   LAB_E980      ;get the WD1793 status register
    AND   #$01          ;mask 0000 000x, busy
    BEQ   LAB_EC4C      ;if not busy go return not counted out

    LDA   #$23          ;set the wait count
    STA   $7f8d         ;save the wait count
LAB_EC33:
    DEC   $7f8d         ;decrement the wait count
    BNE   LAB_EC33      ;loop if more to do

    DEX                 ;decrement the inner loop count
    BNE   LAB_EC27      ;loop if more to do

    DEY                 ;decrement the outer loop count
    BNE   LAB_EC25      ;loop if more to do

    LDA   #$D8          ;set force interrupt command, immediate interrupt
    STA   $7f95         ;save the WD1793 command register copy
    STA   LAB_E980      ;save the WD1793 command
    JSR   LAB_EC53      ;delay for $C6 * ?? cycles
    SEC                 ;flag counted out
    BCS   LAB_EC4D      ;return the flag, branch always

LAB_EC4C:
    CLC                 ;flag not counted out
LAB_EC4D:
    PLA                 ;pull Y
    TAY                 ;restore Y
    PLA                 ;pull X
    TAX                 ;restore X
    PLA                 ;restore A
    RTS


;***********************************************************************************;
;
; delay for $C6 * ?? cycles

LAB_EC53:
    LDA   #$01          ;set the outer loop count


;***********************************************************************************;
;
; delay for A * $C6 * ?? cycles

LAB_EC55:
    STA   $7f8d         ;save the outer loop count
    STX   $7f8e         ;save X
LAB_EC5B:
    LDX   #$C6          ;set the inner loop count
LAB_EC5D:
    DEX                 ;decrement the inner loop count
    BNE   LAB_EC5D      ;loop if more to do

    DEC   $7f8d         ;decrement the outer loop count
    BNE   LAB_EC5B      ;loop if more to do

    LDX   $7f8e         ;restore X
    RTS


;***********************************************************************************;
;
; increment pointers to the next sector ??

LAB_EC69:
    LDA   LAB_B7        ;get the memory pointer low byte
    CLC                 ;clear carry for add
    ADC   #$80          ;add the sector byte count
    STA   LAB_B7        ;save the memory pointer low byte
    BCC   LAB_EC74      ;if no carry skip the highbyte increment

    INC   LAB_B8        ;else increment the memory pointer high byte
LAB_EC74:
    LDX   $7f93         ;get the WD1793 sector number
    INX                 ;increment the sector number
    CPX   #$1B          ;compare it with max + 1
    BMI   LAB_EC89      ;if < max + 1 just exit

    LDX   $7f92         ;get the WD1793 track number
    INX                 ;increment the track number
    STX   $7f92         ;save the WD1793 track number
    CPX   #$4D          ;compare it with max + 1
    BPL   LAB_EC94      ;if > max go do disk error $11

    LDX   #$01
LAB_EC89:
    STX   $7f93         ;save the WD1793 sector number
    CLC                 ;flag ok
    RTS


;***********************************************************************************;
;
; ??

LAB_EC8E:
    JSR   LAB_EC96      ;do "DISK ERROR" message and ??
    JMP   LAB_EB5E


;***********************************************************************************;
;
; do disk error $11

LAB_EC94:
    LDA   #$11


;***********************************************************************************;
;
; do "DISK ERROR" message and ??

LAB_EC96:
    PHA                 ;save A
    TYA                 ;copy Y
    PHA                 ;save Y

; do "DISK ERROR" message

    LDA   #<LAB_EB94    ;set the message pointer low byte
    LDY   #>LAB_EB94    ;set the message pointer high byte
    JSR   LAB_EFE7      ;message out

    PLA                 ;pull Y
    TAY                 ;restore Y
    PLA                 ;restore A

    JSR   LAB_EB7F      ;output [SPACE] <A> as a two digit hex Byte

    LDX   #$00          ;clear the index
LAB_ECA8:
    LDA   $7f90,X
    JSR   LAB_EB7F      ;output [SPACE] <A> as a two digit hex Byte
    INX                 ;increment the index
    CPX   #$07          ;compare it with max + 1
    BMI   LAB_ECA8      ;loop if more to do

    LDA   #$02          ;set restore command, 20ms step rate
    STA   LAB_E980      ;save the WD1793 command

    CLI                 ;enable interrupts
    JSR   LAB_EB0B      ;deselect the drives and stop the motors ??
    SEC
LAB_ECBD:
    LDA   #$FF
    RTS


;***********************************************************************************;
;
; write a WD1793 command and wait a bit

LAB_ECC0:
    STA   $7f95         ;save the WD1793 command register copy
    STA   LAB_E980      ;save the WD1793 command

    LDY   #$00          ;clear Y
    LDX   #$12          ;set the delay count
LAB_ECCA:
    DEX                 ;decrement the delay count
    BNE   LAB_ECCA      ;loop if more to do

    LDX   #$80          ;set the byte count ??
    RTS


;***********************************************************************************;
;
; wait for WD1793 not busy and mask the status

LAB_ECD0:
    JSR   LAB_EC1E      ;wait for WD1793 not busy
    BCS   LAB_ECBD      ;if counted out go return $FF

    LDA   LAB_E980      ;get the WD1793 status register
    STA   $7f94         ;save the WD1793 status register copy
    AND   $7f90         ;AND it with the WD1793 status byte mask
    RTS


;***********************************************************************************;
;
; read one sector to memory ??

LAB_ECDF:
    LDA   #$01          ;set the sector count
    STA   $7f96         ;save the sector count


;***********************************************************************************;
;
; read <n> sector(s) to memory ??

LAB_ECE4:
    JSR   LAB_EBA0
    BNE   LAB_ED38      ;if there was any error just exit

LAB_ECE9:
    JSR   LAB_EBCE      ;seek to track with retries ??
    BNE   LAB_ED38

LAB_ECEE:
    LDA   #$0A
    STA   $7f8c
LAB_ECF3:
    LDA   #$DE          ;mask xx0x xxx0,
                        ;x          drive not ready
                        ;x         write protected
                        ;x       record not found
                        ;x     CRC error
                        ;x    lost data
                        ;x   data request
    STA   $7f90         ;save the WD1793 status byte mask

    LDA   $7f93         ;get the WD1793 sector number
    BEQ   LAB_ED33      ;if zero go do disk error $40

    STA   LAB_E982      ;save the WD1793 sector register

    LDA   #$88          ;set read single sector command, side 1
    JSR   LAB_ECC0      ;write a WD1793 command and wait a bit
LAB_ED05:
    LDA   LAB_E980      ;get the WD1793 status register
    AND   #$16          ;mask 000x 0xx0,
                        ;x       record not found
                        ;x    lost data
                        ;x   data request
    BEQ   LAB_ED05      ;if no data request or error go try again

    LDA   LAB_E983      ;read the WD1793 data register
    STA   (LAB_B7),Y    ;save the byte to memory
    INY                 ;increment the index
    DEX                 ;decrement the count
    BNE   LAB_ED05      ;loop if more to do

    JSR   LAB_ECD0      ;wait for WD1793 not busy and mask the status
    BNE   LAB_ED2E      ;if any bits set go ??

    DEC   $7f96         ;deccrement the sector count
    BEQ   LAB_ED38      ;if all done just exit

    JSR   LAB_EC69      ;increment pointers to the next sector ??
    BCS   LAB_ED38      ;if error just exit

    LDA   $7f92         ;get the WD1793 track number
    CMP   LAB_E981      ;WD1793 track register
    BEQ   LAB_ECEE

    BNE   LAB_ECE9

LAB_ED2E:
    DEC   $7f8c
    BNE   LAB_ECF3

; do disk error $40

LAB_ED33:
    LDA   #$40
    JMP   LAB_EC96      ;do "DISK ERROR" message and ??

; no error exit

LAB_ED38:
    CLI                 ;enable interrupts
    RTS


;***********************************************************************************;
;
; write one sector to disk ??

;LAB_ED3A:
    LDA   #$01          ;set a single sector
    STA   $7f96         ;save the sector count


;***********************************************************************************;
;
; write <n> sector(s) to disk ??

LAB_ED3F:
    JSR   LAB_EBA0
    BNE   LAB_ED38

LAB_ED44:
    JSR   LAB_EBCE      ;seek to track with retries ??
    BNE   LAB_ED38

    LDA   LAB_E980      ;get the WD1793 status register
    AND   #$40          ;mask 0x00 0000, write protected
    BNE   LAB_EDA7      ;if write protected go do "PROTECTED!" message and exit

LAB_ED50:
    LDA   #$0A
    STA   $7f8c
LAB_ED55:
    LDA   #$FC          ;mask xxxx xx00,
                        ;x          drive not ready
                        ;x         write protected
                        ;x        write fault
                        ;x       record not found
                        ;x     CRC error
                        ;x    lost data
    STA   $7f90         ;save the WD1793 status byte mask

    LDA   $7f93         ;get the WD1793 sector number
    BEQ   LAB_EDA2      ;if zero go do disk error $50

    STA   LAB_E982      ;save the WD1793 sector register
    LDA   #$A8          ;set write single sector command, side 1
    JSR   LAB_ECC0      ;write a WD1793 command and wait a bit
LAB_ED67:
    LDA   LAB_E980      ;get the WD1793 status register
    AND   #$D6          ;mask xx0x 0xx0,
                        ;x          drive not ready
                        ;x         write protected
                        ;x       record not found
                        ;x    lost data
                        ;x   data request
    BEQ   LAB_ED67      ;if no flags set go wait some more

    CMP   #$02          ;compare it with data request
    BEQ   LAB_ED7B      ;if data request go send the next byte

    BNE   LAB_ED84      ;else go handle everything else, branch always

LAB_ED74:
    LDA   LAB_E980      ;get the WD1793 status register
    AND   #$96          ;mask x00x 0xx0,
                        ;x          drive not ready
                        ;x       record not found
                        ;x    lost data
                        ;x   data request
    BEQ   LAB_ED74      ;if no flags set go wait some more

LAB_ED7B:
    LDA   (LAB_B7),Y    ;get a byte from memory
    STA   LAB_E983      ;write the WD1793 data register
    INY                 ;inccrement the index
    DEX                 ;decrement the byte count
    BNE   LAB_ED74      ;loop if more to do

LAB_ED84:
    JSR   LAB_ECD0      ;wait for WD1793 not busy and mask the status
    BNE   LAB_ED9D      ;if any bits set go ??

    DEC   $7f96         ;deccrement the sector count
    BEQ   LAB_ED38      ;if all done just exit

    JSR   LAB_EC69      ;increment pointers to the next sector ??
    BCS   LAB_ED38      ;if error just exit

    LDA   $7f92         ;get the WD1793 track number
    CMP   LAB_E981      ;WD1793 track register
    BEQ   LAB_ED50

    BNE   LAB_ED44

LAB_ED9D:
    DEC   $7f8c
    BNE   LAB_ED55

; do disk error $50

LAB_EDA2:
    LDA   #$50          ;set disk error $50
    JMP   LAB_EC96      ;do "DISK ERROR" message and ??


;***********************************************************************************;
;
; do "PROTECTED!" message

LAB_EDA7:
    LDA   #<LAB_EDB1    ;set the message pointer low byte
    LDY   #>LAB_EDB1    ;set the message pointer high byte
    JSR   LAB_EFE7      ;message out
    CLC
    BCC   LAB_EDA2      ;do disk error $50, branch always


;***********************************************************************************;
;
; "PROTECTED!" message

LAB_EDB1:
    !byte $0D
    !text "PROTECTED!"
    !byte $00           ;end marker


;***********************************************************************************;
;
; ??

LAB_EDBD:
    JSR   LAB_0070      ;get the next BASIC byte
    CMP   #$22
    PHP
    BNE   LAB_EDD3

    JSR   LAB_0070      ;get the next BASIC byte
    LDA   LAB_77
    STA   $24
    LDA   LAB_78
    STA   $25
    JMP   LAB_EDEA

LAB_EDD3:
    JSR   LAB_C12B      ;find variable
    BIT   $07
    BMI   LAB_EDDF

    LDA   #$03


;***********************************************************************************;
;
; ??

LAB_EDDC:
    JMP   LAB_EC8E

LAB_EDDF:
    LDY   #$01
    LDA   ($44),Y
    STA   $24
    INY
    LDA   ($44),Y
    STA   $25


;***********************************************************************************;
;
; ??

LAB_EDEA:
    LDY   #$00
LAB_EDEC:
    LDA   ($24),Y
    CMP   #$3A
    BEQ   LAB_EE01

    CPY   #$06
    BCC   LAB_EDFB

LAB_EDF6:
    LDA   #$04
    JMP   LAB_EDDC

LAB_EDFB:
    STA   $7fa0,Y
    INY
    BPL   LAB_EDEC

LAB_EE01:
    TYA
    TAX
    LDA   #$20
LAB_EE05:
    CPX   #$06
    BCS   LAB_EE0F

    STA   $7fa0,X
    INX
    BPL   LAB_EE05

LAB_EE0F:
    INY
    LDA   ($24   ),Y
    AND   #$03
    TAX
    LDA   LAB_EA2F,X
    STA   $7fb1
    PLP
    BNE   LAB_EE32

    TYA
    CLC
    ADC   LAB_77
    STA   LAB_77
    BCC   LAB_EE28

    INC   LAB_78
LAB_EE28:
    JSR   LAB_0070      ;get the next BASIC byte
    CMP   #$22
    BNE   LAB_EDF6

    JSR   LAB_0070      ;get the next BASIC byte
LAB_EE32:
    RTS


;***********************************************************************************;
;
; ??

LAB_EE33:
    LDA   $7fb1
    STA   $7f91         ;save the drive number ??
    LDY   #$00
    STY   $7f92         ;save the WD1793 track number
    INY
    STY   $7f93         ;save the WD1793 sector number
    LDA   #$00
    STA   LAB_B7        ;save the memory pointer low byte
    LDA   #$7F
    STA   LAB_B8        ;save the memory pointer high byte
    STA   $23
    JSR   LAB_ECDF      ;read one sector to memory ??
    BNE   LAB_EE94

    LDA   $7f09
    STA   $56
    LDA   $7f0a
    STA   $57
    LDA   #$10
LAB_EE5D:
    STA   $22
LAB_EE5F:
    LDY   #$00
    LDA   ($22),Y
    CMP   #$FF
    BEQ   LAB_EE95


;***********************************************************************************;
;
; ??

LAB_EE67:
    CMP   $7fa0,Y
    BNE   LAB_EE76

    INY
    CPY   #$06
    BPL   LAB_EE92

    LDA   ($22),Y
    JMP   LAB_EE67

LAB_EE76:
    LDA   $22
    CLC
    ADC   #$10
    STA   $22
    BPL   LAB_EE5F

    INC   $7f93         ;increment the WD1793 sector number
    LDA   $7f93         ;get the WD1793 sector number
    CMP   #$09
    BPL   LAB_EE95

    JSR   LAB_ECDF      ;read one sector to memory ??
    BNE   LAB_EE94

    LDA   #$00
    BEQ   LAB_EE5D

LAB_EE92:
    LDA   #$00
LAB_EE94:
    RTS

LAB_EE95:
    LDA   #$7F
    RTS


;***********************************************************************************;
;
; LOAD ??

LAB_EE98:
    JSR   LAB_EE9E
    JMP   LAB_EB5E


;***********************************************************************************;
;
; ??

LAB_EE9E:
    JSR   LAB_EE33
    TAX
    BNE   LAB_EEE6

    LDY   #$0A
    LDA   ($22),Y
    CMP   #$03
    BMI   LAB_EEE6

    BNE   LAB_EEBE

    LDY   #$06
    LDA   ($22   ),Y
    CLC
    ADC   $28
    STA   $2a
    INY
    LDA   ($22   ),Y
    ADC   $29
    STA   $2b
LAB_EEBE:
    LDY   #$08
    LDA   ($22),Y
    STA   LAB_B7        ;save the memory pointer low byte
    INY
    LDA   ($22),Y
    STA   LAB_B8        ;save the memory pointer high byte
    LDY   #$0C
    LDA   ($22),Y
    STA   $7f92         ;save the WD1793 track number
    INY
    LDA   ($22),Y
    STA   $7f93         ;save the WD1793 sector number
    INY
    LDA   ($22),Y
    STA   $7f96         ;save the sector count
    JSR   LAB_ECE4      ;read <n> sector(s) to memory ??
    BNE   LAB_EEF0

    LDX   #$00
LAB_EEE3:
    JMP   LAB_EB0B      ;deselect the drives and stop the motors ??

; output "??????"

LAB_EEE6:
    LDX   #$06          ;set the "?" count
    LDA   #$3F          ;set "?"
LAB_EEEA:
    JSR   LAB_FFD2      ;do character out
    DEX                 ;decrement the count
    BNE   LAB_EEEA      ;loop if more to do

LAB_EEF0:
    LDX   #$FF
    BNE   LAB_EEE3      ;branch always


;***********************************************************************************;
;
; monitor prompt

LAB_EEF4:
    !byte $0D
    !text "ADDR?"
    !byte $00           ;end marker


;***********************************************************************************;
;
; get a hex address into $66   /67

LAB_EEFB:
    PHA                 ;save A
    TYA                 ;copy Y
    PHA                 ;save Y

    LDA   #<LAB_EEF4    ;set the message pointer low byte
    LDY   #>LAB_EEF4    ;set the message pointer high byte
    JSR   LAB_EFE7      ;message out

    PLA                 ;pull Y
    TAY                 ;restore Y
    PLA                 ;restore A
LAB_EF08:
    JSR   LAB_EF1B      ;get and evaluate a hex byte
    BCS   LAB_EF08      ;if error get another byte

    STA   $67           ;save the address high byte
    JSR   LAB_EF1B      ;get and evaluate a hex byte
    STA   $66           ;save the address low byte
    BCC   LAB_EF2E      ;if no error just exit

    JSR   LAB_EF2F
    BCS   LAB_EF08      ;go get another word


;***********************************************************************************;
;
; get and evaluate a hex byte

LAB_EF1B:
    JSR   LAB_EF41      ;get and evaluate a hex character


;***********************************************************************************;
;
; get and evaluate a hex byte second character

LAB_EF1E:
    BCS   LAB_EF32      ;if not hex go output a "?"

    ASL                 ;shift the ..
    ASL                 ;.. low nibble ..
    ASL                 ;.. to the ..
    ASL                 ;.. high nibble
    STA   $26
    JSR   LAB_EF41      ;get and evaluate a hex character
    BCS   LAB_EF2F

    ORA   $26           ;OR it with the high nibble
    CLC                 ;flag ok
LAB_EF2E:
    RTS


;***********************************************************************************;
;
; ??

LAB_EF2F:
    JSR   LAB_EF32


;***********************************************************************************;
;
; ??

LAB_EF32:
    LDA   #$3F          ;set "?"
    JSR   LAB_FFD2      ;do character out
    LDA   #$9D
    JSR   LAB_FFD2      ;do character out
    JSR   LAB_FFD2      ;do character out
LAB_EF3F:
    SEC                 ;flag error
    RTS


;***********************************************************************************;
;
; get and evaluate a hex character

LAB_EF41:
    JSR   LAB_EF59      ;get a character and ??


;***********************************************************************************;
;
; test and evaluate a hex digit

LAB_EF44:
    CMP   #'0'          ;compare the charater with "0"
    BCC   LAB_EF3F      ;if < "0" go return non hex

    CMP   #'9'+1        ;compare the charater with "9"+1
    BCC   LAB_EF54      ;if < "9"+1 go evaluate the hex digit

    CMP   #'A'          ;compare the charater with "A"
    BCC   LAB_EF3F      ;if < "A" go return non hex

    CMP   #'F'+1        ;compare the charater with "F"+1
    BCS   LAB_EF3F      ;if >= "F"+1 go return non hex

; evaluate the hex digit

LAB_EF54:
    JSR   LAB_D78D      ;evaluate a hex digit
    CLC                 ;flag a hex digit
LAB_EF58:
    RTS


;***********************************************************************************;
;
; get a character and ??

LAB_EF59:
    TXA                 ;copy X
    PHA                 ;save X
    TYA                 ;copy Y
    PHA                 ;save Y

    LDA   #$E6
    JSR   LAB_FFD2      ;do character out
    LDA   #$9D
    JSR   LAB_FFD2      ;do character out

    JSR   LAB_EF7B      ;wait for and echo a character
    STA   $7f88         ;save the charater

    PLA                 ;pull Y
    TAY                 ;restore Y
    PLA                 ;pull X
    TAX                 ;restore X

    LDA   $7f88         ;restore the charater
    CMP   #$03          ;compare it with ??
    BNE   LAB_EF58      ;if ?? just exit

    JMP   $7a00


;***********************************************************************************;
;
; wait for and echo a character

LAB_EF7B:
    JSR   LAB_FFE4      ;do character in
    BEQ   LAB_EF7B      ;if no character just wait

    JMP   LAB_FFD2      ;do character out


;***********************************************************************************;
;
; ??

LAB_EF83:
    JSR   LAB_EEFB      ;get a hex address into $66   /67
LAB_EF86:
    LDA   #$0D          ;set [CR]
    JSR   LAB_FFD2      ;do character out

    LDA   $67           ;get the address high byte
    JSR   LAB_EB7F      ;output [SPACE] <A> as a two digit hex Byte
    LDA   $66           ;get the address low byte
    JSR   LAB_EB84      ;output A as a two digit hex Byte

    LDY   #$00          ;clear the index
LAB_EF97:
    LDA   ($66),Y       ;get a byte from memory
    JSR   LAB_EB7F      ;output [SPACE] <A> as a two digit hex Byte
    INY                 ;increment the index
    CPY   #$08          ;compare it with max + 1
    BMI   LAB_EF97      ;loop if more to do

    LDA   #$0D          ;set [CR]
    JSR   LAB_FFD2      ;do character out
    LDX   #$06          ;set the [SPACE] count
LAB_EFA8:
    JSR   LAB_EB7A      ;output a [SPACE] character
    DEX                 ;decrement the [SPACE] count
    BNE   LAB_EFA8      ;loop if more to do

LAB_EFAE:
    STX   $27           ;save the line index
    JSR   LAB_EF59      ;get a character and ??
    CMP   #$0D          ;compare it with [CR]
    BEQ   LAB_EF83      ;if [CR] go get another hex address

    CMP   #$20          ;compare it with [SPACE]
    BNE   LAB_EFC0      ;if not [SPACE] go evaluate a hex digit

    JSR   LAB_EB7A      ;output a [SPACE] character
    BNE   LAB_EFD0      ;go increment the address, branch always

LAB_EFC0:
    JSR   LAB_EF44      ;test and evaluate a hex digit
    JSR   LAB_EF1E      ;get and evaluate a hex byte second character
    BCS   LAB_EFAE      ;if error go ??

    LDY   #$00          ;clear the index
    STA   ($66),Y       ;save the byte
    CMP   ($66),Y       ;compare the byte with the saved copy
    BNE   LAB_EFE2      ;if not the same go ??

; the byte saved or [SPACE] was returned

LAB_EFD0:
    JSR   LAB_EB7A      ;output a [SPACE] character
    INC   $66           ;inrement the address low byte
    BNE   LAB_EFD9      ;if no rollover skip the high byte increment

    INC   $67           ;else increment the high byte
LAB_EFD9:
    LDX   $27           ;get the line index
    INX                 ;inccrement it
    CPX   #$08          ;compare it with max + 1
    BMI   LAB_EFAE      ;if not there yet go ??

    BPL   LAB_EF86      ;else ??, branch always

; the byte didn't save to memory correctly

LAB_EFE2:
    JSR   LAB_EF2F
    BCS   LAB_EF86      ;branch always


;***********************************************************************************;
;
; message out

LAB_EFE7:
    STA   $6c           ;save the message pointer low byte
    STY   $6d           ;save the message pointer high byte
    LDY   #$FF          ;set -1 for pre increment
LAB_EFED:
    INY                 ;increment the index
    LDA   ($6c),Y       ;get the next character
    BEQ   LAB_EFF8      ;if it's the end marker just exit

    JSR   LAB_FFD2      ;do character out
    CLC                 ;clear carry
    BCC   LAB_EFED      ;go do the next character, branch always

LAB_EFF8:
    RTS


;***********************************************************************************;
;
; unused ??

;LAB_EFF9:
    !byte $68,$07,$01,$2B,$FF,$09,$5E

;***********************************************************************************;
