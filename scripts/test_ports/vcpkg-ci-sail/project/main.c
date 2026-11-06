#include <stdio.h>

#include <sail/sail.h>
#include <sail-manip/sail-manip.h>

int main(void)
{
    if (sail_init() != SAIL_OK) {
        fprintf(stderr, "Failed to initialize SAIL\n");
        return 1;
    }

    const struct sail_codec_bundle_node* codec_bundle_node = sail_codec_bundle_list();

    if (codec_bundle_node == NULL) {
        fprintf(stderr, "No SAIL codecs were found\n");
        return 1;
    }

    for (; codec_bundle_node != NULL; codec_bundle_node = codec_bundle_node->next) {
        printf("Codec: %s\n", codec_bundle_node->codec_bundle->codec_info->name);
    }

    const struct sail_codec_info* codec_info;

    if (sail_codec_info_from_extension("png", &codec_info) != SAIL_OK) {
        fprintf(stderr, "Failed to find the PNG codec\n");
        return 1;
    }

    if (!sail_can_convert(SAIL_PIXEL_FORMAT_BPP24_RGB, SAIL_PIXEL_FORMAT_BPP32_RGBA)) {
        fprintf(stderr, "sail-manip is unable to convert BPP24-RGB to BPP32-RGBA\n");
        return 1;
    }

    sail_finish();

    return 0;
}
