
.define BBOS_IRQ_MAGIC      0x4743

.define BBOS_VERSION        0
.define BBOS_START_ADDR     1
.define BBOS_END_ADDR       2
.define BBOS_INT_HANDLER    3
.define BBOS_API_HANDLER    4
.define BBOSINFO_SIZE       5

; struct DriveParam
.define DRIVE_SECT_SIZE     0
.define DRIVE_SECT_COUNT    1
.define DRIVEPARAM_SIZE     2

.define DRIVE_STATE_MASK    0xFF00
.define DRIVE_ERROR_MASK    0x00FF

.define DRIVE_STATE_NO_MEDIA    0
.define DRIVE_STATE_READY       1
.define DRIVE_STATE_READY_WP    2
.define DRIVE_STATE_BUSY        3

.define DRIVE_ERROR_NONE        0
.define DRIVE_ERROR_BUSY        1
.define DRIVE_ERROR_NO_MEDIA    2
.define DRIVE_ERROR_PROTECTED   3
.define DRIVE_ERROR_EJECT       4
.define DRIVE_ERROR_BAD_SECTOR  5
.define DRIVE_ERROR_BAD_ADDRESS 6
.define DRIVE_ERROR_BROKEN      0xFF

;struct CommsInfo
.define COMMS_BUSY          0
.define COMMS_RECV_AVAIL    1
.define COMMS_WRITE_AVAIL   2
.define COMMS_ACTIVE_PORT   3
.define COMMS_DATA_ON_PORT  4
.define COMMS_SIZE          5

.define COMMS_ERROR_NONE        0
.define COMMS_ERROR_OVERFLOW    1
.define COMMS_ERROR_GENERIC     2
.define COMMS_ERROR_NO_DATA     3

; === BBOS function values ===
.define BBOS_FN_GET_INFO            0x0000      ; v1.0

; Display functions
.define BBOS_VID_ATTACHED           0x1000      ; v1.0
.define BBOS_VID_SET_CURSOR_POS     0x1001      ; v1.0
.define BBOS_VID_GET_CURSOR_POS     0x1002      ; v1.0
.define BBOS_VID_WRITE_CHAR         0x1003      ; v1.0
.define BBOS_VID_WRITE_STRING       0x1004      ; v1.0
.define BBOS_VID_SCROLL             0x1005      ; v1.0
.define BBOS_VID_GET_SIZE           0x1006      ; v1.0
.define BBOS_VID_GET_COUNT          0x1007      ; v1.1
.define BBOS_VID_SET_ACTIVE         0x1008      ; v1.1

; Drive functions
.define BBOS_DRV_GET_COUNT          0x2000      ; v1.0
.define BBOS_DRV_CHECK_STATUS       0x2001      ; v1.0
.define BBOS_DRV_GET_PARAMS         0x2002      ; v1.0
.define BBOS_DRV_READ_SECTOR        0x2003      ; v1.0
.define BBOS_DRV_WRITE_SECTOR       0x2004      ; v1.0

; Keyboard
.define BBOS_KEY_ATTACHED           0x3000      ; v1.0
.define BBOS_KEY_READ_CHAR          0x3001      ; v1.0

; RTC
.define BBOS_RTC_ATTACHED           0x4000      ; v1.0
.define BBOS_RTC_READ_TIME          0x4001      ; Not implemented
.define BBOS_RTC_READ_DATE          0x4002      ; Not implemented
.define BBOS_RTC_SET_TIME           0x4003      ; Not implemented
.define BBOS_RTC_SET_DATE           0x4004      ; Not implemented
.define BBOS_RTC_SET_ALARM          0x4005      ; Not implemented
.define BBOS_RTC_RESET_ALARM        0x4006      ; Not implemented

; Comms
.define BBOS_COM_ATTACHED           0x5000      ; v1.0
