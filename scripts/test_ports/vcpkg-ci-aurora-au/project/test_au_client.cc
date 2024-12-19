#include <iostream>

#include "au/au.hh"
#include "au/constants/speed_of_light.hh"
#include "au/io.hh"
#include "au/units/meters.hh"
#include "au/units/seconds.hh"

using ::au::SPEED_OF_LIGHT;
using ::au::symbols::m;
using ::au::symbols::s;

int main(int argc, char **argv) {
  std::cout << "Speed of light in m/s: " << SPEED_OF_LIGHT.as<int>(m / s)
            << std::endl;
  return 0;
}