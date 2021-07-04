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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DLIBTINS_BUILD_SHARED=${LIBTINS_BUILD_SHARED}
        -DLIBTINS_ENABLE_PCAP=${ENABLE_PCAP}
        -DLIBTINS_ENABLE_CXX11=1
)

vcpkg_install_cmake()

if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "windows" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore") #Windows
    vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)
else() #Linux/Unix/Darwin
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libtins)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libtins RENAME copyright)
