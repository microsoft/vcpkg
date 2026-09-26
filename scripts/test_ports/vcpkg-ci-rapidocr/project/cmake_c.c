#include <rapidocr/OcrLiteCApi.h>

int main(void)
{
    /* Link the C API from a C translation unit without calling OcrInit. */
    OCR_HANDLE (*init)(const char *, const char *, const char *, const char *, int) = &OcrInit;
    void (*destroy)(OCR_HANDLE) = &OcrDestroy;
    return (init && destroy) ? 0 : 1;
}
