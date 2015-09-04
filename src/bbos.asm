
#include "bbos.inc.asm"

.define RUN_AT  0xF000

.define LEM_ID  0x7349f615
.define LEM_VER 0x1802
.define LEM_MFR 0x1c6c8b36

.define HID_CLASS           3
.define KEYBOARD_SUBCLASS   0

.define MAX_DRIVES  8

.org RUN_AT
bbos_start:
SET PC, entry
vram:
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
.reserve    13
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
.reserve    19
vram_edit:
.reserve    320
vram_end:

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

entry:
    SET SP, 0

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

    JSR find_drives

    SET A, HID_CLASS
    SET B, KEYBOARD_SUBCLASS
    JSR find_hw_class
    SET [keyboard_port], A

    IAS irq_handler

    IFE [drive_count], 0
        SET PC, .no_drives

    SET B, 0
.loop_top:
    SET A, 0x2003
    PUSH 0
    PUSH 0
    PUSH B
        INT 0x4743
    POP A
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
    PUSH str_no_boot
    SET PC, .die
.no_drives:
    PUSH str_no_drives
.die:
    SET A, 0x1004
        INT BBOS_IRQ_MAGIC
    ADD SP, 1
.die_loop:
    SET PC, .die_loop

str_no_boot:
.asciiz "No bootable media found"
str_no_drives:
.asciiz "No drives connected"

jmp_to_bootloader:
    SET A, B    ; Set A to the drive we found the bootloader on
    SET SP, 0
    SET PC, 0

irq_handler_jsr:
    PUSH A
    SET A, 0x4744
irq_handler:
    IFN A, 0x4743
        IFN A, 0x4744
            RFI

    PUSH Z
    SET Z, SP
    ADD Z, 3
    PUSH A
    PUSH B
    PUSH C
    PUSH X
    PUSH J

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

    POP J
    POP X
    POP C
    POP B
    POP A
    POP Z
    IFE A, 0x4743
        RFI
    POP A
    RET

.bbos_irq:
    SET A, [Z]
    SET [Z+BBOS_START_ADDR], bbos_start
    SET [Z+BBOS_END_ADDR], bbos_end
    SET [Z+BBOS_INT_HANDLER], irq_handler
    SET [Z+BBOS_API_HANDLER], irq_handler_jsr
    RFI

.video_irq:
    IFE J, 0x1000
        SET PC, .video_irq_attached
    IFE [display_port], 0xFFFF
        RET

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
    RET

.video_irq_attached:
    SET [Z], 1
    IFE [display_port], 0xFFFF
        SET [Z], 0
    RET

.video_irq_setcursor:
    SET A, [Z+0]
    MUL A, 32
    ADD A, [Z+1]
    IFL A, vram_end-vram_edit
        SET [vram_cursor], A
    RET

.video_irq_getcursor:
    SET A, [vram_cursor]
    SET [Z], A
    MOD [Z], 32
    SET [Z+1], A
    DIV [Z+1], 32
    RET

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
    PUSH B
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
    PUSH [Z]
        JSR scrollscreen
    ADD SP, 1
    ; SET PC, .video_irq_updatescreen ; fall through, right below

.video_irq_updatescreen:
    SET A, 0
    SET B, vram
    HWI [display_port]
    RET

.drive_irq:
    IFE J, 0x2000
        SET PC, .drive_irq_getcount
    SET B, [Z]
    IFL B, [drive_count]
        SET PC, .drive_irq_valid
    RET

.drive_irq_valid:
    IFE J, 0x2001
        SET PC, .drive_irq_getstatus
    IFE J, 0x2002
        SET PC, .drive_irq_getparam
    IFE J, 0x2003
        SET PC, .drive_irq_read
    IFE J, 0x2004
        SET PC, .drive_irq_write
    RET

.drive_irq_getcount:
    SET [Z], [drive_count]
    RET

.drive_irq_getstatus:
    SET A, 0
    HWI B
    SHL B, 8
    BOR B, C
    SET [Z], B
    RET

.drive_irq_getparam:
    SET A, [Z+1]
    SET [A+DRIVE_SECT_SIZE], 512
    SET [A+DRIVE_SECT_COUNT], 1440
    RET

.drive_irq_read:
    PUSH X
    PUSH Y
        ADD B, drives
        PUSH B
            SET X, [Z+2]
            SET Y, [Z+1]
            SET A, 2
            HWI [B]
        POP B
    POP Y
    POP X
    SET PC, .drive_irq_wait

.drive_irq_write:
    PUSH X
    PUSH Y
        ADD B, drives
        PUSH B
            SET X, [Z+2]
            SET Y, [Z+1]
            SET A, 3
            HWI [B]
        POP B
    POP Y
    POP X
    ; SET PC, .drive_irq_wait ; fall through right below

.drive_irq_wait:
    SET A, 0
    PUSH B
        HWI [B]
    POP B
    IFE C, 1
        SET PC, .drive_irq_wait
    SET [Z], 0
    IFE C, 0
        SET [Z], 1
    RET

.keyboard_irq:
    IFE J, 0x3000
        SET PC, .keyboard_irq_attached
    IFE [keyboard_port], 0xFFFF
        RET

    IFE J, 0x3001
        SET PC, .keyboard_irq_readchar
    RET

.keyboard_irq_attached:
    SET [Z], 0
    IFN [keyboard_port], 0xFFFF
        SET [Z], 1
    RET

.keyboard_irq_readchar:
    SET A, 1
    HWI [keyboard_port]
    IFE C, 0
        IFE [Z], 1
            SET PC, .keyboard_irq_readchar
    SET [Z], C
    RET

.rtc_irq:
    ; no rtc at this time
    SET [Z], 0
    RET

; A: Class
; B: Subclass
; Return
; A: Port (0xFFFF on fail)
find_hw_class:
    PUSH X
    PUSH Y
    PUSH Z

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

    POP Z
    POP Y
    POP X
    RET

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
    RET

.is_drive:
    ; check for M35FD
    SET I, 0
    IFE A, 0x24c5
        IFE B, 0x4fd5
            SET I, 1
    RET

; +2 dest
; +1 src
; +0 len
memmove:
    PUSH Z
    SET Z, SP
    ADD Z, 2
    PUSH I
    PUSH J
    PUSH C

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
        PUSH I
            SUB C, 1
            ADD I, C
            ADD J, C
        POP C
.bkwd_top:
        STD [I], [J]
        IFE I, C
            SET PC, .done
        SET PC, .bkwd_top

.done:
    POP C
    POP J
    POP I
    POP Z
    RET

; +0 Line Count
; Returns
; None
scrollscreen:
    push z
    set z, sp
    add z, 2
    push a
    push b
    push c
    push i

        set b, vram_edit

        set c, [z+0]
        mul c, 32

        sub [vram_cursor], c
        ifg [vram_cursor], vram_end-vram_edit-1
            set [vram_cursor], 0

        set i, c
        add i, b

        push b
        push i
        push vram_end-vram_edit
        sub [sp], c
            jsr memmove
        add sp, 3

        add b, vram_end-vram_edit
        push b
            sub b, c
        pop c

.clear_top:
        ife b, c
            set pc, .clear_break
        set [b], 0
        add b, 1
        set pc, .clear_top
.clear_break:

        set a, 0
        hwi [display_port]

    pop i
    pop c
    pop b
    pop a
    pop z
    ret

; +4: HW ID Lo
; +3: HW ID Hi
; +2: Version
; +1: MFR ID Lo
; +0: MFR ID Hi
; Returns
; +0: HW Port Number
find_hardware:
    set push, z
    set z, sp
    add z, 2
    set push, a
    set push, b
    set push, c
    set push, y
    set push, x
    set push, i

        hwn i

.loop_top:
        sub i, 1

        hwq i
        ife a, [z+4]
            ife b, [z+3]
                ife c, [z+2],
                    ife x, [z+1]
                        ife y, [z+0]
                            set pc, .found
        ife i, 0
            set pc, .break_fail
        set pc, .loop_top
.found:
        set [z+0], i
        set pc, .ret
.break_fail:
        set [z+0], 0xFFFF
.ret:
    set i, pop
    set x, pop
    set y, pop
    set c, pop
    set b, pop
    set a, pop
    set z, pop

    set pc, pop

; A: str
; Return
; A: len
strlen:
    PUSH A
.loop_top:
        IFE [A], 0
            SET PC, .loop_break
        ADD A, 1
        SET PC, .loop_top
.loop_break:
    SUB A, POP
    RET

bbos_end:
