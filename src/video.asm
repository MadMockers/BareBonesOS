
video_irq:
    IFE J, 0x0000
        SET PC, .attached
    IFE [display_port], 0xFFFF
        SET PC, POP

    IFE J, 0x0001
        SET PC, .setcursor
    IFE J, 0x0002
        SET PC, .getcursor
    IFE J, 0x0003
        SET PC, .writechar
    IFE J, 0x0004
        SET PC, .writestring
    IFE J, 0x0005
        SET PC, .scrollscreen
    SET PC, POP

.attached:
    SET [Z], 1
    IFE [display_port], 0xFFFF
        SET [Z], 0
    SET PC, POP

.setcursor:
    SET A, [Z+0]
    MUL A, 32
    ADD A, [Z+1]
    IFL A, vram_end-vram_edit
        SET [vram_cursor], A
    SET PC, POP

.getcursor:
    SET A, [vram_cursor]
    SET [Z], A
    MOD [Z], 32
    SET [Z+1], A
    DIV [Z+1], 32
    SET PC, POP

.writechar:
    SET A, vram_edit
    ADD A, [vram_cursor]
    SET B, [Z]
    AND B, 0xFF00
    IFE B, 0
        BOR [Z], 0xF000
    SET [A], [Z]
    SET PC, .updatescreen

.writestring:
    SET A, [Z]
    JSR strlen

    ; calculate if string will fit in buffer
    SET C, [vram_cursor]
    SUB C, vram_end-vram_edit-32

    IFL A, C
        SET PC, .writestring_copy

    SET B, A
    SUB B, C
    ; b = number of lines to scroll
    DIV B, 32
    SET PUSH, B
        JSR scrollscreen
    ADD SP, 1

.writestring_copy:
    SET A, vram_edit
    SET B, [vram_cursor]
    ADD A, B
    ADD B, 32
    IFG B, vram_end-vram_edit-1
        SET B, vram_end-vram_edit-1
    SET [vram_cursor], B
    SET B, [Z]
.writestring_top:
    IFE [B], 0
        SET PC, .updatescreen
    SET C, [B]
    IFC C, 0xFF00
        BOR C, 0xF000
    SET [A], C
    ADD B, 1
    ADD A, 1
    SET PC, .writestring_top

.scrollscreen:
    SET PUSH, [Z]
        JSR scrollscreen
    ADD SP, 1
    ; SET PC, .updatescreen ; fall through, right below

.updatescreen:
    SET A, 0
    SET B, vram
    HWI [display_port]
    SET PC, POP

