dir_ptr = $22
hex_save_a = $26
edit_ptr = $66
chrget = $70
L7857 = $7857
L7C00 = $7C00
L7C11 = $7C11
filename = $7fa0
latch = $e900
l_ead1 = $EAD1
l_ec0d = $EC0D
write_a_sector = $ED3A
find_file = $EE33
load_file = $EE9E
not_found = $EEE6
l_eefb = $EEFB
l_ef08 = $EF08
l_ef59 = $EF59
edit_memory = $EF83
puts = $EFE7
chrin = $FFCF
chrout = $FFD2

    *=$7a00

    lda #$93
    jsr chrout
L7A05:
    ldx #$FF
    txs
    lda #$00
    sta latch
    lda #$0D
    jsr chrout
    jsr chrout
    lda #'>'
    jsr chrout
    jsr l_ef59
    cmp #'A'
    bcc L7A25
    cmp #'Z'+1
    bcc L7A2B
L7A25:
    jsr not_found
    jmp L7A05
L7A2B:
    cmp #'L'            ;L-LOAD DISK PROGRAM
    beq jmp_load_prog
    cmp #'S'            ;S-SAVE A PROGRAM
    beq jmp_save_prog
    cmp #'M'            ;M-MEMORY ALTER
    beq jmp_edit_memory
    cmp #'R'            ;R-RE-ENTER BASIC
    beq reenter_basic
    cmp #'G'            ;G-GO TO MEMORY
    beq jmp_goto_memory
    cmp #'X'            ;X-EXECUTE DISK FILE
    beq jmp_exec_file
    cmp #'K'            ;K-KILL A FILE
    beq jmp_kill_file
    jsr external_cmd
    txa
    bne L7A05
    jmp L7C00

jmp_kill_file:
    jmp kill_file
jmp_load_prog:
    jmp load_prog
jmp_save_prog:
    jmp save_prog
jmp_edit_memory:
    jmp edit_memory
jmp_goto_memory:
    jmp goto_memory
jmp_exec_file:
    jmp exec_file

L7A62:
    !text $0d,"FILE? ",0
L7A6A:
    !text $0d,"DEVICE? ",0
L7A74:
    !text $0d,"ENTRY? ",0

reenter_basic:
    jsr chrget
    lda #$EB
    pha
    lda #$5D
    pha
    jmp l_ead1

external_cmd:
    pha
    lda #'*'
    ldy #$00
L7A8E:
    sta filename,y
    iny
    cpy #$05
    bmi L7A8E
    pla
    sta filename+$05
    ldy #$01
    sty $7FB1
    jsr load_file
    rts
L7AA3:
    lda #<L7A62
    ldy #>L7A62
    jsr puts
    ldy #$00
L7AAC:
    jsr chrin
    cmp #':'
    beq L7ABB
    sta filename,y
    iny
    cpy #$07
    bmi L7AAC
L7ABB:
    lda #' '
L7ABD:
    cpy #$06
    bpl L7AC7
    sta filename,y
    iny
    bne L7ABD
L7AC7:
    jsr chrin
    jsr L7ADB
    sta $7FB1
    rts
L7AD1:
    lda #<L7A6A
    ldy #>L7A6A
    jsr puts
    jsr l_ef59
L7ADB:
    cmp #'0'
    bmi L7AD1
    cmp #'3'
    bpl L7AD1
    and #$03
    tax
    lda $EA2F,x
    rts

load_prog:
    jsr L7AF0
    jmp L7A05

L7AF0:
    jsr L7AA3
    jsr load_file
    txa
    bne L7B11
    ldy #$0A
    lda (dir_ptr),y
    cmp #$05
    beq L7B04
    jmp L7A25
L7B04:
    ldy #$06
    lda (dir_ptr),y
    sta edit_ptr
    iny
    lda (dir_ptr),y
    sta edit_ptr+1
    lda #$00
L7B11:
    rts

exec_file:
    jsr L7AF0
    bne L7B25
    jmp L7B22

goto_memory:
    lda #$0D
    jsr chrout
    jsr l_eefb
L7B22:
    jsr L7B28
L7B25:
    jmp L7A05
L7B28:
    jmp (edit_ptr)

save_prog:
    jsr L7AA3
    lda #$0D
    jsr chrout
    jsr l_eefb
    lda edit_ptr
    sta filename+$08
    lda edit_ptr+1
    sta filename+$09
    lda #'-'
    jsr chrout
    jsr l_ef08
    lda edit_ptr
    clc
    adc #$7F
    php
    sec
    sbc filename+$08
    sta hex_save_a
    lda edit_ptr+1
    sbc filename+$09
    plp
    adc #$00
    asl hex_save_a
    rol ;a
    sta filename+$0e
    lda #$00
    sta filename+$0f
    lda #<L7A74
    ldy #>L7A74
    jsr puts
    jsr l_ef08
    lda #$0D
    jsr chrout
    lda edit_ptr
    sta filename+$06
    lda edit_ptr+1
    sta filename+$07
    lda #$05
    sta filename+$0a
    jsr find_file
    bmi L7B90
    tax
    beq L7BE2
    jsr L7857
L7B90:
    jmp L7A05

kill_file:
    lda #<L7BB4
    ldy #>L7BB4
    jsr puts
    jsr L7AA3
    jsr find_file
    tax
    bmi L7BAE
    bne L7BB1
    lda #$FF
    ldy #$05
    sta (dir_ptr),y
    jsr write_a_sector
L7BAE:
    jmp L7A05
L7BB1:
    jmp L7A25

L7BB4:
    !text $0d,"** DELETE-",0
L7BC0:
    !text $0d,"DUPLICATE FILE NAME-CANNOT SAVE",$0d,0

L7BE2:
    lda #<L7BC0
    ldy #>L7BC0
    jsr puts
    jmp L7A05

    cmp $E981
    bne L7BF2
    rts
L7BF2:
    lda #$03
    jsr l_ec0d
    dec $7F8C
    bne $7BD3
    lda #$10
    !byte $2C
    !byte $A9
