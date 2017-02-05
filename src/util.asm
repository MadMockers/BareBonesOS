
; +2 dest
; +1 src
; +0 len
memmove:
    SET PUSH, Z
    SET Z, SP
    ADD Z, 2
    SET PUSH, I
    SET PUSH, J
    SET PUSH, C

        SET I, [Z+2]
        SET J, [Z+1]
        SET C, [Z+0]

        IFE C, 0
            SET PC, .done
        IFL I, J
            SET PC, .fwd
        IFG I, J
            SET PC, .bkwd
        SET PC, .done

.fwd:
        ADD C, I
.fwd_top:
        IFE I, C
            SET PC, .done
        STI [I], [J]
        SET PC, .fwd_top

.bkwd:
        SET PUSH, I
            SUB C, 1
            ADD I, C
            ADD J, C
        SET C, POP
.bkwd_top:
        STD [I], [J]
        IFE I, C
            SET PC, .done
        SET PC, .bkwd_top

.done:
    SET C, POP
    SET J, POP
    SET I, POP
    SET Z, POP
    SET PC, POP

; A: str
; Return
; A: len
strlen:
    SET PUSH, A
.loop_top:
        IFE [A], 0
            SET PC, .loop_break
        ADD A, 1
        SET PC, .loop_top
.loop_break:
    SUB A, POP
    SET PC, POP
