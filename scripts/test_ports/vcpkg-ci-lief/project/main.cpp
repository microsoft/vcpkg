#include <iostream>
#include <LIEF/LIEF.hpp>
#include <LIEF/version.h>
using namespace std;
using namespace LIEF;
int main()
{
	LIEF::assembly::aarch64::REG inst = LIEF::assembly::aarch64::REG::D13;
	std::cout << "reg = " << LIEF::assembly::aarch64::get_register_name(inst) << std::endl;
   std::cout << "access flags public = " << LIEF::DEX::to_string(LIEF::DEX::access_flags_list[1]) << std::endl;
   std::cout << "Version = " << LIEF_VERSION << std::endl;
   return 0;
}
