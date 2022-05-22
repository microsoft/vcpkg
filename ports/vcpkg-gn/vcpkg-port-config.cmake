include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_gn_configure.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_gn_install.cmake")

file(REAL_PATH "${CMAKE_CURRENT_LIST_DIR}/../../tools/vcpkg-gn/gn${CMAKE_EXECUTABLE_SUFFIX}" VCPKG_GN)
