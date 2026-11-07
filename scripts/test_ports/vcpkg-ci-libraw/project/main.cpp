#include <cstdio>
#include <memory>

#include <libraw/libraw.h>

int main()
{
    std::unique_ptr<LibRaw> processor(new LibRaw());

    std::printf("LibRaw version: %s\n", LibRaw::version());
    std::printf("Supported cameras: %d\n", LibRaw::cameraCount());

    if (processor->open_buffer("invalid", 7) == LIBRAW_SUCCESS) {
        std::fprintf(stderr, "LibRaw accepted an invalid buffer\n");
        return 1;
    }

    processor->recycle();

    return 0;
}
