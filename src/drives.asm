
#include "drives/m35fd.asm"

init_drive:
    SET PC, POP

drive_irq:
    IFE J, 0x0000
        SET PC, .getcount
    SET B, [Z+0]
    IFL B, [drive_class+CLASS_COUNT]
        SET PC, .valid
    SET PC, POP

.valid:
    ADD B, [drive_class+CLASS_ARRAY]
    SET B, [B]
    SET C, [B+HW_INTERFACE]
    SET B, [B+HW_PORT]

    IFE J, 0x0001
        SET PC, [C+DRIVE_ITF_GETSTATUS]
    IFE J, 0x0002
        SET PC, [C+DRIVE_ITF_GETPARAM]
    IFE J, 0x0003
        SET PC, [C+DRIVE_ITF_READ]
    IFE J, 0x0004
        SET PC, [C+DRIVE_ITF_WRITE]
    SET PC, POP

.getcount:
    SET [Z+0], [drive_class+CLASS_COUNT]
    SET PC, POP

