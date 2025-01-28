#include <itkImage.h>
#include <itkVnlForwardFFTImageFilter.h>

int main()
{
    using FilterType = itk::VnlForwardFFTImageFilter<itk::Image<float, 2>>;
    auto fftFilter = FilterType::New();
    return 0;
}
