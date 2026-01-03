include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_cmake_configure.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_cmake_build.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_cmake_install.cmake")

# Load ccache integration if the ccache feature is enabled
if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/../vcpkg-tool-ccache/vcpkg-port-config.cmake")
    include("${CMAKE_CURRENT_LIST_DIR}/../vcpkg-tool-ccache/vcpkg-port-config.cmake")
endif()
