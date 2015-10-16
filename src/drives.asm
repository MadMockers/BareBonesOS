
drive_irq:
    IFE J, 0x0000
        SET PC, .getcount
    SET B, [Z]
    IFL B, [drive_count]
        SET PC, .valid
    SET PC, POP

.valid:
    IFE J, 0x0001
        SET PC, .getstatus
    IFE J, 0x0002
        SET PC, .getparam
    IFE J, 0x0003
        SET PC, .read
    IFE J, 0x0004
        SET PC, .write
    SET PC, POP

.getcount:
    SET [Z], [drive_count]
    SET PC, POP

.getstatus:
    SET A, 0
    HWI B
    SHL B, 8
    BOR B, C
    SET [Z], B
    SET PC, POP

.getparam:
    SET A, [Z+1]
    SET [A+DRIVE_SECT_SIZE], 512
    SET [A+DRIVE_SECT_COUNT], 1440
    SET PC, POP

.read:
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
    SET PC, .wait

.write:
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
    ; SET PC, .wait ; fall through right below

.wait:
    SET A, 0
    SET PUSH, B
        HWI [B]
    SET B, POP
    IFE C, 1
        SET PC, .wait
    SET [Z], 0
    IFE C, 0
        SET [Z], 1
    SET PC, POP

