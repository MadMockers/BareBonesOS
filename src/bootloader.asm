
#include "bbos.inc.asm"

.define DEBUG

.define BL_SIZE loader_end-loader_entry

.define DEBUG_BASE_ADDR 0xE000

.define sector_start 509
.define sector_end 510
.define magic 511

copy_start:
start:
    PUSH A  ; A has drive to load off
        ; get position of BBOS
        SET A, 0x0000
        SUB SP, BBOSINFO_SIZE
        SET B, SP
        PUSH B
            INT BBOS_IRQ_MAGIC
        ADD SP, 1
        SET J, [B+BBOS_START_ADDR]
        SUB J, BL_SIZE
.ifdef DEBUG
        SET J, DEBUG_BASE_ADDR
.endif

        SET I, physical_start
        SET Z, J
        SET A, BL_SIZE
        ADD SP, BBOSINFO_SIZE
.copy_top:
        SUB A, 1
        STI [J], [I]
        IFN A, 0
            SET PC, .copy_top
        SET PC, Z
copy_end:

physical_start:

.ifdef DEBUG
.org DEBUG_BASE_ADDR
.endif
loader_entry:
    SET J, PC
    POP B

    PUSH J
    ADD [SP], title_str-loader_entry-1
        SET I, J
        ADD I, write_screen-loader_entry-1
        JSR I
    ADD SP, 1

    SET A, 0x2003
    SET C, [sector_start]
    SET X, 0
    SET Z, [sector_end]
load_top:
    IFE Z, 0
        ADD PC, done-src1
src1:
    PUSH C
    PUSH X
    PUSH B
        INT BBOS_IRQ_MAGIC
    POP Y
    ADD SP, 2
    IFE Y, 0
        ADD PC, load_fail-src2
src2:
    SUB Z, 1
    ADD C, 1
    ADD X, 0x200
    ADD PC, load_top-src3
src3:

load_fail:
    PUSH J
    ADD [SP], drive_fail-loader_entry-1
        SET I, J
        ADD I, write_screen-loader_entry-1
        JSR I
    ADD SP, 1
    ADD PC, die-src4
src4:

done:
    SET A, B
    SET SP, 0
    SET PC, 0

die:
    SET PC, die

write_screen:
    PUSH A
        ; check display is attached
        SET A, 0x1000
        SUB SP, 1
            INT BBOS_IRQ_MAGIC
        POP A
        IFE A, 0
            SET PC, .done

        ; write string
        SET A, 0x1004
        PUSH [SP+2]
            INT BBOS_IRQ_MAGIC
        ADD SP, 1
.done:
    POP A
    RET
    
drive_fail:
    .asciiz "Error while reading"
title_str:
    .asciiz "BootLoader v0.1"
loader_end:
end:

