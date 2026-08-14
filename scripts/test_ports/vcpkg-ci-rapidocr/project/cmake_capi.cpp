#include <rapidocr/OcrLiteCApi.h>

int main()
{
    OCR_HANDLE handle = OcrInit("missing-det.onnx", "missing-cls.onnx", "missing-rec.onnx", "missing-keys.txt", 1);
    if (handle)
    {
        OcrDestroy(handle);
    }
    return 0;
}
