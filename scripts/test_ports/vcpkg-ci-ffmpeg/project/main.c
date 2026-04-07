#include <stdio.h>
#include "libavcodec/avcodec.h"
#include "libavutil/avutil.h"

int main()
{
    char codecVersions[256];
    avcodec_find_encoder(AV_CODEC_ID_H264);
    printf("ffmpeg version: %s\n", av_version_info());
    return 0;
}
