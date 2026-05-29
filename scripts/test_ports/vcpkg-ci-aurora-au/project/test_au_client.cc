#include <iostream>

#include "au/au.hh"
#include "au/io.hh"
#include "au/units/hours.hh"
#include "au/units/meters.hh"
#include "au/units/miles.hh"

using ::au::symbols::h;
using ::au::symbols::mi;
constexpr auto km = ::au::kilo(::au::symbols::m);

int main(int argc, char **argv) {
  constexpr auto v = 65.0 * mi / h;
  std::cout << v << ", in km/h, rounded to nearest integer, is "
            << round_as(km / h, v) << std::endl;
  return 0;
}
