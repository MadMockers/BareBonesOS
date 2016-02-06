
m525hd_interface:
    DAT .getstatus
    DAT .getparam
    DAT .read
    DAT .write

.define M525HD_ERROR_NONE           0x0000
.define M525HD_ERROR_BUSY           0x0001
.define M525HD_ERROR_BAD_ADDRESS    0x0002
.define M525HD_ERROR_PROTECTED      0x0003
.define M525HD_ERROR_PARKED         0x0004
.define M525HD_ERROR_BAD_SECTOR     0x0005
.define M525HD_ERROR_BROKEN         0xFFFF

.define M525HD_STATE_READY          0x0001
.define M525HD_STATE_READY_WP       0x0002
.define M525HD_STATE_BUSY           0x0003
.define M525HD_STATE_PARKED         0x0004
.define M525HD_STATE_PARKED_WP      0x0005
.define M525HD_STATE_INIT           0x0006
.define M525HD_STATE_INIT_WP        0x0007

.define M525HD_CMD_STATUS           0x0000
.define M525HD_CMD_SET_INTERRUPT    0x0001
.define M525HD_CMD_READ_SECTOR      0x0002
.define M525HD_CMD_WRITE_SECTOR     0x0003
.define M525HD_CMD_SPIN_DOWN        0x0004
.define M525HD_CMD_SPIN_UP          0x0005

.error_lookup:
    DAT DRIVE_ERROR_NONE        ; NONE
    DAT DRIVE_ERROR_BUSY        ; BUSY
    DAT DRIVE_ERROR_BAD_ADDRESS ; BAD_ADDRESS
    DAT DRIVE_ERROR_PROTECTED   ; PROTECTED
    DAT DRIVE_ERROR_INTERNAL    ; PARKED
    DAT DRIVE_ERROR_BAD_SECTOR  ; BAD_SECTOR
    DAT DRIVE_ERROR_BROKEN      ; BROKEN

.state_lookup:
    DAT 0   ; starts from 1
    DAT DRIVE_STATE_READY       ; READY
    DAT DRIVE_STATE_READY_WP    ; READY_WP
    DAT DRIVE_STATE_BUSY        ; BUSY
    DAT DRIVE_STATE_READY       ; PARKED
    DAT DRIVE_STATE_READY_WP    ; PARKED_WP
    DAT DRIVE_STATE_BUSY        ; INIT
    DAT DRIVE_STATE_BUSY        ; INIT_WP

.normalize_error_and_state:
    ; B = state
    ; C = error
    ADD B, .state_lookup
    SET B, [B]
    ADD C, .error_lookup
    SET C, [C]
    SET PC, POP

.getstatus:
    SET A, M525HD_CMD_STATUS
    HWI [B]
    JSR .normalize_error_and_state
    SHL B, 8
    AND C, 0xFF
    BOR B, C
    SET [Z+0], B
    SET PC, POP

.getparam:
    SET A, [Z+1]
    SET [A+DRIVE_SECT_SIZE], 512
    SET [A+DRIVE_SECT_COUNT], 5120
    SET PC, POP

.spinup:
    SET A, M525HD_CMD_SPIN_UP
    HWI [B]

.spinup_wait:
    SET A, M525HD_CMD_STATUS
    SET PUSH, B
        HWI [B]
    SET A, B
    SET B, POP
    IFE A, M525HD_STATE_INIT
        SET PC, .spinup_wait

    ; error handling can happen in the '.wait'
    SET PC, POP

.spindown:
    SET A, M525HD_CMD_SPIN_DOWN
    HWI [B]
    SET PC, POP

.read:
    JSR .spinup
    SET PUSH, X
    SET PUSH, Y
        SET PUSH, B
            SET X, [Z+2]
            SET Y, [Z+1]
            SET A, M525HD_CMD_READ_SECTOR
            HWI [B]
        SET B, POP
    SET Y, POP
    SET X, POP
    SET PC, .wait

.write:
    JSR .spinup
    SET PUSH, X
    SET PUSH, Y
        SET PUSH, B
            SET X, [Z+2]
            SET Y, [Z+1]
            SET A, M525HD_CMD_WRITE_SECTOR
            HWI [B]
        SET B, POP
    SET Y, POP
    SET X, POP
    ; SET PC, .wait ; fall through right below

.wait:
    SET A, M525HD_CMD_STATUS
    SET PUSH, B
        HWI [B]
    SET A, B
    SET B, POP
    IFE A, M525HD_STATE_BUSY
        SET PC, .wait
    SET [Z+0], 0
    IFE C, M525HD_ERROR_NONE
        SET [Z+0], 1
    SET PC, POP

