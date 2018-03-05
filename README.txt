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
SET PUSH, 0     ; Don't move cursor
INT 0x4743      ; invoke BBOS
ADD SP, 2       ; clean up stack

STRUCTURES
==========
struct bbosinfo
{
    word Version
    word Address_Start
    word Address_End
    word Interrupt_Handler
    word API_Handler
}

struct drive_param
{
    word SectorSize
    word SectorCount
}

CO-EXISTING WITH BBOS
=====================
This section is for people who want to use BBOS functionality. If this isn't
you, you can just ignore the existance of BBOS once you're code is executing.

If you wish to use BBOS, your code needs to co-exist with it. Firstly you need
to confirm that BBOS is on the system you're running on (your code may have
been loaded by something else). To do this, before you set your interrupt
handler (via the IAS instruction), call "Get BBOS Info", however make sure the
placeholder argument is 0 (i.e, SET PUSH, 0). If this argument is still 0
after the interrupt, then BBOS is not on this system.
The bbosinfo struct from the "Get BBOS Info" call gives you all the information
you needed to co-exist
 - All memory within 'Address_Start' and 'Address_End' must remain untouched,
    as this is where BBOS has positioned itself in memory. Modifying this
    memory region will have undefined results
 - BBOS reserves all interrupt messages starting with octet 0x47 (i.e, 0x47XX)
 - If you wish to set your own interrupt handler, you need to pass interrupts
    with the message "0x47XX" to the address 'Interrupt_Handler' via a
    SET PC, Interrupt_Handler (not a JSR Interrupt_Handler)
 - Jumping to bbosinfo.Interrupt_Handler should only be done in the situation
    described in the previous point (example below). This is problematic as
    you can't easily invoke an interrupt from inside an interrupt handler, and
    thus would not be able to use BBOS functionality. To resolve this, 
    INT 0x4743 can be replaced with JSR bbosinfo.API_Handler.

Custom Interrupt Handler Example
--------------------------------
.define BBOS_VERSION        0
.define BBOS_START_ADDR     1
.define BBOS_END_ADDR       2
.define BBOS_INT_HANDLER    3
.define BBOS_API_HANDLER    4
bbos_int_addr:
.dat    0
start:
    SET A, 0x0000           ; Get BBOS Info
    SUB SP, 1               ; placeholder for return value
    INT 0x4743              ; invoke BBOS
    SET A, POP              ; pop address of info struct into A
    
    ; update our value 'bbos_int_addr' with the value from the struct
    SET [bbos_int_addr], [A+BBOS_INT_HANDLER]

    IAS my_interrupt_handler ; Set my_interrupt_handler as the system interrupt handler

    <other code>

my_interrupt_handler:
    SET PUSH, B             ; preserve B
    SET B, A                ; Use B as scratch pad for masking A
    AND B, 0xFF00           ; mask first octet of B
    IFE B, 0x4700           ; check if it is reserved by BBOS
        SET PC, [bbos_int_addr]  ; invoke BBOS interrupt handler
    SET B, POP              ; restore B

    <my interrupt handler code> ; custom interrupt code
    RFI                     ; return from interrupt
-----------------

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

FUNCTION TABLE
==============
Name                    A       Args                    Returns         Version
-------------------------------------------------------------------------------
Get BBOS Info           0x0000  OUT *bbosinfo           *bbosinfo       1.0

-- Video        
Screen Attached         0x1000  OUT Attached            Attached        1.0
Set Cursor Pos          0x1001  X, Y                    None            1.0
Get Cursor Pos          0x1002  OUT X, OUT Y            Y, X            1.0
Write Char              0x1003  Char, MoveCursor        None            1.0
Write String            0x1004  StringZ, NewLine        None            1.0
Scroll Screen           0x1005  Num lines to scroll     None            1.0
Get Screen Size         0x1006  OUT Width, OUT Height   Height, Width   1.0
Get Screen Count        0x1007  OUT Count               Count           1.1
Set Active Screen       0x1008  Index                   None            1.1

-- Drive
Get Drive Count         0x2000  OUT Drive Count         Drive Count     1.0
Check Drive Status      0x2001  DriveNum                StatusCode      1.0
Get Drive Parameters    0x2002  *DriveParams, DriveNum  None            1.0
Read Drive Sector       0x2003  Sector, Ptr, DriveNum   Success         1.0
Write Drive Sector      0x2004  Sector, Ptr, DriveNum   Success         1.0

-- Keyboard
Keyboard Attached       0x3000  OUT Attached            Attached        1.0
Read Character          0x3001  Blocking                Char            1.0

RTC Specification is undefined as there is currently no RTC hardware
-- RTC
RTC Attached            0x4000  OUT Attached            Attached        1.0
Read RTC Time           0x4001
Read RTC Date           0x4002
Set RTC Time            0x4003
Set RTC Date            0x4004
Set RTC Alarm           0x4005
Reset RTC Alarm         0x4006

Comms not supported at this time
-- Comms
Comms Attached          0x5000  OUT Attached            Attached        1.0
Query                   0x5001  *CommsInfo              None            1.0
Query Port              0x5002  Port, *Name             ID, Connected   1.0
Configure               0x5003  DataWidth               None            1.0
Receive                 0x5004  OUT Lo, OUT Hi, OUT Err Err, Hi, Lo     1.0
Transmit                0x5005  Hi, Lo                  Error           1.0
Set Port                0x5006  Port                    Success         1.0
Set Notify              0x5007  FunctionPtr             None            1.0

FUNCTION DOCUMENTATION
======================
'Get BBOS Info'
---------------
Arguments: None (1 placeholder)
Returns: struct bbosinfo*
Since: v1.0

Provides the information available in the 'bbosinfo' struct, namely the
BBOS version, position of BBOS in memory, the address of the BBOS
interrupt handler, and the address of the BBOS API handler
(description in "CO-EXISTING WITH BBOS").
The BBOS version has the major version in the high octet, and the minor
version in the low octet.
This function returns a pointer to a bbosinfo struct. This struct must
not be modified.

'Screen Attached'
-----------------
Arguments: None (1 placeholder)
Returns: Attached
Since: v1.0

If BBOS identified supported display hardware, this function
returns 1 in Attached, otherwise it returns 0.
If this function returns 0, calling any other 'video' related function
has undefined results.

'Set Cursor Pos'
----------------
Arguments: X, Y
Returns: None
Since: v1.0

Sets the position of the cursor on the screen. Coordinate (0, 0) is
the top left corner of the screen.

'Get Cursor Pos'
----------------
Arguments: None (2 placeholder)
Returns: Y, X
Since: v1.0

Gets the position of the cursor on the screen. Coordinate (0, 0) is
the top left corner of the screen.

'Write Char'
------------
Arguments: Char, MoveCursor
Returns: None
Since: v1.0

Writes the provided character to the position of the cursor on screen.
If the high 9 bits of 'Char' are unset (i.e, the character has no format),
a default format of 0xF000 is applied, which is white on black.
If 'MoveCursor' is set to a non zero value, the cursor position is
progressed by 1.

'Write String'
--------------
Arguments: StringZ, NewLine
Returns: None
Since: v1.0

'StringZ' refers to a zero terminated string, where each character is 16 bits.
As each character is written, if the high 9 bits of are unset (i.e, the
character has no format), a default format of 0xF000 is applied, which
is white on black.
The cursor is progressed by the number of characters in the string. If the
string runs off the bottom of the screen, the screen is scrolled in order
to display the entire string. If 'NewLine' is non zero, the cursor will
be rounded up to the next line after being progressed.

'Scroll Screen'
---------------
Arguments: Lines
Returns: None
Since: v1.0

Scrolls the screen, providing more space at the bottom of the screen.

'Get Screen Size'
---------------
Arguments: None (2 placeholder)
Returns: Height, Width
Since: v1.0

Gets size of the screen (measured in characters).

'Get Screen Count'
---------------
Arguments: None (1 placeholder)
Returns: Count
Since: v1.1

Gets the number of supported display devices connected.

'Set Active Screen'
-----------------
Arguments: Index
Returns: None
Since: v1.1

Sets the active screen. Index starts from 0, and must be less than
screen count. All screen operations take place on the active screen.

'Get Drive Count'
-----------------
Arguments: None (1 placeholder)
Returns: DriveCount
Since: v1.0

Returns the number of attached supported drives that were identified.
If this function returns 0, using other 'Drive' related functions have
undefined results.

'Check Drive Status'
--------------------
Arguments: DriveNum
Returns: Status
Since: v1.0

Returns the status of the drive specified by the DriveNum argument.
The status return value has 2 values packed into it. The high octet
is the current state of the drive. The low octet is the last error.
The state values are:
NO_MEDIA:   No media is present in the drives (for drives that offer
            removable media)
READY:      The drive is ready to receive read and write instructions.
READY_WP:   The drive is write-protected. It is ready to receive
            read instructions.
BUSY:       The drive is currently busy with a previous instruction.

The error values are:
NONE:       There has not been an error since last check
BUSY:       A read or write instruction was given while the drive was
            busy.
NO_MEDIA:   A read or write instruction was given while the drive had
            no media (for drives that offer removable media).
PROTECTED:  A write instruction was issued to a write-protected drive.
EJECT:      Removable media was ejected while an operation was in progress.
BAD_SECTOR: A read or write operation failed due to a bad sector.
BROKEN:     Unknown serious error

'Get Drive Parameters'
----------------------
Arguments: struct drive_params*, DriveNum
Returns: None
Since: v1.0

Gets the information for the specified drive. The first argument is a
pointer to 'drive_params' struct, which contains the size of the sectors
on the drive, and the number of sectors.

'Read Drive Sector'
-------------------
Arguments: Sector, Pointer, DriveNum
Returns: Success
Since: v1.0

Reads 'Sector' from the drive specified by 'DriveNum'. 'Pointer' is the
address of memory, which will have SectorSize words written into it.
On success, 'Success' is 1, otherwise 'Success' is 0. On failure,
the last error can be obtained via the 'Check Drive Status' function.

'Write Drive Sector'
--------------------
Arguments: Sector, Pointer, DriveNum
Returns: Success
Since: v1.0

Writes SectorSize words from the memory specified at 'Pointer' to the
sector specified by 'Sector' on the drive specified by 'DriveNum'.
On success, 'Success' is 1, otherwise 'Success' is 0. On failure,
the last error can be obtained via the 'Check Drive Status' function.

'Keyboard Attached'
-------------------
Arguments: None (1 placeholder)
Returns: Attached
Since: v1.0

Returns 1 if a supported keyboard is attached. If a supported keyboard
is not attached, calling other keyboard functions has undefined behaviour.

'Read Character'
----------------
Arguments: Blocking
Returns: Char
Since: v1.0

Reads a character from the keyboard buffer. If the buffer is empty and
'Blocking' is 0, the value 0 is returned in 'Char'. Otherwise if
'Blocking' is 1, the function will wait for a key to be pressed.

'RTC Attached'
--------------
Arguments: None (1 placeholder)
Returns: Attached
Since: v1.0

Returns 1 if a supported real time clock is attached.

Other RTC functions are currently undefined as there is currently no
RTC hardware specification.

'Comms Attached'
----------------
Arguments: None (1 placeholder)
Returns: Attached
Since: v1.0

Returns 1 if a supported comms device is attached

'Query'
-------
Arguments: struct CommsInfo*
Returns: None
Since: v1.0

Fills in the CommsInfo struct.

'QueryPort'
-----------
Arguments: Port, char Name[32]
Returns: ID, Connected
Since: v1.0

Fills in the Name buffer with the name of the port specified.
Returns the ID of the port, and if the port is connected.

'Configure'
-----------
Arguments: Width
Returns: None
Since: v1.0

Configure the port to either 16 bit words or 32 bit words per
transmit / receive.
If Width = 0, configure the port to 16 bits
If Width = 1, configure the port to 32 bits

'Receive'
---------
Arguments: None (3 placeholder)
Returns: Error, High, Low
Since: v1.0

Reads 16 or 32 bits. If width is configured to 16 bits, High
is set to 0.
Error codes:
    0:  No error
    1:  Buffer overflow
    2:  Generic Error
    3:  No data available

'Transmit'
----------
Arguments: High, Low
Returns: Error
Since: v1.0

Transmits 16 or 32 bits. If width is configured to 16 bits,
High is ignored.
Error codes:
    0:  No error
    1:  Buffer overflow

'Set Port'
----------
Arguments: Port
Returns: Success
Since: v1.0

Sets the active Port.

'Set Notify'
------------
Arguments: Function
Returns: None
Since: v1.0

If Function is not NULL, receive notifications when data becomes
available. The address Function is called with register A set to
the port that has data available. The function must preserve *ALL*
registers (i.e, after returning with SET PC, POP, all register must
be the same as when entering the function).
If Function is NULL, disable notifications.
