//#include <vxl_config.h>
#include <vil/vil_rgb.h>
#include <vil/vil_load.h>
#include <vil/vil_image_view.h>

int main()
{
  vil_image_view<vil_rgb<vxl_byte> > img = vil_load("foo.tiff");
  return 0;
}