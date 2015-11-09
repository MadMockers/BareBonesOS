
#ifndef _BUILD_FLOPPY_H
#define _BUILD_FLOPPY_H

#include <stddef.h>

void *build_floppy(size_t sector_size, void *bootloader, size_t bootloader_len,
        void *usr_img, size_t img_len, size_t *out_len);

#endif // !_BUILD_FLOPPY_H
