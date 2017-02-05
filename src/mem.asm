
alloc_pos:
.dat        bbos_start

; SP+1: Size
; Return
; SP+1: Memory
alloc:
    SUB [alloc_pos], [SP+1]
    SET [SP+1], [alloc_pos]
    SET PC, POP
