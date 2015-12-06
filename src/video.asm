
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
    IFE J, 0x0006
        SET PC, .getsize

    SET PC, POP

.attached:
    SET [Z+0], 1
    IFE [display_port], 0xFFFF
        SET [Z+0], 0
    SET PC, POP

.setcursor:
    SET A, [Z+0]
    MUL A, LEM_WID
    ADD A, [Z+1]
    IFL A, vram_end-vram_edit
        SET [vram_cursor], A
    SET PC, POP

.getcursor:
    SET A, [vram_cursor]
    SET [Z+1], A
    MOD [Z+1], LEM_WID
    SET [Z+0], A
    DIV [Z+0], LEM_WID
    SET PC, POP

.writechar:
    SET A, vram_edit
    ADD A, [vram_cursor]
    IFC [Z+1], 0xFF00
        BOR [Z+1], 0xF000
    SET [A], [Z+1]
    IFE [Z+0], 1
        IFL [vram_cursor], vram_end-vram_edit-1
            ADD [vram_cursor], 1
    SET PC, .updatescreen

.writestring:
    SET A, [Z+1]
    JSR strlen

    ; calculate if string will fit in buffer
    SET C, vram_end-vram_edit
    SUB C, [vram_cursor]

    SET B, A
    IFE [Z+0], 0
        SET PC, .writestring_no_newline
    ; if 0 length, force round up
    IFE A, 0
        ADD B, 1

    ; round B up to nearest LEM_WID
    ADD B, LEM_WID-1
    DIV B, LEM_WID
    MUL B, LEM_WID
.writestring_no_newline:

    IFL B, C
        SET PC, .writestring_update_cursor

    ; get cursor X position
    SET X, [vram_cursor]
    MOD X, LEM_WID

    ; B = x position after write (ignoring wrapping)
    ADD B, X

    ; B = number of lines to scroll
    DIV B, LEM_WID
    SET PUSH, B
        JSR scrollscreen
    ADD SP, 1

.writestring_update_cursor:
    SET C, [vram_cursor]
    SET B, C

    ; Set B to new cursor position
    ; A is still strlen
    ADD B, A

    IFE [Z+0], 0
        SET PC, .writestring_update_cursor_no_newline
    ; round B up to nearest LEM_WID
    ADD B, LEM_WID-1
    DIV B, LEM_WID
    MUL B, LEM_WID
.writestring_update_cursor_no_newline:

    ; sanitize cursor position
    IFG B, vram_end-vram_edit-1
        SET B, vram_end-vram_edit-1
    SET [vram_cursor], B

.writestring_copy:
    ; set A to VRAM write pointer
    SET A, vram_edit
    ; C is still vram_cursor (before update)
    ADD A, C

    SET B, [Z+1]
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
    SET PUSH, [Z+0]
        JSR scrollscreen
    ADD SP, 1
;    SET PC, .updatescreen

.updatescreen:
    SET A, 0
    SET B, vram
    HWI [display_port]
    SET PC, POP

.getsize:
    SET [Z+0], LEM_WID
    SET [Z+1], LEM_HGT
    SET PC, POP

