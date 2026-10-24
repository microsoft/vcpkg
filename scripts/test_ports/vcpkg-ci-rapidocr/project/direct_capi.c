#include <rapidocr/OcrLiteCApi.h>

int rapidocr_capi_root_include_ok(void)
{
    OCR_PARAM param;
    param.padding = 0;
    param.maxSideLen = 0;
    param.boxScoreThresh = 0.f;
    param.boxThresh = 0.f;
    param.unClipRatio = 0.f;
    param.doAngle = 0;
    param.mostAngle = 0;
    return param.padding;
}

int main(void)
{
    return rapidocr_capi_root_include_ok();
}
