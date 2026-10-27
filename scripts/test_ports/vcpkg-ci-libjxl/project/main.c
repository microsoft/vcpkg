#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <jxl/cms.h>
#include <jxl/decode.h>
#include <jxl/encode.h>
#include <jxl/thread_parallel_runner.h>

#define WIDTH 4
#define HEIGHT 4

static int encode(void* runner, uint8_t** compressed, size_t* compressed_size)
{
    uint8_t pixels[WIDTH * HEIGHT * 3];
    for (size_t i = 0; i < sizeof(pixels); i++) {
        pixels[i] = (uint8_t)(i * 7);
    }

    JxlEncoder* encoder = JxlEncoderCreate(NULL);
    if (encoder == NULL) {
        fprintf(stderr, "Failed to create JXL encoder\n");
        return 1;
    }

    JxlEncoderSetCms(encoder, *JxlGetDefaultCms());

    if (JxlEncoderSetParallelRunner(encoder, JxlThreadParallelRunner, runner) != JXL_ENC_SUCCESS) {
        fprintf(stderr, "Failed to set the encoder parallel runner\n");
        JxlEncoderDestroy(encoder);
        return 1;
    }

    JxlBasicInfo basic_info;
    JxlEncoderInitBasicInfo(&basic_info);
    basic_info.xsize = WIDTH;
    basic_info.ysize = HEIGHT;
    basic_info.bits_per_sample = 8;
    basic_info.uses_original_profile = JXL_TRUE;

    JxlColorEncoding color_encoding;
    JxlColorEncodingSetToSRGB(&color_encoding, JXL_FALSE);

    JxlPixelFormat pixel_format = { 3, JXL_TYPE_UINT8, JXL_NATIVE_ENDIAN, 0 };
    JxlEncoderFrameSettings* frame_settings = JxlEncoderFrameSettingsCreate(encoder, NULL);

    if (JxlEncoderSetBasicInfo(encoder, &basic_info) != JXL_ENC_SUCCESS
        || JxlEncoderSetColorEncoding(encoder, &color_encoding) != JXL_ENC_SUCCESS
        || JxlEncoderSetFrameLossless(frame_settings, JXL_TRUE) != JXL_ENC_SUCCESS
        || JxlEncoderAddImageFrame(frame_settings, &pixel_format, pixels, sizeof(pixels)) != JXL_ENC_SUCCESS) {
        fprintf(stderr, "Failed to set up the JXL encoder\n");
        JxlEncoderDestroy(encoder);
        return 1;
    }

    JxlEncoderCloseInput(encoder);

    size_t capacity = 1024;
    *compressed = malloc(capacity);
    uint8_t* next_out = *compressed;
    size_t avail_out = capacity;
    JxlEncoderStatus status;

    while ((status = JxlEncoderProcessOutput(encoder, &next_out, &avail_out)) == JXL_ENC_NEED_MORE_OUTPUT) {
        size_t offset = (size_t)(next_out - *compressed);
        capacity *= 2;
        *compressed = realloc(*compressed, capacity);
        next_out = *compressed + offset;
        avail_out = capacity - offset;
    }

    JxlEncoderDestroy(encoder);

    if (status != JXL_ENC_SUCCESS) {
        fprintf(stderr, "Failed to encode the JXL image\n");
        return 1;
    }

    *compressed_size = (size_t)(next_out - *compressed);
    return 0;
}

static int decode(void* runner, const uint8_t* compressed, size_t compressed_size)
{
    JxlDecoder* decoder = JxlDecoderCreate(NULL);
    if (decoder == NULL) {
        fprintf(stderr, "Failed to create JXL decoder\n");
        return 1;
    }

    if (JxlDecoderSetParallelRunner(decoder, JxlThreadParallelRunner, runner) != JXL_DEC_SUCCESS
        || JxlDecoderSubscribeEvents(decoder, JXL_DEC_BASIC_INFO) != JXL_DEC_SUCCESS
        || JxlDecoderSetInput(decoder, compressed, compressed_size) != JXL_DEC_SUCCESS) {
        fprintf(stderr, "Failed to set up the JXL decoder\n");
        JxlDecoderDestroy(decoder);
        return 1;
    }

    JxlDecoderCloseInput(decoder);

    JxlBasicInfo basic_info;
    if (JxlDecoderProcessInput(decoder) != JXL_DEC_BASIC_INFO
        || JxlDecoderGetBasicInfo(decoder, &basic_info) != JXL_DEC_SUCCESS) {
        fprintf(stderr, "Failed to decode the JXL basic info\n");
        JxlDecoderDestroy(decoder);
        return 1;
    }

    JxlDecoderDestroy(decoder);

    printf("Decoded image: %ux%u\n", basic_info.xsize, basic_info.ysize);

    if (basic_info.xsize != WIDTH || basic_info.ysize != HEIGHT) {
        fprintf(stderr, "Unexpected JXL image size\n");
        return 1;
    }

    return 0;
}

int main(void)
{
    uint32_t version = JxlDecoderVersion();
    printf("libjxl version: %u.%u.%u\n", version / 1000000, version / 1000 % 1000, version % 1000);

    void* runner = JxlThreadParallelRunnerCreate(NULL, JxlThreadParallelRunnerDefaultNumWorkerThreads());
    if (runner == NULL) {
        fprintf(stderr, "Failed to create JXL thread parallel runner\n");
        return 1;
    }

    uint8_t* compressed = NULL;
    size_t compressed_size = 0;
    int result = encode(runner, &compressed, &compressed_size);

    if (result == 0) {
        printf("Encoded size: %zu bytes\n", compressed_size);
        result = decode(runner, compressed, compressed_size);
    }

    free(compressed);
    JxlThreadParallelRunnerDestroy(runner);

    return result;
}
