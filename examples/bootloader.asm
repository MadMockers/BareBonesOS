#include "bbos.inc.asm"

.define sector_start 509
.define sector_end 510
.define magic 511

copy_start:
start:
    SET PUSH, A  ; A has drive to load off
        ; get position of BBOS
        SET A, 0x0000
        SET PUSH, 0
            INT BBOS_IRQ_MAGIC
        SET B, POP
        SET J, [B+BBOS_START_ADDR]
        SUB J, loader_end-trap

        SET I, physical_start
        SET Z, J
        SET A, loader_end-trap
.copy_top:
        SUB A, 1
        STI [J], [I]
        IFN A, 0
            SET PC, .copy_top
        ADD Z, loader_entry-trap
        SET PC, Z
copy_end:

physical_start:

; trap to stop code underneath us from running into us
trap:
    SET J, PC
    SET SP, 0
    SET PUSH, J
    ADD [SP], trap_str-trap-1
        SET I, J
        ADD I, write_screen-trap-1
        JSR I
    ADD SP, 1
    SUB PC, 1

loader_entry:
    SET J, PC
    SET B, POP

    SET PUSH, J
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
    SET PUSH, C
    SET PUSH, X
    SET PUSH, B
        INT BBOS_IRQ_MAGIC
    SET Y, POP
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
    SET PUSH, J
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
    SET PUSH, A
        ; check display is attached
        SET A, 0x1000
        SUB SP, 1
            INT BBOS_IRQ_MAGIC
        SET A, POP
        IFE A, 0
            SET PC, .done

        ; write string
        SET A, 0x1004
        SET PUSH, [SP+2]
        SET PUSH, 1
            INT BBOS_IRQ_MAGIC
        ADD SP, 2
.done:
    SET A, POP
    SET PC, POP
    
drive_fail:
    .asciiz "Error while reading"
title_str:
    .asciiz "BootLoader v0.1"
trap_str:
    .asciiz "Caught stray execution: halting"
loader_end:
end:
