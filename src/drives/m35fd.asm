
m35fd_interface:
    DAT .getstatus
    DAT .getparam
    DAT .read
    DAT .write

.getstatus:
    SET A, 0
    HWI B
    SHL B, 8
    AND C, 0xFF
    BOR B, C
    SET [Z+0], B
    SET PC, POP

.getparam:
    SET A, [Z+1]
    SET [A+DRIVE_SECT_SIZE], 512
    SET [A+DRIVE_SECT_COUNT], 1440
    SET PC, POP

.read:
    SET PUSH, X
    SET PUSH, Y
        SET PUSH, B
            SET X, [Z+2]
            SET Y, [Z+1]
            SET A, 2
            HWI B
        SET B, POP
    SET Y, POP
    SET X, POP
    SET PC, .wait

.write:
    SET PUSH, X
    SET PUSH, Y
        SET PUSH, B
            SET X, [Z+2]
            SET Y, [Z+1]
            SET A, 3
            HWI B
        SET B, POP
    SET Y, POP
    SET X, POP
    ; SET PC, .wait ; fall through right below

.wait:
    SET A, 0
    SET PUSH, B
        HWI B
    SET A, B
    SET B, POP
    IFE A, DRIVE_STATE_BUSY
        SET PC, .wait
    SET [Z+0], 0
    IFE C, 0
        SET [Z+0], 1
    SET PC, POP
