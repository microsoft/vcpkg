#include <rtl-sdr.h>

int main()
{
  return (int)rtlsdr_get_device_count();
}
