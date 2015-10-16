
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
