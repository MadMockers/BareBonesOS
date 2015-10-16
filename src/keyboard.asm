
keyboard_irq:
    IFE J, 0x0000
        SET PC, .attached
    IFE [keyboard_port], 0xFFFF
        SET PC, POP

    IFE J, 0x0001
        SET PC, .readchar
    SET PC, POP

.attached:
    SET [Z], 0
    IFN [keyboard_port], 0xFFFF
        SET [Z], 1
    SET PC, POP

.readchar:
    SET A, 1
    HWI [keyboard_port]
    IFE C, 0
        IFE [Z], 1
            SET PC, .readchar
    SET [Z], C
    SET PC, POP

