
rtc_irq:
    IFE J, 0x0000
        SET PC, .attached
    IFE [rtc_port], 0xFFFF
        SET PC, POP

    IFE J, 0x0001
        SET PC, .read_time
    IFE J, 0x0002
        SET PC, .read_date
    IFE J, 0x0003
        SET PC, .set_time
    IFE J, 0x0004
        SET PC, .set_date
    IFE J, 0x0005
        SET PC, feature_not_implemented
    IFE J, 0x0006
        SET PC, feature_not_implemented
    SET PC, POP

.attached:
    SET [Z+0], 0
    IFN [rtc_port], 0xFFFF
        SET [Z+0], 1
    SET PC, POP

.read_time:
    ; ABCXJ are already preserved
    ; Use J as stack frame, since clock uses Z
    SET J, Z
    SET PUSH, Y
    SET PUSH, Z

    ; REAL_TIME
    ; B: Year
    ; C: Month | Date
    ; X: Hours | Minutes
    ; Y: Seconds
    ; Z: Milliseconds
    SET A, 0x10
    HWI [rtc_port]

    ; Only care about the time portion
    SET B, X
    SHR B, 16
    AND X, 0xFF

    ; B = Hours
    ; X = Minutes
    ; Y = Seconds

    SET [J+0], Y
    SET [J+1], X
    SET [J+2], B

    SET Z, POP
    SET Y, POP
    SET PC, POP

.read_date:
    ; ABCXJ are already preserved
    ; Use J as stack frame, since clock uses Z
    SET J, Z
    SET PUSH, Y
    SET PUSH, Z

    ; REAL_TIME
    ; B: Year
    ; C: Month | Day
    ; X: Hours | Minutes
    ; Y: Seconds
    ; Z: Milliseconds
    SET A, 0x10
    HWI [rtc_port]

    ; Only care about the date portion
    SET X, C
    SHR X, 8
    AND C, 0xFF

    ; B = Year
    ; X = Month
    ; C = Day

    SET [Z+0], C
    SET [Z+1], X
    SET [Z+2], B

    SET Z, POP
    SET Y, POP
    SET PC, POP

.set_time:
    ; ABCXJ are already preserved
    ; Use J as stack frame, since clock uses Z
    SET J, Z
    SET PUSH, Y
    SET PUSH, Z
    SET PUSH, I

    ; read date/time, update time portion, then set
    ; REAL_TIME
    ; B: Year
    ; C: Month | Day
    ; X: Hours | Minutes
    ; Y: Seconds
    ; Z: Milliseconds
    SET A, 0x10
    HWI [rtc_port]

    ; Use I to build hours | minutes
    SET I, [J+2]    ; J+2 = hours
    SHL I, 8
    BOR I, [J+1]    ; J+1 = minutes
    SET X, I

    SET Y, [J+0]    ; J+0 = seconds

    ; Don't modify milliseconds. BBOS interface doesn't support it

    ; SET_REAL_TIME
    SET A, 0x12
    HWI [rtc_port]

    SET I, POP
    SET Z, POP
    SET Y, POP
    SET PC, POP

.set_date:
    ; ABCXJ are already preserved
    ; Use J as stack frame, since clock uses Z
    SET J, Z
    SET PUSH, Y
    SET PUSH, Z
    SET PUSH, I

    ; read date/time, update time portion, then set
    ; REAL_TIME
    ; B: Year
    ; C: Month | Day
    ; X: Hours | Minutes
    ; Y: Seconds
    ; Z: Milliseconds
    SET A, 0x10
    HWI [rtc_port]

    ; Use I to build hours | minutes
    SET B, [J+2]    ; J+2 = year

    SET I, [J+1]    ; J+1 = month
    SHL I, 8
    BOR I, [J+0]    ; J+0 = day
    SET X, I

    ; SET_REAL_TIME
    SET A, 0x12
    HWI [rtc_port]

    SET I, POP
    SET Z, POP
    SET Y, POP
    SET PC, POP
