#include <cstdio>
#include <vector>

#include <jxl/decode_cxx.h>
#include <jxl/encode_cxx.h>
#include <jxl/thread_parallel_runner_cxx.h>

int main()
{
    JxlThreadParallelRunnerPtr runner = JxlThreadParallelRunnerMake(
        nullptr, JxlThreadParallelRunnerDefaultNumWorkerThreads());
    JxlEncoderPtr encoder = JxlEncoderMake(nullptr);
    JxlDecoderPtr decoder = JxlDecoderMake(nullptr);

    if (!runner || !encoder || !decoder) {
        std::fprintf(stderr, "Failed to create libjxl objects\n");
        return 1;
    }

    if (JxlEncoderSetParallelRunner(encoder.get(), JxlThreadParallelRunner, runner.get()) != JXL_ENC_SUCCESS
        || JxlDecoderSetParallelRunner(decoder.get(), JxlThreadParallelRunner, runner.get()) != JXL_DEC_SUCCESS) {
        std::fprintf(stderr, "Failed to set the parallel runner\n");
        return 1;
    }

    const std::vector<uint8_t> invalid = { 'i', 'n', 'v', 'a', 'l', 'i', 'd' };

    if (JxlSignatureCheck(invalid.data(), invalid.size()) != JXL_SIG_INVALID) {
        std::fprintf(stderr, "libjxl accepted an invalid signature\n");
        return 1;
    }

    std::printf("libjxl encoder version: %u\n", JxlEncoderVersion());

    return 0;
}
