# The upstream CMake exports its targets to a file named libpng.cmake
# however, find_package(libpng CONFIG) doesn't work with that name.
#
# By includeing `libpng.cmake` form this file, find_package() will be 
# able to find the exports `libpngConfig.cmake`.
include(libpng16)