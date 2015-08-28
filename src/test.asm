
.loop:
    SET A, 0x3001
    PUSH 1
        INT BBOS_IRQ_MAGIC
    POP B
    BOR B, 0xF000

    SET A, 0x1003
    PUSH B
        JSR irq_handler_jsr
        ;INT BBOS_IRQ_MAGIC
    ADD SP, 1

    SET A, 0x1002
    SUB SP, 2
        INT BBOS_IRQ_MAGIC
    POP X
    POP Y

    ADD Y, 1
    IFN Y, 10
        SET PC, .no_scroll

    SET A, 0x1005
    PUSH 1
        INT BBOS_IRQ_MAGIC
    ADD SP, 1
    SUB Y, 1
.no_scroll:

    SET A, 0x1001
    PUSH X
    PUSH Y
        INT BBOS_IRQ_MAGIC
    ADD SP, 2
    SET PC, .loop
