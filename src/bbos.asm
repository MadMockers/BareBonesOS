
;.define RUN_TEST

#include "bbos.inc.asm"

.define VERSION                         0x0101

.define RUN_AT                          0xF000

.define LEM_ID                          0x7349f615
.define LEM_ID_ALT                      0x734df615
.define LEM_VER                         0x1802
.define LEM_MFR                         0x1c6c8b36

.define HID_CLASS                       3
.define KEYBOARD_SUBCLASS               0

.define COMMS_CLASS                     0xE
.define PARALLEL_SUBCLASS               0

.define DRIVE_PORT                      0
.define DRIVE_INTERFACE                 1
.define DRIVE_SIZE                      2

.define DRIVE_ITF_GETSTATUS             0
.define DRIVE_ITF_GETPARAM              1
.define DRIVE_ITF_READ                  2
.define DRIVE_ITF_WRITE                 3
.define DRIVE_ITF_SIZE                  4

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

.ifdef RUN_TEST
static_tests:
#include "../examples/test.asm"
.endif

boot_rom:

.org RUN_AT
bbos_start:
entry:
    SET SP, 0

    IAS irq_handler

    JSR detect_hardware

    SET A, BBOS_VID_WRITE_STRING
    SET PUSH, boot_str1
    SET PUSH, 1
        INT BBOS_IRQ_MAGIC
    ADD SP, 2

    SET A, BBOS_VID_WRITE_STRING
    SET PUSH, boot_str2
    SET PUSH, 1
        INT BBOS_IRQ_MAGIC
    ADD SP, 2

.ifdef RUN_TEST
    SET PC, static_tests
.endif

    IFE [drive_class+CLASS_COUNT], 0
        SET PC, .no_drives

.retry:
    SET B, 0
.loop_top:
    SET A, BBOS_DRV_READ_SECTOR
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
    IFL B, [drive_class+CLASS_COUNT]
        SET PC, .loop_top
.loop_break:
    SET PUSH, str_no_boot
    SET A, BBOS_VID_WRITE_STRING
    SET PUSH, 1
        INT BBOS_IRQ_MAGIC
    ADD SP, 2
    SET A, BBOS_KEY_ATTACHED
    SET PUSH, 0
        INT BBOS_IRQ_MAGIC
    SET A, POP
    IFE A, 0
        SET PC, .die

    SET A, BBOS_VID_WRITE_STRING
    SET PUSH, str_retry
    SET PUSH, 2
        INT BBOS_IRQ_MAGIC
    ADD SP, 2

    SET A, BBOS_KEY_READ_CHAR
    SET PUSH, 1
        INT BBOS_IRQ_MAGIC
    ADD SP, 1
    SET PC, .retry
.no_drives:
    SET PUSH, str_no_drives
    SET A, BBOS_VID_WRITE_STRING
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
            RFI ; 0

    SET PUSH, Z
    SET Z, SP
    ADD Z, 3
    SET PUSH, A
    SET PUSH, B
    SET PUSH, C
    SET PUSH, X
    SET PUSH, Y
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
    SET Y, POP
    SET X, POP
    SET C, POP
    SET B, POP
    SET A, POP
    SET Z, POP
    IFE A, 0x4743
        RFI ; 0
    SET A, POP
    SET PC, POP

.bbos_irq:
    SET [bbos_info+BBOS_VERSION], VERSION
    SET [bbos_info+BBOS_START_ADDR], [alloc_pos]
    SET [bbos_info+BBOS_END_ADDR], bbos_end
    SET [bbos_info+BBOS_INT_HANDLER], irq_handler
    SET [bbos_info+BBOS_API_HANDLER], irq_handler_jsr
    SET [Z+0], bbos_info
    SET PC, POP

#include "util.asm"
#include "hardware.asm"
#include "mem.asm"
#include "video.asm"
#include "drives.asm"
#include "keyboard.asm"
#include "rtc.asm"
#include "comms.asm"

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

str_retry:
.asciiz "Press any key to retry"
str_no_boot:
.asciiz "No bootable media found"
str_no_drives:
.asciiz "No drives connected"

bbos_end:

boot_rom_end:
