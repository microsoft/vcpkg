#include <stdio.h>
#include <avif/avif.h>

int main()
{
    char codecVersions[256];
    avifCodecVersions(codecVersions);
    printf("Codec Versions: %s\n", codecVersions);
    return 0;
}
