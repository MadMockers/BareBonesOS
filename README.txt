BareBones OS (BBOS)

Making calls to BBOS
====================
1) Set A to the chosen command A value shown below
2) Push the arguments to the stack in order listed. Any arguments with
    "OUT" before them pushes a place holder on the stack for a return value
3) Call software interrupt 0x4743
4) Any values returned will be ontop of the stack, in order listed. Any values
    left on the stack should then be POPped off the stack (i.e, caller cleans up stack)

NOTES
=====
 - Any arguments on the stack are not guaranteed to be unmodified
 - All registers will be preserved

EXAMPLES
========
Get Cursor Pos
---
SET A, 0x1002   ; Get Cursor Pos
SUB SP, 2       ; place holder for X, Y
INT 0x4743      ; invoke BBOS
SET X, POP      ; store X in X
SET Y, POP      ; store Y in Y

Poll Keyboard then Write to upper left corner
---
SET A, 0x3001   ; Read Char
SET PUSH, 1     ; block and wait for a key to be pressed
INT 0x4743      ; invoke BBOS
SET B, POP      ; get result and store in B
BOR B, 0xF000   ; Binary OR in format
SET A, 0x1003   ; Write Char
SET PUSH, B     ; Push character to be written to screen
INT 0x4743      ; invoke BBOS
ADD SP, 1       ; clean up stack

Note: Write Char does not move the cursor

STRUCTURES
==========
struct bbosinfo
{
    word Address_Start
    word Address_End
    word Interrupt_Handler
    word API_Handler
}

struct DriveParam
{
    word SectorSize
    word SectorCount
}

CO-EXISTING WITH BBOS
=====================
This section is for people who want to use BBOS functionality. If this isn't you,
you can just ignore the existance of BBOS once you're code is executing.

If you wish to use BBOS, your code needs to co-exist with it.
The bbosinfo struct from the "Get BBOS Info" call gives you all the information
you need to do this.
 - All code within 'Address_Start' and 'Address_End' must remain untouched, as this
    is where BBOS has positioned itself in memory. Modifying this memory region
    will have undefined results
 - BBOS reserves all interrupt messages starting with octet 0x47 (i.e, 0x47XX)
 - If you wish to set your own interrupt handler, you need to pass interrupts with
    the message "0x47XX" to the address 'Interrupt_Handler' via a SET PC (not a JSR)
 - Jumping to bbosinfo.Interrupt_Handler should only be done in the situation described
    in the previous point (example below). This is problematic as you can't easily
    invoke an interrupt from inside an interrupt handler, and thus would not be able to
    use BBOS functionality. To resolve this, INT 0x4743 can be replaced with JSR bbosinfo.API_Handler.

Custom Interrupt Handler Example
--------------------------------
.define BBOS_START_ADDR     0
.define BBOS_END_ADDR       1
.define BBOS_INT_HANDLER    2
.define BBOS_API_HANDLER    3
bbos_struct:
    .reserve 4
start:
    SET A, 0x0000           ; Get BBOS Info
    SET PUSH, bbos_struct   ; Push reserved bbos_struct addr as argument
    INT 0x4743              ; invoke BBOS
    ADD SP, 1               ; cleanup stack

    IAS my_interrupt_handler ; Set my_interrupt_handler as the system interrupt handler

    <other code>

my_interrupt_handler:
    SET PUSH, B             ; preserve B
    SET B, A                ; Use B as scratch pad for masking A
    AND B, 0xFF00           ; mask first octet of B
    IFE B, 0x4700           ; check if it is reserved by BBOS
        SET PC, [bbos_struct+BBOS_INT_HANDLER]  ; invoke BBOS interrupt handler
    SET B, POP              ; restore B

    <my interrupt handler code> ; custom interrupt code
    RFI                     ; return from interrupt
-----------------

FUNCTION TABLE
==============
Name                    A       Args                    Returns
------------------------------------------------------------------------
Get BBOS Info           0x0000  *bbosinfo               None

-- Video        
Screen Attached         0x1000  OUT Attached            Attached
Set Cursor Pos          0x1001  X, Y                    None
Get Cursor Pos          0x1002  OUT X, OUT Y            X, Y
Write Char              0x1003  Char (with format)      None
Write String            0x1004  StringZ (with format)   None
Scroll Screen           0x1005  Num lines to scroll     None

-- Drive
Get Drive Count         0x2000  OUT Drive Count         Drive Count
Check Drive Status      0x2001  DriveNum                StatusCode
Get Drive Parameters    0x2002  *DriveParams, DriveNum  None
Read Drive Sector       0x2003  Sector, Ptr, DriveNum   Success
Write Drive Sector      0x2004  Sector, Ptr, DriveNum   Success

-- Keyboard
Keyboard Attached       0x3000  OUT Attached            Attached
Read Char               0x3001  Blocking                Char

RTC Specification is undefined as there is currently no RTC hardware
-- RTC
RTC Attached            0x4000  OUT Attached            Attached (Always false currently)
Read RTC Time           0x4001
Read RTC Date           0x4002
Set RTC Time            0x4003
Set RTC Date            0x4004
Set RTC Alarm           0x4005
Reset RTC Alarm         0x4006

BOOTLOADERS
===========
A bootloader must be accessible via a supported storage drive at boot.
BBOS will look through all connected storage devices, and read in sector 0 of
each drive. If sector 0 *ENDS* (i.e, at location 0x1FF) in the word 0x55AA,
this sector will be loaded at address 0. Register 'A' will be set to the
'DriveNum' which this bootloader was read from (for use in the 'Drive' family
of BBOS functions), and then BBOS will pass execution to address 0.

In short:
1) Your bootloader must be built to run at address 0
2) It must be accessible on the first sector of an attached and supported
    storage device.
3) The first sector must end in 0x55AA
4) Register 'A' will hold the DriveNum
5) Execution will be passed to address 0
