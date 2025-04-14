#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <libaec.h>

int main()
{

    uint8_t input_data[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    size_t input_size = sizeof(input_data);

    uint8_t compressed_data[20];
    size_t compressed_size = sizeof(compressed_data);

    uint8_t decompressed_data[10];
    size_t decompressed_size = sizeof(decompressed_data);

    struct aec_stream strm;
    memset(&strm, 0, sizeof(strm));
    strm.next_in = input_data;
    strm.avail_in = input_size;
    strm.next_out = compressed_data;
    strm.avail_out = compressed_size;

    if (aec_encode_init(&strm) != AEC_OK) {
        fprintf(stderr, "Failed to initialize encoder\n");
        return 1;
    }

    if (aec_encode(&strm, AEC_FLUSH) != AEC_OK) {
        fprintf(stderr, "Failed to encode data\n");
        return 1;
    }

    compressed_size = strm.total_out;
    aec_encode_end(&strm);

    printf("Compression successful, compressed size: %zu\n", compressed_size);
    return 0;
}
