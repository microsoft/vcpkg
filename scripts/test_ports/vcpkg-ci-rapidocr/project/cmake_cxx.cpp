#include <rapidocr/OcrLite.h>

int main()
{
    // Default-constructed OcrLite must destroy without initModels().
    {
        OcrLite ocr;
        (void)ocr;
    }
    return 0;
}
