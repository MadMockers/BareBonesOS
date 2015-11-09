
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>

#include <sys/types.h>
#include <sys/mman.h>

#include <arpa/inet.h>

#include "floppy.h"
#include "bootloader.h"

#define MAX_SIZE_WORDS  0xE000
#define MAX_SIZE_BYTES  (MAX_SIZE_WORDS * 2)

int main(int argc, char *argv[])
{
    int outfd, infd, result;
    off_t size;
    char buffer[1024];

    if(argc != 3)
    {
        fprintf(stderr, "%s <image> <output file>\n", basename(argv[0]));
        fprintf(stderr, "Maximum image size is 0x%X words\n", MAX_SIZE_WORDS);
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

    if(size > MAX_SIZE_BYTES)
    {
        fprintf(stderr, "Image is too large! "
                "Maximum size is 0x%X words (%d words, %d octets)\n",
                MAX_SIZE_WORDS, MAX_SIZE_WORDS, MAX_SIZE_BYTES);
        return 1;
    }
    
    void *usr_img = mmap(NULL, size, PROT_READ, MAP_PRIVATE, infd, 0);
    if(usr_img == MAP_FAILED)
    {
        fprintf(stderr, "Failed to map user image: %s\n", strerror(errno));
        return 1;
    }

    size_t outlen;
    void *floppy = build_floppy(512, bootloader_bin, bootloader_bin_len,
            usr_img, size, &outlen);

    if(!floppy)
    {
        fprintf(stderr, "Failed to build floppy from parts\n");
        return 1;
    }

    size_t written = 0;
    while(written != outlen)
    {
        int result = write(outfd, (void*)((uintptr_t)floppy + written), outlen - written);
        if(result == -1)
        {
            fprintf(stderr, "Error writing image to media: %s\n", strerror(errno));
            return 1;
        }
        written += result;
    }

    free(floppy);

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
