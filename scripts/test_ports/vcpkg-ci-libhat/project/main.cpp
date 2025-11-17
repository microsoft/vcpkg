#include <libhat/signature.hpp>
int main()
{
   auto sig = hat::parse_signature("01 02 03 04 05 06 07 08 09").value();
   return 0;
}
