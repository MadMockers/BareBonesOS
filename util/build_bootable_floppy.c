
#include <libgen.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>

#include <sys/types.h>

#include <arpa/inet.h>

#include "bootloader.h"

#define BBOS_MAGIC      0x55AA

struct info
{
    uint16_t    start_sector;
    uint16_t    sector_count;
    uint16_t    magic;
} __attribute__((packed));

int main(int argc, char *argv[])
{
    int outfd, infd, result;
    off_t size;
    struct info info;
    char buffer[1024];

    if(argc != 3)
    {
        fprintf(stderr, "%s <image> <output file>\n", basename(argv[0]));
        fprintf(stderr, "Maximum image size is 0xE000 words\n");
        return 1;
    }

    outfd = open(argv[2], O_RDWR | O_CREAT | O_TRUNC, 0644);
    if(outfd == -1)
    {
        fprintf(stderr, "Failed to open output file '%s': %s\n",
                argv[2], strerror(errno));
        return 1;
    }

    infd = open(argv[1], O_RDONLY);
    if(infd == -1)
    {
        fprintf(stderr, "Failed to open image file %s: %s\n",
                argv[1], strerror(errno));
        return 1;
    }

    /* get image size */
    size = lseek(infd, 0, SEEK_END);
    lseek(infd, 0, SEEK_SET);

    if(size > 0xE000)
    {
        fprintf(stderr, "Image is too large! Maximum size is 0xE000 words (57,344 words, 114,688 octets)\n");
        return 1;
    }

    /* write out bootloader */
    result = write(outfd, bootloader_bin, bootloader_bin_len);
    if(result != bootloader_bin_len)
    {
        fprintf(stderr, "Failed to write bootloader: %s\n", strerror(errno));
        return 1;
    }

    /* truncate to 512-sizeof(info) words (1018 bytes), then write info */
    result = ftruncate(outfd, 512*2-sizeof(info));
    if(result == -1)
    {
        fprintf(stderr, "Error expanding output file: %s\n", strerror(errno));
        return 1;
    }
    lseek(outfd, 0, SEEK_END);

    /* write start sector */
    info.start_sector = htons(1);
    info.sector_count = htons(size / (512 * 2) + 1);
    info.magic = htons(BBOS_MAGIC);
    result = write(outfd, &info, sizeof(info));
    if(result != sizeof(info))
    {
        fprintf(stderr, "Error writing sector info: %s\n", strerror(errno));
        return 1;
    }

    /* write user image */
    while(1)
    {
        result = read(infd, buffer, sizeof(buffer));
        if(result == 0)
            break;
        if(result == -1)
        {
            fprintf(stderr, "Error reading from image file: %s\n", strerror(errno));
            return 1;
        }

        if(write(outfd, buffer, result) != result)
        {
            fprintf(stderr, "Error writing image to media: %s\n", strerror(errno));
            return 1;
        }
    }

    /* truncate to final size */
    result = ftruncate(outfd, 1440 * 512 * 2);
    if(result == -1)
    {
        fprintf(stderr, "Error expanding output to final size: %s\n", strerror(errno));
        return 1;
    }

    printf("Boot media successfully created at '%s'\n", argv[2]);

    return 0;
}
