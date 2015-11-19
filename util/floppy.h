
#ifndef _BUILD_FLOPPY_H
#define _BUILD_FLOPPY_H

#include <stddef.h>

/**
 * @param sector_size       size of sector IN WORDS (i.e, 16 bit words)
 * @param bootloader        pointer to bootloader buffer
 * @param bootloader_len    length of bootloader buffer (IN BYTES)
 * @param usr_img           pointer to user provided image to be wrapped
 * @param img_len           length of user image (IN BYTES)
 * @param out_len           pointer to variable that will hold the size of the output (IN BYTES)
 * @return                  pointer to floppy buffer (must be free'd)
 */
void *build_floppy(size_t sector_size, void *bootloader, size_t bootloader_len,
        void *usr_img, size_t img_len, size_t *out_len);

#endif // !_BUILD_FLOPPY_H
