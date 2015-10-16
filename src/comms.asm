
notify_func:
    .dat 0

current_port:
    .dat 0

comms_notify:
    SET PUSH, B
    SET PUSH, C
        SET A, 0
        HWI [comms_port]

        SET A, C
        JSR [notify_func]
    SET C, POP
    SET B, POP
    RFI

comms_irq:
    SET X, [comms_port]

    IFE J, 0x0000
        SET PC, .attached
    IFE X, 0xFFFF
        SET PC, POP

    IFE J, 0x0001
        SET PC, .query
    IFE J, 0x0002
        SET PC, .query_port
    IFE J, 0x0003
        SET PC, .configure
    IFE J, 0x0004
        SET PC, .receive
    IFE J, 0x0005
        SET PC, .transmit
    IFE J, 0x0006
        SET PC, .set_port
    IFE J, 0x0007
        SET PC, .set_notify
    SET PC, POP

; Returns
; +0 Attached
.attached:
    SET [Z], 0
    IFN X, 0xFFFF
        SET [Z], 1
    SET PC, POP

; +0 Ptr to CommsInfo
; Returns
; None
.query:
    SET A, 0
    HWI X

    SET X, [Z+0]
    SET [X+COMMS_ACTIVE_PORT], B
    SET [X+COMMS_DATA_ON_PORT], C

    SET [current_port], B
    
    SHR A, 27
    SET C, A
    AND C, 0x1
    SET [X+COMMS_WRITE_AVAIL], C

    SHR A, 2
    SET C, A
    AND C, 0x1
    SET [X+COMMS_RECV_AVAIL], C

    SHR A, 2
    SET C, A
    AND C, 0x1
    SET [X+COMMS_BUSY], C

    SET PC, POP

; +1 Port
; +0 Name: Ptr to 25 len string or NULL
; Returns
; +0 Port ID
; +1 Connected
.query_port:
    SET A, 7
    SET B, [Z+1]
    SET C, [Z+0]
    SET PUSH, B
        HWI X
    SET B, POP

    SET A, 6
    HWI X
    SET [Z+0], A
    SET [Z+1], B

    SET PC, POP

; +0 Width
.configure:
    SET A, 1
    SET B, [Z+0]
    HWI X
    SET PC, POP

; +2 OUT Lo
; +1 OUT Hi
; +0 OUT Error
; Returns
; +0 Error
; +1 Hi
; +2 Lo
.receive:
    SET A, 2
    HWI X
    SET [Z+0], C
    SET [Z+1], B
    SET [Z+2], A
    SET PC, POP

; +1 Hi
; +0 Lo
; Returns
; +0 Error
.transmit:
    SET A, 3
    SET B, [Z+0]
    SET C, [Z+1]
    HWI X
    SET [Z+0], C

    ; 2 = queued, which is close enough
    IFE C, 2
        SET C, 0
    SET PC, POP

; +0 Port
; Returns
; +0 Success
.set_port:
    SET A, 8
    SET B, [Z+0]
    HWI X
    XOR C, 1

    IFE C, 1
        SET [current_port], B

    SET [Z+0], C
    SET PC, POP

; +0 Function
.set_notify:

    SET A, 4
    SET B, 1
    IFE [Z+0], 0
        SET B, 0
    SET C, COMMS_IRQ

    SET J, X
    SET X, 0
    HWI J

    SET [notify_func], [Z+0]

    SET PC, POP
