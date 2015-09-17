SET I, 0x0b                              ; 0000: b0c1
SET J, 0xf000                            ; 0001: 7ce1 f000
SET A, 0x2a9                             ; 0003: 7c01 02a9
SUB A, 0x01                              ; 0005: 8803
STI [J], [I]                             ; 0006: 39fe
IFN A, 0x00                              ; 0007: 8413
SET PC, 0x05                             ; 0008: 9b81
SET PC, 0xf000                           ; 0009: 7f81 f000
SET SP, 0x00                             ; 000b: 8761
IAS 0xf05b                               ; 000c: 7d40 f05b
SET POP, 0xf615                          ; 000e: 7f01 f615
SET POP, 0x7349                          ; 0010: 7f01 7349
SET POP, 0x1802                          ; 0012: 7f01 1802
SET POP, 0x8b36                          ; 0014: 7f01 8b36
SET POP, 0x1c6c                          ; 0016: 7f01 1c6c
JSR 0xf21d                               ; 0018: 7c20 f21d
SET [0xf272], POP                        ; 001a: 63c1 f272
ADD SP, 0x04                             ; 001c: 9762
SET A, 0x00                              ; 001d: 8401
SET B, 0xee80                            ; 001e: 7c21 ee80
HWI [0xf272]                             ; 0020: 7a40 f272
SET A, 0x1004                            ; 0022: 7c01 1004
SET POP, 0xf24f                          ; 0024: 7f01 f24f
INT 0x4743                               ; 0026: 7d00 4743
ADD SP, 0x01                             ; 0028: 8b62
SET A, 0x1004                            ; 0029: 7c01 1004
SET POP, 0xf263                          ; 002b: 7f01 f263
INT 0x4743                               ; 002d: 7d00 4743
ADD SP, 0x01                             ; 002f: 8b62
JSR 0xf19f                               ; 0030: 7c20 f19f
SET A, 0x03                              ; 0032: 9001
SET B, 0x00                              ; 0033: 8421
JSR 0xf187                               ; 0034: 7c20 f187
SET [0xf27c], A                          ; 0036: 03c1 f27c
IFE [0xf27b], 0x00                       ; 0038: 87d2 f27b
SET PC, 0xf04c                           ; 003a: 7f81 f04c
SET B, 0x00                              ; 003c: 8421
SET A, 0x2003                            ; 003d: 7c01 2003
SET POP, 0x00                            ; 003f: 8701
SET POP, 0x00                            ; 0040: 8701
SET POP, B                               ; 0041: 0701
INT 0x4743                               ; 0042: 7d00 4743
SET A, POP                               ; 0044: 6001
ADD SP, 0x02                             ; 0045: 8f62
IFN A, 0x01                              ; 0046: 8813
SET PC, 0xf043                           ; 0047: 7f81 f043
IFE [0x1ff], 0x55aa                      ; 0049: 7fd2 55aa 01ff
SET PC, 0xf055                           ; 004c: 7f81 f055
ADD B, 0x01                              ; 004e: 8822
IFL B, [0xf27b]                          ; 004f: 7836 f27b
SET PC, 0xf032                           ; 0051: 7f81 f032
SET POP, 0xf27d                          ; 0053: 7f01 f27d
SET PC, 0xf04e                           ; 0055: 7f81 f04e
SET POP, 0xf295                          ; 0057: 7f01 f295
SET A, 0x1004                            ; 0059: 7c01 1004
INT 0x4743                               ; 005b: 7d00 4743
ADD SP, 0x01                             ; 005d: 8b62
SET PC, 0xf053                           ; 005e: 7f81 f053
SET A, B                                 ; 0060: 0401
SET SP, 0x00                             ; 0061: 8761
SET PC, 0x00                             ; 0062: 8781
SET POP, A                               ; 0063: 0301
SET A, 0x4744                            ; 0064: 7c01 4744
IFN A, 0x4743                            ; 0066: 7c13 4743
IFN A, 0x4744                            ; 0068: 7c13 4744
RFI                                      ; 006a: 0160
SET POP, Z                               ; 006b: 1701
SET Z, SP                                ; 006c: 6ca1
ADD Z, 0x03                              ; 006d: 90a2
SET POP, A                               ; 006e: 0301
SET POP, B                               ; 006f: 0701
SET POP, C                               ; 0070: 0b01
SET POP, X                               ; 0071: 0f01
SET POP, J                               ; 0072: 1f01
SET J, [Z+0xfffe]                        ; 0073: 54e1 fffe
IFE J, 0x00                              ; 0075: 84f2
JSR 0xf08b                               ; 0076: 7c20 f08b
SET X, J                                 ; 0078: 1c61
AND X, 0xf000                            ; 0079: 7c6a f000
IFE X, 0x1000                            ; 007b: 7c72 1000
JSR 0xf098                               ; 007d: 7c20 f098
IFE X, 0x2000                            ; 007f: 7c72 2000
JSR 0xf114                               ; 0081: 7c20 f114
IFE X, 0x3000                            ; 0083: 7c72 3000
JSR 0xf169                               ; 0085: 7c20 f169
IFE X, 0x4000                            ; 0087: 7c72 4000
JSR 0xf185                               ; 0089: 7c20 f185
SET J, POP                               ; 008b: 60e1
SET X, POP                               ; 008c: 6061
SET C, POP                               ; 008d: 6041
SET B, POP                               ; 008e: 6021
SET A, POP                               ; 008f: 6001
SET Z, POP                               ; 0090: 60a1
IFE A, 0x4743                            ; 0091: 7c12 4743
RFI                                      ; 0093: 0160
SET A, POP                               ; 0094: 6001
SET PC, POP                              ; 0095: 6381
SET A, [Z]                               ; 0096: 3401
SET [A], 0xee80                          ; 0097: 7d01 ee80
SET [A+0x01], 0xf2a9                     ; 0099: 7e01 f2a9 0001
SET [A+0x02], 0xf05b                     ; 009c: 7e01 f05b 0002
SET [A+0x03], 0xf058                     ; 009f: 7e01 f058 0003
SET PC, POP                              ; 00a2: 6381
IFE J, 0x1000                            ; 00a3: 7cf2 1000
SET PC, 0xf0b5                           ; 00a5: 7f81 f0b5
IFE [0xf272], 0xffff                     ; 00a7: 7fd2 ffff f272
SET PC, POP                              ; 00aa: 6381
IFE J, 0x1001                            ; 00ab: 7cf2 1001
SET PC, 0xf0bb                           ; 00ad: 7f81 f0bb
IFE J, 0x1002                            ; 00af: 7cf2 1002
SET PC, 0xf0c5                           ; 00b1: 7f81 f0c5
IFE J, 0x1003                            ; 00b3: 7cf2 1003
SET PC, 0xf0d0                           ; 00b5: 7f81 f0d0
IFE J, 0x1004                            ; 00b7: 7cf2 1004
SET PC, 0xf0dd                           ; 00b9: 7f81 f0dd
IFE J, 0x1005                            ; 00bb: 7cf2 1005
SET PC, 0xf10a                           ; 00bd: 7f81 f10a
SET PC, POP                              ; 00bf: 6381
SET [Z], 0x01                            ; 00c0: 89a1
IFE [0xf272], 0xffff                     ; 00c1: 7fd2 ffff f272
SET [Z], 0x00                            ; 00c4: 85a1
SET PC, POP                              ; 00c5: 6381
SET A, [Z]                               ; 00c6: 3401
MUL A, 0x20                              ; 00c7: 7c04 0020
ADD A, [Z+0x01]                          ; 00c9: 5402 0001
IFL A, 0x180                             ; 00cb: 7c16 0180
SET [0xf271], A                          ; 00cd: 03c1 f271
SET PC, POP                              ; 00cf: 6381
SET A, [0xf271]                          ; 00d0: 7801 f271
SET [Z], A                               ; 00d2: 01a1
MOD [Z], 0x20                            ; 00d3: 7da8 0020
SET [Z+0x01], A                          ; 00d5: 02a1 0001
DIV [Z+0x01], 0x20                       ; 00d7: 7ea6 0020 0001
SET PC, POP                              ; 00da: 6381
SET A, 0xee80                            ; 00db: 7c01 ee80
ADD A, [0xf271]                          ; 00dd: 7802 f271
SET B, [Z]                               ; 00df: 3421
AND B, 0xff00                            ; 00e0: 7c2a ff00
IFE B, 0x00                              ; 00e2: 8432
BOR [Z], 0xf000                          ; 00e3: 7dab f000
SET [A], [Z]                             ; 00e5: 3501
SET PC, 0xf10e                           ; 00e6: 7f81 f10e
SET A, [Z]                               ; 00e8: 3401
JSR 0xf246                               ; 00e9: 7c20 f246
SET C, [0xf271]                          ; 00eb: 7841 f271
SUB C, 0x160                             ; 00ed: 7c43 0160
IFL A, C                                 ; 00ef: 0816
SET PC, 0xf0ef                           ; 00f0: 7f81 f0ef
SET B, A                                 ; 00f2: 0021
SUB B, C                                 ; 00f3: 0823
DIV B, 0x20                              ; 00f4: 7c26 0020
SET POP, B                               ; 00f6: 0701
JSR 0xf1eb                               ; 00f7: 7c20 f1eb
ADD SP, 0x01                             ; 00f9: 8b62
SET A, 0xee80                            ; 00fa: 7c01 ee80
SET B, [0xf271]                          ; 00fc: 7821 f271
ADD A, B                                 ; 00fe: 0402
ADD B, 0x20                              ; 00ff: 7c22 0020
IFG B, 0x17f                             ; 0101: 7c34 017f
SET B, 0x17f                             ; 0103: 7c21 017f
SET [0xf271], B                          ; 0105: 07c1 f271
SET B, [Z]                               ; 0107: 3421
IFE [B], 0x00                            ; 0108: 8532
SET PC, 0xf10e                           ; 0109: 7f81 f10e
SET C, [B]                               ; 010b: 2441
IFC C, 0xff00                            ; 010c: 7c51 ff00
BOR C, 0xf000                            ; 010e: 7c4b f000
SET [A], C                               ; 0110: 0901
ADD B, 0x01                              ; 0111: 8822
ADD A, 0x01                              ; 0112: 8802
SET PC, 0xf0fd                           ; 0113: 7f81 f0fd
SET POP, [Z]                             ; 0115: 3701
JSR 0xf1eb                               ; 0116: 7c20 f1eb
ADD SP, 0x01                             ; 0118: 8b62
SET A, 0x00                              ; 0119: 8401
SET B, 0xee80                            ; 011a: 7c21 ee80
HWI [0xf272]                             ; 011c: 7a40 f272
SET PC, POP                              ; 011e: 6381
IFE J, 0x2000                            ; 011f: 7cf2 2000
SET PC, 0xf12f                           ; 0121: 7f81 f12f
SET B, [Z]                               ; 0123: 3421
IFL B, [0xf27b]                          ; 0124: 7836 f27b
SET PC, 0xf11e                           ; 0126: 7f81 f11e
SET PC, POP                              ; 0128: 6381
IFE J, 0x2001                            ; 0129: 7cf2 2001
SET PC, 0xf132                           ; 012b: 7f81 f132
IFE J, 0x2002                            ; 012d: 7cf2 2002
SET PC, 0xf138                           ; 012f: 7f81 f138
IFE J, 0x2003                            ; 0131: 7cf2 2003
SET PC, 0xf140                           ; 0133: 7f81 f140
IFE J, 0x2004                            ; 0135: 7cf2 2004
SET PC, 0xf150                           ; 0137: 7f81 f150
SET PC, POP                              ; 0139: 6381
SET [Z], [0xf27b]                        ; 013a: 79a1 f27b
SET PC, POP                              ; 013c: 6381
SET A, 0x00                              ; 013d: 8401
HWI B                                    ; 013e: 0640
SHL B, 0x08                              ; 013f: a42f
BOR B, C                                 ; 0140: 082b
SET [Z], B                               ; 0141: 05a1
SET PC, POP                              ; 0142: 6381
SET A, [Z+0x01]                          ; 0143: 5401 0001
SET [A], 0x200                           ; 0145: 7d01 0200
SET [A+0x01], 0x5a0                      ; 0147: 7e01 05a0 0001
SET PC, POP                              ; 014a: 6381
SET POP, X                               ; 014b: 0f01
SET POP, Y                               ; 014c: 1301
ADD B, 0xf273                            ; 014d: 7c22 f273
SET POP, B                               ; 014f: 0701
SET X, [Z+0x02]                          ; 0150: 5461 0002
SET Y, [Z+0x01]                          ; 0152: 5481 0001
SET A, 0x02                              ; 0154: 8c01
HWI [B]                                  ; 0155: 2640
SET B, POP                               ; 0156: 6021
SET Y, POP                               ; 0157: 6081
SET X, POP                               ; 0158: 6061
SET PC, 0xf15e                           ; 0159: 7f81 f15e
SET POP, X                               ; 015b: 0f01
SET POP, Y                               ; 015c: 1301
ADD B, 0xf273                            ; 015d: 7c22 f273
SET POP, B                               ; 015f: 0701
SET X, [Z+0x02]                          ; 0160: 5461 0002
SET Y, [Z+0x01]                          ; 0162: 5481 0001
SET A, 0x03                              ; 0164: 9001
HWI [B]                                  ; 0165: 2640
SET B, POP                               ; 0166: 6021
SET Y, POP                               ; 0167: 6081
SET X, POP                               ; 0168: 6061
SET A, 0x00                              ; 0169: 8401
SET POP, B                               ; 016a: 0701
HWI [B]                                  ; 016b: 2640
SET B, POP                               ; 016c: 6021
IFE C, 0x01                              ; 016d: 8852
SET PC, 0xf15e                           ; 016e: 7f81 f15e
SET [Z], 0x00                            ; 0170: 85a1
IFE C, 0x00                              ; 0171: 8452
SET [Z], 0x01                            ; 0172: 89a1
SET PC, POP                              ; 0173: 6381
IFE J, 0x3000                            ; 0174: 7cf2 3000
SET PC, 0xf176                           ; 0176: 7f81 f176
IFE [0xf27c], 0xffff                     ; 0178: 7fd2 ffff f27c
SET PC, POP                              ; 017b: 6381
IFE J, 0x3001                            ; 017c: 7cf2 3001
SET PC, 0xf17c                           ; 017e: 7f81 f17c
SET PC, POP                              ; 0180: 6381
SET [Z], 0x00                            ; 0181: 85a1
IFN [0xf27c], 0xffff                     ; 0182: 7fd3 ffff f27c
SET [Z], 0x01                            ; 0185: 89a1
SET PC, POP                              ; 0186: 6381
SET A, 0x01                              ; 0187: 8801
HWI [0xf27c]                             ; 0188: 7a40 f27c
IFE C, 0x00                              ; 018a: 8452
IFE [Z], 0x01                            ; 018b: 89b2
SET PC, 0xf17c                           ; 018c: 7f81 f17c
SET [Z], C                               ; 018e: 09a1
SET PC, POP                              ; 018f: 6381
SET [Z], 0x00                            ; 0190: 85a1
SET PC, POP                              ; 0191: 6381
SET POP, X                               ; 0192: 0f01
SET POP, Y                               ; 0193: 1301
SET POP, Z                               ; 0194: 1701
SET I, A                                 ; 0195: 00c1
SHL I, 0x04                              ; 0196: 94cf
BOR I, B                                 ; 0197: 04cb
HWN Z                                    ; 0198: 1600
SUB Z, 0x01                              ; 0199: 88a3
IFE Z, 0xffff                            ; 019a: 7cb2 ffff
SET PC, 0xf19a                           ; 019c: 7f81 f19a
HWQ Z                                    ; 019e: 1620
SHR B, 0x08                              ; 019f: a42d
IFE B, I                                 ; 01a0: 1832
SET PC, 0xf19a                           ; 01a1: 7f81 f19a
SET PC, 0xf18e                           ; 01a3: 7f81 f18e
SET A, Z                                 ; 01a5: 1401
SET Z, POP                               ; 01a6: 60a1
SET Y, POP                               ; 01a7: 6081
SET X, POP                               ; 01a8: 6061
SET PC, POP                              ; 01a9: 6381
HWN Z                                    ; 01aa: 1600
SUB Z, 0x01                              ; 01ab: 88a3
IFE Z, 0xffff                            ; 01ac: 7cb2 ffff
SET PC, 0xf1b6                           ; 01ae: 7f81 f1b6
HWQ Z                                    ; 01b0: 1620
JSR 0xf1b7                               ; 01b1: 7c20 f1b7
IFE I, 0x00                              ; 01b3: 84d2
SET PC, 0xf1a0                           ; 01b4: 7f81 f1a0
SET I, [0xf27b]                          ; 01b6: 78c1 f27b
ADD [0xf27b], 0x01                       ; 01b8: 8bc2 f27b
ADD I, 0xf273                            ; 01ba: 7cc2 f273
SET [I], Z                               ; 01bc: 15c1
IFL [0xf27b], 0x08                       ; 01bd: a7d6 f27b
SET PC, 0xf1a0                           ; 01bf: 7f81 f1a0
SET PC, POP                              ; 01c1: 6381
SET I, 0x00                              ; 01c2: 84c1
IFE A, 0x24c5                            ; 01c3: 7c12 24c5
IFE B, 0x4fd5                            ; 01c5: 7c32 4fd5
SET I, 0x01                              ; 01c7: 88c1
SET PC, POP                              ; 01c8: 6381
SET POP, Z                               ; 01c9: 1701
SET Z, SP                                ; 01ca: 6ca1
ADD Z, 0x02                              ; 01cb: 8ca2
SET POP, I                               ; 01cc: 1b01
SET POP, J                               ; 01cd: 1f01
SET POP, C                               ; 01ce: 0b01
SET I, [Z+0x02]                          ; 01cf: 54c1 0002
SET J, [Z+0x01]                          ; 01d1: 54e1 0001
SET C, [Z]                               ; 01d3: 3441
IFE C, 0x00                              ; 01d4: 8452
SET PC, 0xf1e6                           ; 01d5: 7f81 f1e6
IFL I, J                                 ; 01d7: 1cd6
SET PC, 0xf1d4                           ; 01d8: 7f81 f1d4
IFG I, J                                 ; 01da: 1cd4
SET PC, 0xf1db                           ; 01db: 7f81 f1db
SET PC, 0xf1e6                           ; 01dd: 7f81 f1e6
ADD C, I                                 ; 01df: 1842
IFE I, C                                 ; 01e0: 08d2
SET PC, 0xf1e6                           ; 01e1: 7f81 f1e6
STI [I], [J]                             ; 01e3: 3dde
SET PC, 0xf1d5                           ; 01e4: 7f81 f1d5
SET POP, I                               ; 01e6: 1b01
SUB C, 0x01                              ; 01e7: 8843
ADD I, C                                 ; 01e8: 08c2
ADD J, C                                 ; 01e9: 08e2
SET C, POP                               ; 01ea: 6041
STD [I], [J]                             ; 01eb: 3ddf
IFE I, C                                 ; 01ec: 08d2
SET PC, 0xf1e6                           ; 01ed: 7f81 f1e6
SET PC, 0xf1e0                           ; 01ef: 7f81 f1e0
SET C, POP                               ; 01f1: 6041
SET J, POP                               ; 01f2: 60e1
SET I, POP                               ; 01f3: 60c1
SET Z, POP                               ; 01f4: 60a1
SET PC, POP                              ; 01f5: 6381
SET POP, Z                               ; 01f6: 1701
SET Z, SP                                ; 01f7: 6ca1
ADD Z, 0x02                              ; 01f8: 8ca2
SET POP, A                               ; 01f9: 0301
SET POP, B                               ; 01fa: 0701
SET POP, C                               ; 01fb: 0b01
SET POP, I                               ; 01fc: 1b01
SET B, 0xee80                            ; 01fd: 7c21 ee80
SET C, [Z]                               ; 01ff: 3441
MUL C, 0x20                              ; 0200: 7c44 0020
SUB [0xf271], C                          ; 0202: 0bc3 f271
IFG [0xf271], 0x17f                      ; 0204: 7fd4 017f f271
SET [0xf271], 0x00                       ; 0207: 87c1 f271
SET I, C                                 ; 0209: 08c1
ADD I, B                                 ; 020a: 04c2
SET POP, B                               ; 020b: 0701
SET POP, I                               ; 020c: 1b01
SET POP, 0x180                           ; 020d: 7f01 0180
SUB PEEK, C                              ; 020f: 0b23
JSR 0xf1be                               ; 0210: 7c20 f1be
ADD SP, 0x03                             ; 0212: 9362
ADD B, 0x180                             ; 0213: 7c22 0180
SET POP, B                               ; 0215: 0701
SUB B, C                                 ; 0216: 0823
SET C, POP                               ; 0217: 6041
IFE B, C                                 ; 0218: 0832
SET PC, 0xf214                           ; 0219: 7f81 f214
SET [B], 0x00                            ; 021b: 8521
ADD B, 0x01                              ; 021c: 8822
SET PC, 0xf20d                           ; 021d: 7f81 f20d
SET A, 0x00                              ; 021f: 8401
HWI [0xf272]                             ; 0220: 7a40 f272
SET I, POP                               ; 0222: 60c1
SET C, POP                               ; 0223: 6041
SET B, POP                               ; 0224: 6021
SET A, POP                               ; 0225: 6001
SET Z, POP                               ; 0226: 60a1
SET PC, POP                              ; 0227: 6381
SET POP, Z                               ; 0228: 1701
SET Z, SP                                ; 0229: 6ca1
ADD Z, 0x02                              ; 022a: 8ca2
SET POP, A                               ; 022b: 0301
SET POP, B                               ; 022c: 0701
SET POP, C                               ; 022d: 0b01
SET POP, Y                               ; 022e: 1301
SET POP, X                               ; 022f: 0f01
SET POP, I                               ; 0230: 1b01
HWN I                                    ; 0231: 1a00
SUB I, 0x01                              ; 0232: 88c3
HWQ I                                    ; 0233: 1a20
IFE A, [Z+0x04]                          ; 0234: 5412 0004
IFE B, [Z+0x03]                          ; 0236: 5432 0003
IFE C, [Z+0x02]                          ; 0238: 5452 0002
IFE X, [Z+0x01]                          ; 023a: 5472 0001
IFE Y, [Z]                               ; 023c: 3492
SET PC, 0xf239                           ; 023d: 7f81 f239
IFE I, 0x00                              ; 023f: 84d2
SET PC, 0xf23c                           ; 0240: 7f81 f23c
SET PC, 0xf227                           ; 0242: 7f81 f227
SET [Z], I                               ; 0244: 19a1
SET PC, 0xf23e                           ; 0245: 7f81 f23e
SET [Z], 0xffff                          ; 0247: 7da1 ffff
SET I, POP                               ; 0249: 60c1
SET X, POP                               ; 024a: 6061
SET Y, POP                               ; 024b: 6081
SET C, POP                               ; 024c: 6041
SET B, POP                               ; 024d: 6021
SET A, POP                               ; 024e: 6001
SET Z, POP                               ; 024f: 60a1
SET PC, POP                              ; 0250: 6381
SET POP, A                               ; 0251: 0301
IFE [A], 0x00                            ; 0252: 8512
SET PC, 0xf24d                           ; 0253: 7f81 f24d
ADD A, 0x01                              ; 0255: 8802
SET PC, 0xf247                           ; 0256: 7f81 f247
SUB A, POP                               ; 0258: 6003
SET PC, POP                              ; 0259: 6381
.dat 0x4042                              ; 025a: 4042
.dat 0x4061                              ; 025b: 4061
.dat 0x4072                              ; 025c: 4072
.dat 0x4065                              ; 025d: 4065
.dat 0x4042                              ; 025e: 4042
.dat 0x406f                              ; 025f: 406f
.dat 0x406e                              ; 0260: 406e
.dat 0x4065                              ; 0261: 4065
.dat 0x4073                              ; 0262: 4073
.dat 0x4020                              ; 0263: 4020
.dat 0x404f                              ; 0264: 404f
.dat 0x4053                              ; 0265: 4053
.dat 0x4020                              ; 0266: 4020
.dat 0x4028                              ; 0267: 4028
.dat 0x4042                              ; 0268: 4042
.dat 0x4042                              ; 0269: 4042
.dat 0x404f                              ; 026a: 404f
.dat 0x4053                              ; 026b: 4053
.dat 0x4029                              ; 026c: 4029
.dat 0x0000                              ; 026d: 0000
.dat 0x2042                              ; 026e: 2042
.dat 0x2079                              ; 026f: 2079
.dat 0x2020                              ; 0270: 2020
.dat 0x204d                              ; 0271: 204d
.dat 0x2061                              ; 0272: 2061
.dat 0x2064                              ; 0273: 2064
.dat 0x204d                              ; 0274: 204d
.dat 0x206f                              ; 0275: 206f
.dat 0x2063                              ; 0276: 2063
.dat 0x206b                              ; 0277: 206b
.dat 0x2065                              ; 0278: 2065
.dat 0x2072                              ; 0279: 2072
.dat 0x2073                              ; 027a: 2073
.dat 0x0000                              ; 027b: 0000
.dat 0x0000                              ; 027c: 0000
.dat 0xffff                              ; 027d: ffff
.dat 0x0000                              ; 027e: 0000
.dat 0x0000                              ; 027f: 0000
.dat 0x0000                              ; 0280: 0000
.dat 0x0000                              ; 0281: 0000
.dat 0x0000                              ; 0282: 0000
.dat 0x0000                              ; 0283: 0000
.dat 0x0000                              ; 0284: 0000
.dat 0x0000                              ; 0285: 0000
.dat 0x0000                              ; 0286: 0000
.dat 0x0000                              ; 0287: 0000
.dat 0x004e                              ; 0288: 004e
.dat 0x006f                              ; 0289: 006f
.dat 0x0020                              ; 028a: 0020
.dat 0x0062                              ; 028b: 0062
.dat 0x006f                              ; 028c: 006f
.dat 0x006f                              ; 028d: 006f
.dat 0x0074                              ; 028e: 0074
.dat 0x0061                              ; 028f: 0061
.dat 0x0062                              ; 0290: 0062
.dat 0x006c                              ; 0291: 006c
.dat 0x0065                              ; 0292: 0065
.dat 0x0020                              ; 0293: 0020
.dat 0x006d                              ; 0294: 006d
.dat 0x0065                              ; 0295: 0065
.dat 0x0064                              ; 0296: 0064
.dat 0x0069                              ; 0297: 0069
.dat 0x0061                              ; 0298: 0061
.dat 0x0020                              ; 0299: 0020
.dat 0x0066                              ; 029a: 0066
.dat 0x006f                              ; 029b: 006f
.dat 0x0075                              ; 029c: 0075
.dat 0x006e                              ; 029d: 006e
.dat 0x0064                              ; 029e: 0064
.dat 0x0000                              ; 029f: 0000
.dat 0x004e                              ; 02a0: 004e
.dat 0x006f                              ; 02a1: 006f
.dat 0x0020                              ; 02a2: 0020
.dat 0x0064                              ; 02a3: 0064
.dat 0x0072                              ; 02a4: 0072
.dat 0x0069                              ; 02a5: 0069
.dat 0x0076                              ; 02a6: 0076
.dat 0x0065                              ; 02a7: 0065
.dat 0x0073                              ; 02a8: 0073
.dat 0x0020                              ; 02a9: 0020
.dat 0x0063                              ; 02aa: 0063
.dat 0x006f                              ; 02ab: 006f
.dat 0x006e                              ; 02ac: 006e
.dat 0x006e                              ; 02ad: 006e
.dat 0x0065                              ; 02ae: 0065
.dat 0x0063                              ; 02af: 0063
.dat 0x0074                              ; 02b0: 0074
.dat 0x0065                              ; 02b1: 0065
.dat 0x0064                              ; 02b2: 0064
.dat 0x0000                              ; 02b3: 0000
