
#include <string.h>
#include <stdlib.h>

#include <sys/mman.h>

#include <arpa/inet.h>

#include "floppy.h"

#define BBOS_MAGIC      0x55AA

struct info
{
    uint16_t    start_sector;
    uint16_t    sector_count;
    uint16_t    magic;
} __attribute__((packed));

/* sizeof(packed structure) is not what you want */
#define STRUCT_INFO_SIZE    6

void *build_floppy(size_t sector_size, void *bootloader, size_t bootloader_len,
        void *usr_img, size_t img_len, size_t *out_len)
{
    sector_size *= sizeof(uint16_t);
    if(bootloader_len > sector_size - STRUCT_INFO_SIZE)
        return NULL;
    void *floppy = malloc(sector_size + img_len);
    if(!floppy)
        return NULL;

    memcpy(floppy, bootloader, bootloader_len);
    memcpy((void*)((uintptr_t)floppy + sector_size), usr_img, img_len);

    struct info *info = (struct info*)((uintptr_t)floppy + sector_size - STRUCT_INFO_SIZE);
    info->start_sector = htons(1);
    info->sector_count = htons((img_len-1) / sector_size + 1);
    info->magic = htons(BBOS_MAGIC);

    *out_len = sector_size + img_len;

    return floppy;
}

