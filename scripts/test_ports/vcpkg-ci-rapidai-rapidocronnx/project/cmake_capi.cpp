#include <rapidocronnx/OcrLiteCApi.h>

int main()
{
    // Link the C API without calling it. OcrInit on missing ONNX paths is not a
    // supported entry and aborts on some native triplets (arm64-osx).
    OCR_HANDLE (*volatile init)(const char *, const char *, const char *, const char *, int) = &OcrInit;
    void (*volatile destroy)(OCR_HANDLE) = &OcrDestroy;
    return (init && destroy) ? 0 : 1;
}
