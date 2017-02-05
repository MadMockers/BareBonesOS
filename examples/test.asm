
; This test is designed to be launched by a bootloader.
; It is not capable if loading itself from floppy on its own.

#include "bbos.inc.asm"

test_entry:
    JSR video_tests
    JSR drive_tests
;    JSR keyboard_tests
;    JSR rtc_tests
    SET PUSH, str_tests_completed
        JSR user_confirm
    SET A, POP

    IFE A, 1
        SET PC, test_entry

done:
    SET PC, done

video_tests:
    ; test if display is present
    SET A, 0x1000
    SET PUSH, 0
        INT BBOS_IRQ_MAGIC
    SET B, POP
    IFE B, 0
        SET PC, POP

    SET A, 0x1008
    SET PUSH, 1
        INT BBOS_IRQ_MAGIC
    SET 0, POP

    SET PUSH, str_set_cursor
    SET PUSH, 1
        JSR write_string
    ADD SP, 2
    SET PUSH, str_get_cursor
    SET PUSH, 1
        JSR write_string
    ADD SP, 2

    ; Save cursor position
    SET A, 0x1002
    SUB SP, 2
        INT BBOS_IRQ_MAGIC

        ; Set cursor position
        SET A, 0x1001
        SET PUSH, 5
        SET PUSH, 5
            INT BBOS_IRQ_MAGIC
        ADD SP, 2

        SET A, 0x1002
        SUB SP, 2
            INT BBOS_IRQ_MAGIC
        SET X, POP
        SET Y, POP

        ; restore cursor
        SET A, 0x1001
        INT BBOS_IRQ_MAGIC
    ADD SP, 2

    SET A, str_fail
    IFE X, 5
        IFE Y, 5
            SET A, str_success
    SET PUSH, A
    SET PUSH, 1
        JSR write_string
    ADD SP, 2

    SET PUSH, str_write_char
    SET PUSH, 1
        JSR write_string
    ADD SP, 2

    SET A, 0x1003
    SET PUSH, 0x5A ; 'Z'
    SET PUSH, 0
        INT BBOS_IRQ_MAGIC
    ADD SP, 2


    SET B, str_success
.writechar_top:
    IFE [B], 0
        SET PC, .writechar_break
    SET PUSH, [B]
    SET PUSH, 1
        INT BBOS_IRQ_MAGIC
    ADD SP, 2
    ADD B, 1
    SET PC, .writechar_top
.writechar_break:

    SET PUSH, 0
    SET PUSH, SP
    SET PUSH, 1
        JSR write_string
    ADD SP, 3

    SET PUSH, str_scroll_screen
    SET PUSH, 1
        JSR write_string
    ADD SP, 2

    ; save cursor pos
    SUB SP, 2
        SET A, 0x1002
        INT BBOS_IRQ_MAGIC

        SET A, 0x1005
        SET PUSH, 1
            INT BBOS_IRQ_MAGIC
        ADD SP, 1

        SET A, 0x1001
        INT BBOS_IRQ_MAGIC
    ADD SP, 2

    SET PUSH, str_scroll_screen_confirm
        JSR user_confirm
    SET A, POP

    SET B, str_fail
    IFN A, 0
        SET B, str_success
    SET A, 0x1004
    SET PUSH, B
    SET PUSH, 1
        JSR write_string
    ADD SP, 2
        
    SET A, 0x1004
    SET PUSH, str_screen_size
    SET PUSH, 0
        INT BBOS_IRQ_MAGIC
    ADD SP, 2

    SET A, 0x1006
    SUB SP, 2
        INT BBOS_IRQ_MAGIC
        SET PUSH, 0
            JSR write_dec
        ADD SP, 2
        SET A, 0x1003
        SET PUSH, 0x78 ; 'x'
        SET PUSH, 1
            INT BBOS_IRQ_MAGIC
        ADD SP, 2
        SET PUSH 0
            JSR write_dec
    ADD SP, 2

    SET PUSH, 0
    SET PUSH, SP
    SET PUSH, 1
        JSR write_string
    ADD SP, 3

    SET PC, POP

drive_tests:
    SET A, 0x2000
    SUB SP, 1
        INT BBOS_IRQ_MAGIC
    SET B, POP

    SET PUSH, B
    SET PUSH, 0
        JSR write_dec
    ADD SP, 2
    SET PUSH, str_drives_connected
    SET PUSH, 1
        JSR write_string
    ADD SP, 2

    IFE B, 0
        SET PC, POP

    SET A, 0
.loop_top:
    SET PUSH, A
    SET PUSH, B
        JSR test_drive
    SET B, POP
    SET A, POP
    ADD A, 1
    IFE A, B
        SET PC, .loop_break
    SET PC, .loop_top
.loop_break:
    SET PC, POP

test_drive:
    SET Z, A    ; Z is our drive number

    SET PUSH, str_do_test1
    SET PUSH, 0
        JSR write_string
    ADD SP, 2
    SET PUSH, Z
    SET PUSH, 0
        JSR write_dec
    ADD SP, 2

    SET PUSH, str_do_test2
        JSR user_confirm
    SET B, POP

    IFE B, 1
        SET PC, .do_tests

    SET PUSH, str_skipping_drive
    SET PUSH, 1
        JSR write_string
    ADD SP, 2
    SET PC, POP

.do_tests:
    JSR write_drive_status

    SUB SP, DRIVEPARAM_SIZE
        SET A, 0x2002
        SET PUSH, SP
        SET PUSH, Z
            INT BBOS_IRQ_MAGIC
        ADD SP, 2
        SET B, SP
        SET PUSH, str_sector_count
        SET PUSH, 0
            JSR write_string
        ADD SP, 2
        SET PUSH, [B+DRIVE_SECT_COUNT]
        SET PUSH, 1
            JSR write_dec
        ADD SP, 2
        SET PUSH, str_sector_size
        SET PUSH, 0
            JSR write_string
        ADD SP, 2
        SET PUSH, [B+DRIVE_SECT_SIZE]
        SET PUSH, 1
            JSR write_dec
        ADD SP, 2
    ADD SP, DRIVEPARAM_SIZE

    SET PUSH, str_writing
    SET PUSH, 1
        JSR write_string
    ADD SP, 2

    SET A, 0x2004
    SET PUSH, 1000
    SET PUSH, 0
    SET PUSH, Z
        INT BBOS_IRQ_MAGIC
    ADD SP, 3

    JSR write_drive_status

    SET A, 0x2003
    SET PUSH, 1000
    SET PUSH, test_end+512
    SET PUSH, Z
        INT BBOS_IRQ_MAGIC
    ADD SP, 3

    JSR write_drive_status

    ; confirm the memory written matches the memory read
    SET A, 0
    SET B, test_end+512
.cmp_top:
    IFE A, 512
        SET PC, .read_write_success
    IFN [A], [B]
        SET PC, .read_write_fail
    ADD A, 1
    ADD B, 1
    SET PC, .cmp_top
.read_write_fail:
    SET PUSH, str_fail
    SET PUSH, 1
        JSR write_string
    ADD SP, 2
    SET PC, .ret
.read_write_success:
    SET PUSH, str_success
    SET PUSH, 1
        JSR write_string
    ADD SP, 2
.ret:
    SET PC, POP

write_drive_status:
    SET PUSH, A
    SET PUSH, B
    SET PUSH, C
        SET A, 0x2001
        SET PUSH, Z
            INT BBOS_IRQ_MAGIC
        SET B, POP
        SET C, B
        AND B, 0xFF
        SHR C, 8
        ; B = last error
        ; C = state

        SET PUSH, str_drive_state
        SET PUSH, 0
            JSR write_string
        ADD SP, 2
        SET PUSH, C
        SET PUSH, 1
            JSR write_hex
        ADD SP, 2
        SET PUSH, str_drive_last_error
        SET PUSH, 0
            JSR write_string
        ADD SP, 2
        SET PUSH, B
        SET PUSH, 1
            JSR write_hex
        ADD SP, 2
    SET C, POP
    SET B, POP
    SET A, POP
    SET PC, POP

; +1 String
; +0 NewLine
write_string:
    SET PUSH, A
        SET A, 0x1004
        SET PUSH, [SP+3]
        SET PUSH, [SP+3]
            INT BBOS_IRQ_MAGIC
        ADD SP, 2
    SET A, POP
    SET PC, POP

; +1 Value
; +0 NewLine
write_hex:
    SET PUSH, Z
    SET Z, SP
    ADD Z, 2
    SET PUSH, A

        SUB SP, 5
        SET PUSH, SP
        SET PUSH, [Z+1]
            JSR to_hex_str
          ADD SP, 1
          SET PUSH, [Z+0]
          JSR write_string
        ADD SP, 7

    SET A, POP
    SET Z, POP
    SET PC, POP

; +1 Value
; +0 NewLine
write_dec:
    SET PUSH, Z
    SET Z, SP
    ADD Z, 2
    SET PUSH, A

        SUB SP, 6
        SET PUSH, SP
        SET PUSH, [Z+1]
            JSR to_dec_str
          ADD SP, 1
          SET PUSH, [Z+0]
          JSR write_string
        ADD SP, 8

    SET A, POP
    SET Z, POP
    SET PC, POP

; +1 Ptr to 6 words
; +0 Value
; Returns
; Updates +1 to string
to_dec_str:
    SET PUSH, Z
    SET Z, SP
    ADD Z, 2
    SET PUSH, A
    SET PUSH, B
    SET PUSH, C

        SET A, [Z+1]
        SET B, [Z+0]
        SET [A+5], 0
        ADD A, 5

.loop_top:
        IFE B, 0
            IFN [A], 0
                SET PC, .loop_break

        SUB A, 1
        SET C, B
        MOD C, 10
        ADD C, 0x30 ; '0'
        SET [A], C

        DIV B, 10
        SET PC, .loop_top
.loop_break:
        SET [Z+1], A
    SET C, POP
    SET B, POP
    SET A, POP
    SET Z, POP
    SET PC, POP

; +1 Ptr to 5 words
; +0 Value
; Returns
; Updates +1 to string
to_hex_str:
    SET PUSH, Z
    SET Z, SP
    ADD Z, 2
    SET PUSH, A
    SET PUSH, B
    SET PUSH, C

        SET A, [Z+1]
        SET B, [Z+0]
        SET [A+4], 0
        ADD A, 4

.loop_top:
        IFE B, 0
            IFN [A], 0
                SET PC, .loop_break

        SUB A, 1
        SET C, B
        AND C, 0xF
        ADD C, 0x30 ; '0'
        IFG C, 0x39 ; '9'
            ADD C, 0x41-0x39 ; 'A'-'9'
        SET [A], C

        SHR B, 4
        SET PC, .loop_top
.loop_break:
        SET [Z+1], A

    SET C, POP
    SET B, POP
    SET A, POP
    SET Z, POP
    SET PC, POP

; +0 String to write
; Return
; +0 1 = yes, 0 = no
user_confirm:
    SET PUSH, Z
    SET Z, SP
    ADD Z, 2
    SET PUSH, A
    SET PUSH, B

        SET A, 0x1004
        SET PUSH, [Z+0]
        SET PUSH, 0
            INT BBOS_IRQ_MAGIC
        ADD SP, 2

        SET A, 0x3000
        SUB SP, 1
            INT BBOS_IRQ_MAGIC
        SET A, POP

        IFE A, 1
            SET PC, .has_keyboard

        ; write empty string for new line
        SET A, 0x1004
        SET PUSH, 0
        SET PUSH, SP
        SET PUSH, 1
            JSR write_string
        ADD SP, 3

        SET PUSH, str_no_keyboard
        SET PUSH, 1
            JSR write_string
        ADD SP, 2

        SET [Z+0], 0
        SET PC, .return

.has_keyboard:
        SET A, 0x3001
        SET PUSH, 1
            INT BBOS_IRQ_MAGIC
        SET B, POP

        SET A, 0x1003
        SET PUSH, B
        SET PUSH, 1
            INT BBOS_IRQ_MAGIC
        ADD SP, 2

        ; write empty string for new line
        SET A, 0x1004
        SET PUSH, 0
        SET PUSH, SP
        SET PUSH, 1
            JSR write_string
        ADD SP, 3

        SET A, 1
        IFN B, 0x59 ; 'Y'
            IFN B, 0x79 ; 'y'
                SET A, 0
        SET [Z+0], A
.return:

    SET B, POP
    SET A, POP
    SET Z, POP
    SET PC, POP

str_display_tests:
    .asciiz "Display Tests:"
str_set_cursor:
    .asciiz "Testing Set Cursor"
str_get_cursor:
    .asciiz "Testing Get Cursor"
str_write_char:
    .asciiz "Testing Write Char"
str_scroll_screen:
    .asciiz "Testing Scroll Screen"
str_scroll_screen_confirm:
    .asciiz "Has the screen scrolled up by 1 [y/n]? "
str_screen_size:
    .asciiz "Screen Size: "

str_drives_connected:
    .asciiz " drives connected."
str_do_test1:
    .asciiz "Test drive "
str_do_test2:
    .asciiz "? Testing will involve writing to sector 1,000 [y/n]: "
str_skipping_drive:
    .asciiz "Skipping drive."
str_drive_state:
    .asciiz "Drive State: 0x"
str_drive_last_error:
    .asciiz "Drive Last Error: 0x"
str_sector_count:
    .asciiz "Sector Count: "
str_sector_size:
    .asciiz "Sector Size: "
str_writing:
    .asciiz "Writing to sector 1,000"
str_reading:
    .asciiz "Reading from sector 1,000"

str_success:
    .asciiz "Success!"
str_fail:
    .asciiz "Fail!"
str_no_keyboard:
    .asciiz "No Keyboard, assuming 'N'!"

str_tests_completed:
    .asciiz "Testing has finished. Test again? [y/n] "

test_end:
