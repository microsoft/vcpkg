#include <stdint.h>
#include <libaec.h>

int main()
{
    int32_t source[] = { 1, 1, 1, 4};
    int source_length = 4;

    unsigned char dest[64];
    int dest_lenth = 64;
    
    struct aec_stream strm;
    strm.bits_per_sample = 32;
    strm.block_size = 16;
    strm.rsi = 128;
    strm.flags = AEC_DATA_SIGNED | AEC_DATA_PREPROCESS;
    strm.next_in = (unsigned char *)source;
    strm.avail_in = source_length * sizeof(int32_t);
    strm.next_out = (unsigned char *)dest;
    strm.avail_out = dest_lenth;
    if (aec_encode_init(&strm) != AEC_OK)
        return 1;
    if (aec_encode(&strm, AEC_FLUSH) != AEC_OK)
        return 1;
    aec_encode_end(&strm);

    return 0;
}
