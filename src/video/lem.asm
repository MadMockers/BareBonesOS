
; the width and height are all hardcoded here, as they don't vary

.define _LEM_WID    32
.define _LEM_HGT    12

lem_interface:
    DAT .required_mem
    DAT .get_dimensions
    DAT .writechar
    DAT .writestring
    DAT .scrollscreen
    DAT .flush
    DAT .activate

pixie_interface:
    DAT .required_mem
    DAT .get_dimensions
    DAT .writechar
    DAT .writestring
    DAT .scrollscreen
    DAT .flush
    DAT .pixie_activate

; +0 HW
; Returns
; +0 Memory
.required_mem:
    SET [SP+1], 384
    SET PC, pop

; LEM has fixed dimensions
; +0 HW
; Returns
; +0 Width
; +1 Height
.get_dimensions:
    SET [SP+1], _LEM_WID
    SET [SP+2], _LEM_HGT
    SET PC, POP

.writechar:
    SET A, [X+DISPLAY_EDIT_START]
    ADD A, [X+DISPLAY_CURSOR]
    IFC [Z+1], 0xFF00
        BOR [Z+1], 0xF000
    SET [A], [Z+1]

    SET B, [X+DISPLAY_CURSOR_MAX]
    IFE [Z+0], 1
        IFL [X+DISPLAY_CURSOR], B
            ADD [X+DISPLAY_CURSOR], 1
    SET PC, .flush

.writestring:
    SET A, [Z+1]
    JSR strlen

    SET B, A
    IFE [Z+0], 0
        SET PC, .writestring_no_newline
    ; if 0 length, force round up
    IFE A, 0
        ADD B, 1

    ; round B up to nearest LEM_WID
    ADD B, _LEM_WID-1
    DIV B, _LEM_WID
    MUL B, _LEM_WID
.writestring_no_newline:

    ; calculate if string will fit in buffer
    SET C, [X+DISPLAY_CURSOR_MAX]
    SUB C, 1
    SUB C, [X+DISPLAY_CURSOR]

    IFL B, C
        SET PC, .writestring_update_cursor

    ; get cursor X position
    SET PUSH, A
        SET A, [X+DISPLAY_CURSOR]
        MOD A, _LEM_WID

        ; B = x position after write (ignoring wrapping)
        ADD B, A
    SET A, POP

    ; B = number of lines to scroll
    DIV B, _LEM_WID
    SET PUSH, B
        JSR .scrollscreen_impl
    ADD SP, 1

.writestring_update_cursor:
    SET C, [X+DISPLAY_CURSOR]
    SET B, C

    ; Set B to new cursor position
    ; A is still strlen
    ADD B, A

    IFE [Z+0], 0
        SET PC, .writestring_update_cursor_no_newline
    ; round B up to nearest _LEM_WID
    ADD B, _LEM_WID-1
    DIV B, _LEM_WID
    MUL B, _LEM_WID
.writestring_update_cursor_no_newline:

    ; sanitize cursor position
    IFG B, [X+DISPLAY_CURSOR_MAX]
        SET B, [X+DISPLAY_CURSOR_MAX]
    SET [X+DISPLAY_CURSOR], B

.writestring_copy:
    ; set A to VRAM write pointer
    SET A, [X+DISPLAY_EDIT_START]
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
        JSR .scrollscreen_impl
    ADD SP, 1
    SET PC, .flush

; +0 Line Count
; Returns
; None
.scrollscreen_impl:
    SET PUSH, Z
    SET Z, SP
    ADD Z, 2
    SET PUSH, A
    SET PUSH, B
    SET PUSH, C
    SET PUSH, X
    SET PUSH, I
    SET PUSH, J

        SET J, [active_display]
        SET J, [J+HW_CONTEXT]

        ; X: Size of editable section
        SET X, [J+DISPLAY_CURSOR_MAX]
        ADD X, 1

        ; B: start of editable section
        SET B, [J+DISPLAY_EDIT_START]

        ; C: Distance to move vram
        SET C, [Z+0]
        MUL C, _LEM_WID

        SUB [J+DISPLAY_CURSOR], C
        IFG [J+DISPLAY_CURSOR], [J+DISPLAY_CURSOR_MAX]
            SET [J+DISPLAY_CURSOR], 0

        ; I: New top of screen
        SET I, C
        ADD I, B

        ; Destination is the start of the editable section
        SET PUSH, B
        ; Source is the new top of screen
        SET PUSH, I
        ; Amount is the size of editable section (X) subtract distance moved (C)
        SET PUSH, X
        SUB [SP], C
            JSR memmove
        ADD SP, 3

        ; Start 0ing from start of edit section (X) + size of edit section (B) - distance moved (C)
        ADD B, X
        SET PUSH, B
            SUB B, C
        SET C, POP

        ; C: End if editable section
        ; B: Current idx
.clear_top:
        IFE B, C
            SET PC, .clear_break
        SET [B], 0
        ADD B, 1
        SET PC, .clear_top
.clear_break:

    SET J, POP
    SET I, POP
    SET X, POP
    SET C, POP
    SET B, POP
    SET A, POP
    SET Z, POP
    SET PC, POP

.flush:
.updatescreen:
    SET PC, POP

.activate:
    SET PUSH, A
    SET PUSH, B
    SET PUSH, C
    SET PUSH, X

        SET C, [SP+5]
        SET X, [C+HW_CONTEXT]
        SET C, [C+HW_PORT]

        ; Change display to LEM mode
        SET A, 16
        SET B, 0
        HWI C

        ; Set the VRAM location
        SET A, 0
        SET B, [X+DISPLAY_MEM_START]
        HWI C

    SET X, POP
    SET C, POP
    SET B, POP
    SET A, POP

    SET PC, POP

.pixie_activate:
    SET PUSH, A
    SET PUSH, B
    SET PUSH, C
    SET PUSH, X

        SET C, [SP+5]
        SET X, [C+HW_CONTEXT]
        SET C, [C+HW_PORT]

        ; Change display to LEM mode
        SET A, 16
        SET B, 0
        HWI C

        ; Set the VRAM location
        SET A, 0
        SET B, [X+DISPLAY_MEM_START]
        HWI C

    SET X, POP
    SET C, POP
    SET B, POP
    SET A, POP

    SET PC, POP
