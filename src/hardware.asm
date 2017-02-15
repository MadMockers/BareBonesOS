
.define HW_DEF_ID_HI            0
.define HW_DEF_ID_LO            1
.define HW_DEF_VERSION          2
.define HW_DEF_CLASS            3
.define HW_DEF_INTERFACE        4
.define HW_DEF_SIZE             5

.define HW_CLASS_UNKNOWN        0
.define HW_CLASS_VIDEO          1
.define HW_CLASS_DRIVE          2
.define HW_CLASS_KEYBOARD       3
.define HW_CLASS_COUNT          4

.define CLASS_COUNT             0
.define CLASS_ARRAY             1
.define CLASS_SIZE              2

.define HW_CLASS                0
.define HW_INTERFACE            1
.define HW_PORT                 2
.define HW_CONTEXT              3
.define HW_SIZE                 4

hardware_def_array:
; Displays
.dat    0x7349, 0xf615, 0x1802, HW_CLASS_VIDEO, lem_interface       ; LEM1802
.dat    0x734d, 0xf615, 0x1802, HW_CLASS_VIDEO, lem_interface       ; LEM1802 (Alternative H/W ID)
.dat    0x774d, 0xf615, 0x1802, HW_CLASS_VIDEO, pixie_interface     ; PIXIE
; Storage
.dat    0x4fd5, 0x24c5, 0x000b, HW_CLASS_DRIVE, m35fd_interface     ; M35FD
; Keyboards
.dat    0x30cf, 0x7406, 0x0001, HW_CLASS_KEYBOARD, 0                ; Keyboard
.dat    0x30c1, 0x7406, 0x0001, HW_CLASS_KEYBOARD, 0                ; Keyboard (Alternative H/W ID)
hardware_def_array_end:

hardware_array:
.dat    0
hardware_count:
.dat    0

; array of classes, with labels for each one
hardware_classes:
unknown_class:
.reserve    CLASS_SIZE
video_class:
.reserve    CLASS_SIZE
drive_class:
.reserve    CLASS_SIZE
keyboard_class:
.reserve    CLASS_SIZE

detect_hardware:
    HWN Z

    SET I, Z
    MUL I, HW_SIZE
    SET PUSH, I
        JSR alloc
    SET [hardware_array], POP
    SET [hardware_count], Z

    SET I, 0

.detect_top:
        IFE I, Z
            SET PC, .detect_break

        HWQ I

        SET X, J
        JSR register_hardware
.detect_continue:
        ADD I, 1
        SET PC, .detect_top
.detect_break:

    JSR init_classes

    SET PC, POP

register_hardware:
    SET PUSH, J
        SET J, hardware_def_array

.register_top:
        IFE J, hardware_def_array_end
            SET PC, .register_break

        ; If we don't care about version...
        IFE [J+HW_DEF_VERSION], 0xFFFF
            SET C, 0xFFFF

        IFE A, [J+HW_DEF_ID_LO]
            IFE B, [J+HW_DEF_ID_HI]
                IFE C, [J+HW_DEF_VERSION]
                    SET PC, .found
.register_continue:
        ADD J, HW_DEF_SIZE
        SET PC, .register_top
.found:
        SET A, I
        MUL A, HW_SIZE
        ADD A, [hardware_array]

        SET [A+HW_CLASS], [J+HW_DEF_CLASS]
        SET [A+HW_INTERFACE], [J+HW_DEF_INTERFACE]
        SET [A+HW_PORT], I

        SET A, [J+HW_DEF_CLASS]
        MUL A, CLASS_SIZE
        ADD A, hardware_classes
        ADD [A+CLASS_COUNT], 1
.register_break:

    SET J, POP
    SET PC, POP

init_classes:
    SET A, hardware_classes
    SET B, CLASS_SIZE*HW_CLASS_COUNT
    ADD B, A

.alloc_top:
        IFE A, B
            SET PC, .alloc_break
        SET C, [A+CLASS_COUNT]
        IFE C, 0
            SET PC, .alloc_continue
        SET PUSH, C
            JSR alloc
        SET [A+CLASS_ARRAY], POP
.alloc_continue:
        ADD A, CLASS_SIZE
        SET PC, .alloc_top
.alloc_break:

    SET A, [hardware_array]
    SET B, [hardware_count]
    MUL B, HW_SIZE
    ADD B, A

    SET C, [hardware_classes]

.classify_top:
        IFE A, B
            SET PC, .classify_break
        SET X, [A+HW_CLASS]
        IFE X, 0 ; ignore unknown hardware
            SET PC, .classify_continue
        MUL X, CLASS_SIZE
        SET X, [X+hardware_classes+CLASS_ARRAY]
.find_free_top:
            IFE [X], 0
                SET PC, .find_free_break
.find_free_continue:
            ADD X, 1
            SET PC, .find_free_top
.find_free_break:
            SET [X], A
.classify_continue:
        ADD A, HW_SIZE
        SET PC, .classify_top
.classify_break:

    JSR init_video
    JSR init_drive
    JSR init_keyboard

    SET PC, POP

; Don't compile this in for now
.ifdef UNDEFINED
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
.endif
