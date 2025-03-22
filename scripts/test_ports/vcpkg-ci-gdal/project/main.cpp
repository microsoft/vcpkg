#include <gdal_priv.h>

int main()
{
    GDALAllRegister();
    auto poDataset = GDALDatasetUniquePtr(GDALDataset::FromHandle(GDALOpen("test.gtif", GA_ReadOnly)));
    return 0;
}
