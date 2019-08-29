# The upstream CMakeLists.txt exports libpng's targets to a file named `libpng16.cmake`.
# However, `find_package(libpng CONFIG)` expects a file named `libpngConfig.cmake` to exist instead.
#
# By including `libpng.cmake` from this file, `find_package(libpng CONFIG)` will work.
get_filename_component(_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
include("${_DIR}/libpng16.cmake")
