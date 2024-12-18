#include <iostream>
#include <LIEF/LIEF.hpp>
#include <LIEF/version.h>

int main()
{
   std::cout << "access flags public = " << LIEF::DEX::to_string(LIEF::DEX::access_flags_list[1]) << std::endl;
   std::cout << "Version = " << LIEF_VERSION << std::endl;
   return 0;
}
