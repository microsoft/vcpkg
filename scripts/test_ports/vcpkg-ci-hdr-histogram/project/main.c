#include <hdr/hdr_histogram.h>
#include <hdr/hdr_thread.h>

int main() {
    struct hdr_histogram* histogram = NULL;
    int rc = hdr_init(1, 1000000, 3, &histogram);
    if (rc != 0) {
        return 1;
    }
    hdr_record_value(histogram, 42);
    hdr_usleep(1);
    hdr_close(histogram);
    return 0;
}
