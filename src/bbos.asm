
#include "bbos.inc.asm"

.define VERSION 0x0100

.define RUN_AT  0xF000

.define LEM_ID  0x7349f615
.define LEM_VER 0x1802
.define LEM_MFR 0x1c6c8b36
.define LEM_WID 32
.define LEM_HGT 12

.define VRAM_SIZE   384 ; LEM_WID * LEM_HGT

.define MAX_DRIVES  8

.define HID_CLASS           3
.define KEYBOARD_SUBCLASS   0

.define COMMS_CLASS         0xE
.define PARALLEL_SUBCLASS   0

.define DRIVE_PORT          0
.define DRIVE_INTERFACE     1
.define DRIVE_SIZE          2

.define DRIVE_ITF_GETSTATUS 0
.define DRIVE_ITF_GETPARAM  1
.define DRIVE_ITF_READ      2
.define DRIVE_ITF_WRITE     3
.define DRIVE_ITF_SIZE      4

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

    JSR find_display
    JSR find_drives
    JSR find_keyboard
    JSR find_hic

    IFE [drive_count], 0
        SET PC, .no_drives

.retry:
    SET B, 0
.loop_top:
    SET A, 0x2003
    SET PUSH, 0
    SET PUSH, 0
    SET PUSH, B
        INT BBOS_IRQ_MAGIC
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
    SET A, 0x1004
    SET PUSH, 1
        INT BBOS_IRQ_MAGIC
    ADD SP, 2
    SET A, 0x3000
    SET PUSH, 0
        INT BBOS_IRQ_MAGIC
    SET A, POP
    IFE A, 0
        SET PC, .die

    SET A, 0x1004
    SET PUSH, str_retry
    SET PUSH, 2
        INT BBOS_IRQ_MAGIC
    ADD SP, 2

    SET A, 0x3001
    SET PUSH, 1
        INT BBOS_IRQ_MAGIC
    ADD SP, 1
    SET PC, .retry
.no_drives:
    SET PUSH, str_no_drives
    SET A, 0x1004
    SET PUSH, 1
        INT BBOS_IRQ_MAGIC
    ADD SP, 2
.die:
    SET PC, .die

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
        AND J, 0x0FFF
        IFE X, 0x1000
            JSR video_irq
        IFE X, 0x2000
            JSR drive_irq
        IFE X, 0x3000
            JSR keyboard_irq
        IFE X, 0x4000
            JSR rtc_irq

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
    SET [bbos_info+BBOS_VERSION], VERSION
    SET [bbos_info+BBOS_START_ADDR], bbos_start-VRAM_SIZE
    SET [bbos_info+BBOS_END_ADDR], bbos_end
    SET [bbos_info+BBOS_INT_HANDLER], irq_handler
    SET [bbos_info+BBOS_API_HANDLER], irq_handler_jsr
    SET [Z+0], bbos_info
    SET PC, POP

#include "video.asm"
#include "drives.asm"
#include "keyboard.asm"
#include "rtc.asm"
#include "comms.asm"

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

; A: API
; Return
; A: Port (0xFFFF on fail)
;find_hw_api:
;    SET PUSH, X
;    SET PUSH, Y
;    SET PUSH, Z
;
;        SET I, A
;
;        HWN Z
;.loop_top:
;        SUB Z, 1
;        IFE Z, 0xFFFF
;            SET PC, .loop_break
;        HWQ Z
;
;        SHR B, 4
;        AND B, 0xF
;        IFE B, I
;            SET PC, .loop_break
;        SET PC, .loop_top
;.loop_break:
;        SET A, Z
;
;    SET Z, POP
;    SET Y, POP
;    SET X, POP
;    SET PC, POP

find_hic:
    SET A, COMMS_CLASS
    SET B, PARALLEL_SUBCLASS
    JSR find_hw_class
    SET [comms_port], A
    SET PC, POP

find_keyboard:
    SET A, HID_CLASS
    SET B, KEYBOARD_SUBCLASS
    JSR find_hw_class
    SET [keyboard_port], A
    SET PC, POP

find_display:
    ; find display
    SET PUSH, LEM_ID&0xFFFF
    SET PUSH, LEM_ID>>16
    SET PUSH, LEM_VER
    SET PUSH, LEM_MFR&0xFFFF
    SET PUSH, LEM_MFR>>16
        JSR find_hardware
    SET [display_port], POP
    ADD SP, 4

    ; Skip display init if no display
    IFE [display_port], 0xFFFF
        SET PC, POP

    SET A, 0
    SET B, vram
    HWI [display_port]
    
    SET A, 0x1004
    SET PUSH, boot_str1
    SET PUSH, 1
        INT BBOS_IRQ_MAGIC
    ADD SP, 2

    SET A, 0x1004
    SET PUSH, boot_str2
    SET PUSH, 1
        INT BBOS_IRQ_MAGIC
    ADD SP, 2
    SET PC, POP

find_drives:

    HWN Z

.loop_top:
    SUB Z, 1
    IFE Z, 0xFFFF
        SET PC, .loop_break
    HWQ Z

    JSR .get_drive_itf
    IFE J, 0
        SET PC, .loop_top
    ; drive found
    SET I, [drive_count]
    ADD [drive_count], 1
    MUL I, DRIVE_SIZE
    ADD I, drives
    SET [I+DRIVE_PORT], Z
    SET [I+DRIVE_INTERFACE], J
    IFL [drive_count], MAX_DRIVES
        SET PC, .loop_top
.loop_break:
    SET PC, POP

.get_drive_itf:
    ; check for M35FD
    SET J, 0
    IFE A, 0x24c5
        IFE B, 0x4fd5
            SET J, m35fd_interface
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
        MUL C, LEM_WID

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
        SET B, vram
        HWI [display_port]

    SET I, POP
    SET C, POP
    SET B, POP
    SET A, POP
    SET Z, POP
    SET PC, POP

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
.dat        0x204d
.dat        0x204d
.dat        0x2020
.dat        0x2053
.dat        0x206f
.dat        0x206c
.dat        0x2075
.dat        0x2074
.dat        0x2069
.dat        0x206f
.dat        0x206e
.dat        0x2073
.dat        0

bbos_info:
.reserve    BBOSINFO_SIZE

vram_cursor:
.dat        0
display_port:
.dat        0xFFFF

; support up to 8 drives
drives:
.reserve    16 ; MAX_DRIVES * DRIVE_SIZE
drive_count:
.dat        0

keyboard_port:
.dat        0

comms_port:
.dat        0

str_retry:
.asciiz "Press any key to retry"
str_no_boot:
.asciiz "No bootable media found"
str_no_drives:
.asciiz "No drives connected"


bbos_end:

boot_rom_end:

