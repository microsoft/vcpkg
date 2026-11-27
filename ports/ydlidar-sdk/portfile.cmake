# Upstream only marks part of the API with YDLIDAR_API, so DLL builds are incomplete.
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO YDLIDAR/YDLidar-SDK
    REF "V${VERSION}"
    SHA512 8e295da4a130192b9770e8bafaab4a26a18e063f70ee3d04b2b67cdab320518ff28ec9e808d6088660ea159d970c559db97f44ceefd826c6b08975848fc7aada
    HEAD_REF master
    PATCHES
        fix-windows-macros.patch
)

# Upstream's build system is not installable (CMake 4 policy errors, LOCATION-based
# install, no exported targets), so build the same sources with a replacement.
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-ydlidar-sdk-config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DYDLIDAR_SDK_VERSION=${VERSION}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-ydlidar-sdk)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE.txt"
    "${SOURCE_PATH}/core/network/SimpleSocket.h"
    "${SOURCE_PATH}/core/math/angles.h"
)
