.define RUN_LOCATION 0xF000

zero:
    SET I, boot_rom
    SET J, RUN_LOCATION
    SET A, boot_rom_end-boot_rom

cpy_top:
    SUB A, 1
    STI [J], [I]
    IFN A, 0
    SET PC, cpy_top

    SET PC, RUN_LOCATION

boot_rom:
    .incbin "bbos.bin"
boot_rom_end:
