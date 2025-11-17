#include <iostream>
#include <LIEF/LIEF.hpp>
#include <LIEF/version.h>

int main()
{
   // Outputs a string representation of the PUBLIC access flag (index 1)
   std::cout << "access flags public = " << LIEF::DEX::to_string(LIEF::DEX::access_flags_list[1]) << std::endl;
   std::cout << "Version = " << LIEF_VERSION << std::endl;
   return 0;
}
