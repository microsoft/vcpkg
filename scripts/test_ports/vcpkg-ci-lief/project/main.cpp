#include <iostream>
#include <LIEF/LIEF.hpp>
#include <LIEF/version.h>
#include <memory>
using namespace std;
using namespace LIEF;
int main()
{
   std::unique_ptr<assembly::Instruction> inst = get_inst();
   std::cout << "address = " << inst.value().address() << std::endl;
   std::cout << "access flags public = " << LIEF::DEX::to_string(LIEF::DEX::access_flags_list[1]) << std::endl;
   std::cout << "Version = " << LIEF_VERSION << std::endl;
   return 0;
}
