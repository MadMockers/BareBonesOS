
#include "bbos.inc.asm"

.define BL_SIZE end-loader_entry

copy_start:
start:
    PUSH A  ; A has drive to load off
        SET I, physical_start
        SET J, loader_entry
        SET A, BL_SIZE
.copy_top:
        SUB A, 1
        STI [J], [I]
        IFN A, 0
            SET PC, .copy_top
        SET PC, loader_entry
copy_end:

physical_start:

.org 509
sector_start:
.org 510
sector_end:
.org 511
magic:

.org 0xE000
loader_entry:
    POP B
    PUSH title_str
        JSR write_screen
    ADD SP, 1

    SET A, 0x2003
    SET C, [sector_start]
    SET X, 0
    SET Z, [sector_end]
.load_top:
    IFE Z, 0
        SET PC, done
    PUSH C
    PUSH X
    PUSH B
        INT BBOS_IRQ_MAGIC
    POP Y
    ADD SP, 2
    IFE Y, 0
        SET PC, load_fail
    SUB Z, 1
    ADD C, 1
    ADD X, 0x200
    SET PC, .load_top

load_fail:
    PUSH drive_fail
        JSR write_screen
        SET PC, die

done:
    SET A, B
    SET SP, 0
    SET PC, 0

die:
    SET PC, die

write_screen:
    PUSH A
        SET A, 0x1004
        PUSH [SP+2]
            INT BBOS_IRQ_MAGIC
        ADD SP, 1
    POP A
    RET
    
drive_fail:
    .asciiz "Error while reading"
title_str:
    .asciiz "BootLoader v0.1"
loader_end:
end:
