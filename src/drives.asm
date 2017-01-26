
#include "drives/m35fd.asm"

drive_irq:
    IFE J, 0x0000
        SET PC, .getcount
    SET B, [Z+0]
    IFL B, [drive_count]
        SET PC, .valid
    SET PC, POP

.valid:
    SET PUSH, B
    SET B, [drive_count]
    SUB B, POP
    SUB B, 1

    MUL B, DRIVE_SIZE
    ADD B, [drive_array]

    SET C, [B+DRIVE_INTERFACE]
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
    SET [Z+0], [drive_count]
    SET PC, POP

