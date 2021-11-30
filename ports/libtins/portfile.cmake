vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mfontanini/libtins
    REF v4.3
    SHA512 29d606004fe9a440c9a53eede42fd5c6dbd049677d2cca2c5cfd26311ee2ca4c64ca3e665fbc81efd5bfab5577a5181ed0754c617e139317d9ae0cabba05aff7
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBTINS_BUILD_SHARED)

set(ENABLE_PCAP FALSE)
if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  set(ENABLE_PCAP TRUE)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBTINS_BUILD_SHARED=${LIBTINS_BUILD_SHARED}
        -DLIBTINS_ENABLE_PCAP=${ENABLE_PCAP}
        -DLIBTINS_ENABLE_CXX11=1
)

vcpkg_cmake_install()

if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "windows" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore") #Windows
    vcpkg_cmake_config_fixup(CONFIG_PATH CMake)
else() #Linux/Unix/Darwin
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libtins)
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/libtins/libtinsConfig.cmake" "set(LIBTINS_INCLUDE_DIRS \"${SOURCE_PATH}/include\")" [[
get_filename_component(LIBTINS_CMAKE_DIR "${LIBTINS_CMAKE_DIR}" PATH)
get_filename_component(LIBTINS_CMAKE_DIR "${LIBTINS_CMAKE_DIR}" PATH)
set(LIBTINS_INCLUDE_DIRS "${LIBTINS_CMAKE_DIR}/include")
]])

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libtins" RENAME copyright)

vcpkg_fixup_pkgconfig()
