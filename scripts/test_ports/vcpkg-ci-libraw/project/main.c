#include <stdio.h>

#include <libraw/libraw.h>

int main(void)
{
    libraw_data_t* data = libraw_init(0);

    if (data == NULL) {
        fprintf(stderr, "Failed to initialize LibRaw\n");
        return 1;
    }

    printf("LibRaw version: %s\n", libraw_version());
    printf("Supported cameras: %d\n", libraw_cameraCount());

    if (libraw_open_buffer(data, "invalid", 7) == LIBRAW_SUCCESS) {
        fprintf(stderr, "LibRaw accepted an invalid buffer\n");
        libraw_close(data);
        return 1;
    }

    libraw_close(data);

    return 0;
}
