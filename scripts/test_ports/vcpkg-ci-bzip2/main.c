#include <bzlib.h>

#include <string.h>

int main(void)
{
    const char input[] = "vcpkg bzip2 CI";
    char compressed[128];
    char output[128];
    unsigned int compressed_size = sizeof(compressed);
    unsigned int output_size = sizeof(output);

    if (BZ2_bzBuffToBuffCompress(
            compressed, &compressed_size, (char *)input, (unsigned int)strlen(input) + 1, 9, 0, 30) != BZ_OK) {
        return 1;
    }
    if (BZ2_bzBuffToBuffDecompress(output, &output_size, compressed, compressed_size, 0, 0) != BZ_OK) {
        return 2;
    }
    return strcmp(input, output) == 0 ? 0 : 3;
}
