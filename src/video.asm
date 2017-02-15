
.define DISPLAY_MEM_START               0
.define DISPLAY_EDIT_START              1
.define DISPLAY_MEM_END                 2
.define DISPLAY_CURSOR                  3
.define DISPLAY_CURSOR_MAX              4
.define DISPLAY_WIDTH                   5
.define DISPLAY_HEIGHT                  6
.define DISPLAY_SIZE                    7

.define DISPLAY_ITF_REQUIRED_MEM        0
.define DISPLAY_ITF_GET_DIMENSIONS      1
.define DISPLAY_ITF_WRITE_CHAR          2
.define DISPLAY_ITF_WRITE_STRING        3
.define DISPLAY_ITF_SCROLL_SCREEN       4
.define DISPLAY_ITF_FLUSH               5
.define DISPLAY_ITF_ACTIVATE            6
.define DISPLAY_ITF_SIZE                7

#include "video/lem.asm"

active_display:
.dat        0

init_video:
    ; Check if there's anything to initialize
    IFE [video_class+CLASS_COUNT], 0
        SET PC, POP
    SET PUSH, Z
    SET Z, SP
    ADD Z, 2
    SET PUSH, A
    SET PUSH, B
    SET PUSH, C
    SET PUSH, X
    SET PUSH, Y

        SET A, [video_class+CLASS_ARRAY]
        SET B, [video_class+CLASS_COUNT]
        ADD B, A

        SET [active_display], [A]

.init_top:
            IFE A, B
                SET PC, .init_break

            ; C: HW struct
            SET C, [A]

            SET PUSH, A
            SET PUSH, B
                ; X: DISPLAY_ITF struct
                SET X, [C+HW_INTERFACE]

                SET PUSH, DISPLAY_SIZE
                    JSR alloc
                ; Y: DISPLAY struct
                SET Y, POP

                SET PUSH, 0
                SET PUSH, C
                    JSR [X+DISPLAY_ITF_GET_DIMENSIONS]
                SET [Y+DISPLAY_HEIGHT], POP
                SET [Y+DISPLAY_WIDTH], POP

                SET PUSH, C
                    JSR [X+DISPLAY_ITF_REQUIRED_MEM]
                    ; A: required mem
                    SET A, [SP]
                    JSR alloc
                ; B: VRAM
                SET B, POP

                SET [Y+DISPLAY_MEM_START], B
                SET [Y+DISPLAY_EDIT_START], B
                ADD B, A
                SET [Y+DISPLAY_MEM_END], B
                SET A, [Y+DISPLAY_WIDTH]
                MUL A, [Y+DISPLAY_HEIGHT]
                SUB A, 1
                SET [Y+DISPLAY_CURSOR_MAX], A

                SET [C+HW_CONTEXT], Y

            SET B, POP
            SET A, POP
.init_continue:
            ADD A, 1
            SET PC, .init_top
.init_break:

        SET A, [active_display]
        SET PUSH, A
            SET A, [A+HW_INTERFACE]
            SET A, [A+DISPLAY_ITF_ACTIVATE]
            IFN A, 0
                JSR A
        ADD SP, 1

    SET Y, POP
    SET X, POP
    SET C, POP
    SET B, POP
    SET A, POP
    SET Z, POP
    SET PC, POP

video_irq:
    IFE J, 0x0000
        SET PC, .attached

    SET Y, [active_display]
    IFE Y, 0
        SET PC, POP

    SET A, [Y+HW_INTERFACE]
    SET X, [Y+HW_CONTEXT]

    IFE J, 0x0001
        SET PC, .setcursor
    IFE J, 0x0002
        SET PC, .getcursor
    IFE J, 0x0003
        SET PC, [A+DISPLAY_ITF_WRITE_CHAR]
    IFE J, 0x0004
        SET PC, [A+DISPLAY_ITF_WRITE_STRING]
    IFE J, 0x0005
        SET PC, [A+DISPLAY_ITF_SCROLL_SCREEN]
    IFE J, 0x0006
        SET PC, .getsize
    IFE J, 0x0007
        SET PC, .getdisplaycount
    IFE J, 0x0008
        SET PC, .setactivedisplay

    SET PC, POP

.attached:
    SET [Z+0], 0
    IFN [video_class+CLASS_COUNT], 0
        SET [Z+0], 1
    SET PC, POP

.setcursor:
    SET A, [Z+0]
    MUL A, [X+DISPLAY_WIDTH]
    ADD A, [Z+1]
    IFL A, [X+DISPLAY_CURSOR_MAX]
        SET [X+DISPLAY_CURSOR], A
    SET PC, POP

.getcursor:
    SET A, [X+DISPLAY_CURSOR]
    SET B, [X+DISPLAY_WIDTH]
    SET [Z+1], A
    MOD [Z+1], B
    SET [Z+0], A
    DIV [Z+0], B
    SET PC, POP

.getsize:
    SET [Z+0], [X+DISPLAY_HEIGHT]
    SET [Z+1], [X+DISPLAY_WIDTH]
    SET PC, POP

.getdisplaycount:
    SET [Z+0], [video_class+CLASS_COUNT]
    SET PC, POP

.setactivedisplay:
    SET A, [video_class+CLASS_COUNT]
    SET B, [Z+0]
    IFL B, A
        SET PC, .inbounds
    SET PC, POP
.inbounds:
    ADD B, [video_class+CLASS_ARRAY]
    SET B, [B]
    SET [active_display], B

    SET PUSH, B
        SET B, [B+HW_INTERFACE]
        SET B, [B+DISPLAY_ITF_ACTIVATE]
        IFN B, 0
            JSR B
    ADD SP, 1

    SET PC, POP
