
#include "bbos.inc.asm"

.define RUN_AT  0xF000

.define LEM_ID  0x7349f615
.define LEM_VER 0x1802
.define LEM_MFR 0x1c6c8b36

.define HID_CLASS           3
.define KEYBOARD_SUBCLASS   0

.define MAX_DRIVES  8

.define VRAM_SIZE   384

zero:
    SET I, boot_rom
    SET J, bbos_start
    SET A, bbos_end-bbos_start

cpy_top:
    SUB A, 1
    STI [J], [I]
    IFN A, 0
        SET PC, cpy_top
    SET PC, bbos_start
boot_rom:

.org RUN_AT-VRAM_SIZE
vram:
vram_edit:
.org RUN_AT
vram_end:
bbos_start:
entry:
    SET SP, 0

    IAS irq_handler

    ; find display
    SET PUSH, LEM_ID&0xFFFF
    SET PUSH, LEM_ID>>16
    SET PUSH, LEM_VER
    SET PUSH, LEM_MFR&0xFFFF
    SET PUSH, LEM_MFR>>16
        JSR find_hardware
    SET [display_port], POP
    ADD SP, 4
    SET A, 0
    SET B, vram
    HWI [display_port]
    
    SET A, 0x1004
    SET PUSH, boot_str1
        INT BBOS_IRQ_MAGIC
    ADD SP, 1

    SET A, 0x1004
    SET PUSH, boot_str2
        INT BBOS_IRQ_MAGIC
    ADD SP, 1

    JSR find_drives

    SET A, HID_CLASS
    SET B, KEYBOARD_SUBCLASS
    JSR find_hw_class
    SET [keyboard_port], A

    IFE [drive_count], 0
        SET PC, .no_drives

    SET B, 0
.loop_top:
    SET A, 0x2003
    SET PUSH, 0
    SET PUSH, 0
    SET PUSH, B
        INT 0x4743
    SET A, POP
    ADD SP, 2
    IFN A, 1
        SET PC, .loop_continue
    IFE [0x1FF], 0x55AA
        SET PC, jmp_to_bootloader
.loop_continue:
    ADD B, 1
    IFL B, [drive_count]
        SET PC, .loop_top
.loop_break:
    SET PUSH, str_no_boot
    SET PC, .die
.no_drives:
    SET PUSH, str_no_drives
.die:
    SET A, 0x1004
        INT BBOS_IRQ_MAGIC
    ADD SP, 1
.die_loop:
    SET PC, .die_loop

jmp_to_bootloader:
    SET A, B    ; Set A to the drive we found the bootloader on
    SET SP, 0
    SET PC, 0

irq_handler_jsr:
    SET PUSH, A
    SET A, 0x4744
irq_handler:
    IFN A, 0x4743
        IFN A, 0x4744
            RFI

    SET PUSH, Z
    SET Z, SP
    ADD Z, 3
    SET PUSH, A
    SET PUSH, B
    SET PUSH, C
    SET PUSH, X
    SET PUSH, J

        SET J, [Z-2]
        IFE J, 0x0000
            JSR .bbos_irq
        SET X, J
        AND X, 0xF000
        IFE X, 0x1000
            JSR .video_irq
        IFE X, 0x2000
            JSR .drive_irq
        IFE X, 0x3000
            JSR .keyboard_irq
        IFE X, 0x4000
            JSR .rtc_irq

    SET J, POP
    SET X, POP
    SET C, POP
    SET B, POP
    SET A, POP
    SET Z, POP
    IFE A, 0x4743
        RFI
    SET A, POP
    SET PC, POP

.bbos_irq:
    SET A, [Z]
    SET [A+BBOS_START_ADDR], bbos_start-VRAM_SIZE
    SET [A+BBOS_END_ADDR], bbos_end
    SET [A+BBOS_INT_HANDLER], irq_handler
    SET [A+BBOS_API_HANDLER], irq_handler_jsr
    SET PC, POP

.video_irq:
    IFE J, 0x1000
        SET PC, .video_irq_attached
    IFE [display_port], 0xFFFF
        SET PC, POP

    IFE J, 0x1001
        SET PC, .video_irq_setcursor
    IFE J, 0x1002
        SET PC, .video_irq_getcursor
    IFE J, 0x1003
        SET PC, .video_irq_writechar
    IFE J, 0x1004
        SET PC, .video_irq_writestring
    IFE J, 0x1005
        SET PC, .video_irq_scrollscreen
    SET PC, POP

.video_irq_attached:
    SET [Z], 1
    IFE [display_port], 0xFFFF
        SET [Z], 0
    SET PC, POP

.video_irq_setcursor:
    SET A, [Z+0]
    MUL A, 32
    ADD A, [Z+1]
    IFL A, vram_end-vram_edit
        SET [vram_cursor], A
    SET PC, POP

.video_irq_getcursor:
    SET A, [vram_cursor]
    SET [Z], A
    MOD [Z], 32
    SET [Z+1], A
    DIV [Z+1], 32
    SET PC, POP

.video_irq_writechar:
    SET A, vram_edit
    ADD A, [vram_cursor]
    SET B, [Z]
    AND B, 0xFF00
    IFE B, 0
        BOR [Z], 0xF000
    SET [A], [Z]
    SET PC, .video_irq_updatescreen

.video_irq_writestring:
    SET A, [Z]
    JSR strlen

    ; calculate if string will fit in buffer
    SET C, [vram_cursor]
    SUB C, vram_end-vram_edit-32

    IFL A, C
        SET PC, .video_irq_writestring_copy

    SET B, A
    SUB B, C
    ; b = number of lines to scroll
    DIV B, 32
    SET PUSH, B
        JSR scrollscreen
    ADD SP, 1

.video_irq_writestring_copy:
    SET A, vram_edit
    SET B, [vram_cursor]
    ADD A, B
    ADD B, 32
    IFG B, vram_end-vram_edit-1
        SET B, vram_end-vram_edit-1
    SET [vram_cursor], B
    SET B, [Z]
.video_irq_writestring_top:
    IFE [B], 0
        SET PC, .video_irq_updatescreen
    SET C, [B]
    IFC C, 0xFF00
        BOR C, 0xF000
    SET [A], C
    ADD B, 1
    ADD A, 1
    SET PC, .video_irq_writestring_top

.video_irq_scrollscreen:
    SET PUSH, [Z]
        JSR scrollscreen
    ADD SP, 1
    ; SET PC, .video_irq_updatescreen ; fall through, right below

.video_irq_updatescreen:
    SET A, 0
    SET B, vram
    HWI [display_port]
    SET PC, POP

.drive_irq:
    IFE J, 0x2000
        SET PC, .drive_irq_getcount
    SET B, [Z]
    IFL B, [drive_count]
        SET PC, .drive_irq_valid
    SET PC, POP

.drive_irq_valid:
    IFE J, 0x2001
        SET PC, .drive_irq_getstatus
    IFE J, 0x2002
        SET PC, .drive_irq_getparam
    IFE J, 0x2003
        SET PC, .drive_irq_read
    IFE J, 0x2004
        SET PC, .drive_irq_write
    SET PC, POP

.drive_irq_getcount:
    SET [Z], [drive_count]
    SET PC, POP

.drive_irq_getstatus:
    SET A, 0
    HWI B
    SHL B, 8
    BOR B, C
    SET [Z], B
    SET PC, POP

.drive_irq_getparam:
    SET A, [Z+1]
    SET [A+DRIVE_SECT_SIZE], 512
    SET [A+DRIVE_SECT_COUNT], 1440
    SET PC, POP

.drive_irq_read:
    SET PUSH, X
    SET PUSH, Y
        ADD B, drives
        SET PUSH, B
            SET X, [Z+2]
            SET Y, [Z+1]
            SET A, 2
            HWI [B]
        SET B, POP
    SET Y, POP
    SET X, POP
    SET PC, .drive_irq_wait

.drive_irq_write:
    SET PUSH, X
    SET PUSH, Y
        ADD B, drives
        SET PUSH, B
            SET X, [Z+2]
            SET Y, [Z+1]
            SET A, 3
            HWI [B]
        SET B, POP
    SET Y, POP
    SET X, POP
    ; SET PC, .drive_irq_wait ; fall through right below

.drive_irq_wait:
    SET A, 0
    SET PUSH, B
        HWI [B]
    SET B, POP
    IFE C, 1
        SET PC, .drive_irq_wait
    SET [Z], 0
    IFE C, 0
        SET [Z], 1
    SET PC, POP

.keyboard_irq:
    IFE J, 0x3000
        SET PC, .keyboard_irq_attached
    IFE [keyboard_port], 0xFFFF
        SET PC, POP

    IFE J, 0x3001
        SET PC, .keyboard_irq_readchar
    SET PC, POP

.keyboard_irq_attached:
    SET [Z], 0
    IFN [keyboard_port], 0xFFFF
        SET [Z], 1
    SET PC, POP

.keyboard_irq_readchar:
    SET A, 1
    HWI [keyboard_port]
    IFE C, 0
        IFE [Z], 1
            SET PC, .keyboard_irq_readchar
    SET [Z], C
    SET PC, POP

.rtc_irq:
    ; no rtc at this time
    SET [Z], 0
    SET PC, POP

; A: Class
; B: Subclass
; Return
; A: Port (0xFFFF on fail)
find_hw_class:
    SET PUSH, X
    SET PUSH, Y
    SET PUSH, Z

        SET I, A
        SHL I, 4
        BOR I, B

        HWN Z
.loop_top:
        SUB Z, 1
        IFE Z, 0xFFFF
            SET PC, .loop_break
        HWQ Z

        SHR B, 8
        IFE B, I
            SET PC, .loop_break
        SET PC, .loop_top
.loop_break:
        SET A, Z

    SET Z, POP
    SET Y, POP
    SET X, POP
    SET PC, POP

find_drives:

    HWN Z

.loop_top:
    SUB Z, 1
    IFE Z, 0xFFFF
        SET PC, .loop_break
    HWQ Z

    JSR .is_drive
    IFE I, 0
        SET PC, .loop_top
    ; drive found
    SET I, [drive_count]
    ADD [drive_count], 1
    ADD I, drives
    SET [I], Z
    IFL [drive_count], MAX_DRIVES
        SET PC, .loop_top
.loop_break:
    SET PC, POP

.is_drive:
    ; check for M35FD
    SET I, 0
    IFE A, 0x24c5
        IFE B, 0x4fd5
            SET I, 1
    SET PC, POP

; +2 dest
; +1 src
; +0 len
memmove:
    SET PUSH, Z
    SET Z, SP
    ADD Z, 2
    SET PUSH, I
    SET PUSH, J
    SET PUSH, C

        SET I, [Z+2]
        SET J, [Z+1]
        SET C, [Z+0]

        IFE C, 0
            SET PC, .done
        IFL I, J
            SET PC, .fwd
        IFG I, J
            SET PC, .bkwd
        SET PC, .done

.fwd:
        ADD C, I
.fwd_top:
        IFE I, C
            SET PC, .done
        STI [I], [J]
        SET PC, .fwd_top

.bkwd:
        SET PUSH, I
            SUB C, 1
            ADD I, C
            ADD J, C
        SET C, POP
.bkwd_top:
        STD [I], [J]
        IFE I, C
            SET PC, .done
        SET PC, .bkwd_top

.done:
    SET C, POP
    SET J, POP
    SET I, POP
    SET Z, POP
    SET PC, POP

; +0 Line Count
; Returns
; None
scrollscreen:
    SET PUSH,  Z
    SET Z, SP
    ADD Z, 2
    SET PUSH,  A
    SET PUSH,  B
    SET PUSH,  C
    SET PUSH,  I

        SET B, vram_edit

        SET C, [Z+0]
        MUL C, 32

        SUB [vram_cursor], C
        IFG [vram_cursor], vram_end-vram_edit-1
            SET [vram_cursor], 0

        SET I, C
        ADD I, B

        SET PUSH,  B
        SET PUSH,  I
        SET PUSH,  vram_end-vram_edit
        SUB [SP], C
            JSR memmove
        ADD SP, 3

        ADD B, vram_end-vram_edit
        SET PUSH,  B
            SUB B, C
        SET C, POP

.clear_top:
        IFE B, C
            SET PC, .clear_break
        SET [B], 0
        ADD B, 1
        SET PC, .clear_top
.clear_break:

        SET A, 0
        HWI [display_port]

    SET I, POP
    SET C, POP
    SET B, POP
    SET A, POP
    SET Z, POP
    RET

; +4: HW ID Lo
; +3: HW ID Hi
; +2: Version
; +1: MFR ID Lo
; +0: MFR ID Hi
; Returns
; +0: HW Port Number
find_hardware:
    SET PUSH, Z
    SET Z, SP
    ADD Z, 2
    SET PUSH, A
    SET PUSH, B
    SET PUSH, C
    SET PUSH, Y
    SET PUSH, X
    SET PUSH, I

        HWN I

.loop_top:
        SUB I, 1

        HWQ I
        IFE A, [Z+4]
            IFE B, [Z+3]
                IFE C, [Z+2],
                    IFE X, [Z+1]
                        IFE Y, [Z+0]
                            SET PC, .found
        IFE I, 0
            SET PC, .break_fail
        SET PC, .loop_top
.found:
        SET [Z+0], I
        SET PC, .ret
.break_fail:
        SET [Z+0], 0xFFFF
.ret:
    SET I, POP
    SET X, POP
    SET Y, POP
    SET C, POP
    SET B, POP
    SET A, POP
    SET Z, POP

    SET PC, POP

; A: str
; Return
; A: len
strlen:
    SET PUSH, A
.loop_top:
        IFE [A], 0
            SET PC, .loop_break
        ADD A, 1
        SET PC, .loop_top
.loop_break:
    SUB A, POP
    SET PC, POP

boot_str1:
.dat        0x4042
.dat        0x4061
.dat        0x4072
.dat        0x4065
.dat        0x4042
.dat        0x406F
.dat        0x406E
.dat        0x4065
.dat        0x4073
.dat        0x4020
.dat        0x404F
.dat        0x4053
.dat        0x4020
.dat        0x4028
.dat        0x4042
.dat        0x4042
.dat        0x404F
.dat        0x4053
.dat        0x4029
.dat        0
boot_str2:
.dat        0x2042
.dat        0x2079
.dat        0x2020
.dat        0x204D
.dat        0x2061
.dat        0x2064
.dat        0x204D
.dat        0x206F
.dat        0x2063
.dat        0x206B
.dat        0x2065
.dat        0x2072
.dat        0x2073
.dat        0

vram_cursor:
.dat        0
display_port:
.dat        0xFFFF

; support up to 8 drives
drives:
.reserve    MAX_DRIVES
drive_count:
.dat        0

keyboard_port:
.dat        0

str_no_boot:
.asciiz "No bootable media found"
str_no_drives:
.asciiz "No drives connected"


bbos_end:

boot_rom_end:

