
; Only support a single keyboard for now
keyboard_port:
.dat    0

init_keyboard:
    IFE [keyboard_class+CLASS_COUNT], 0
        SET PC, POP

    SET A, [keyboard_class+CLASS_ARRAY]
    SET A, [A]
    SET [keyboard_port], [A+HW_PORT]
    SET PC, POP

keyboard_irq:
    IFE J, 0x0000
        SET PC, .attached
    IFE [keyboard_port], 0xFFFF
        SET PC, POP

    IFE J, 0x0001
        SET PC, .readchar
    SET PC, POP

.attached:
    SET [Z+0], 0
    IFN [keyboard_port], 0xFFFF
        SET [Z+0], 1
    SET PC, POP

.readchar:
    SET A, 1
    HWI [keyboard_port]
    IFE C, 0
        IFE [Z+0], 1
            SET PC, .readchar
    SET [Z+0], C
    SET PC, POP

