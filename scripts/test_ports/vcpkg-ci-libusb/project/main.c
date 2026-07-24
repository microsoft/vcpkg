#include <libusb.h>

int main() {
    libusb_context *ctx = NULL;
    int ret = libusb_init(&ctx);
    if (ret != 0) return 1;
    libusb_exit(ctx);
    return 0;
}
