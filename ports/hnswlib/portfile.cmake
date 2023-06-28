vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nmslib/hnswlib
    REF "v${VERSION}"
    SHA512 fd74c23040598973d7e0b5a6af73eb884ee2d30703187d1702fdd48eaf8f7f96d8fbb125d3763f90111d9fb7c5ab3434ebdb818da8717d35c5571e99083c812b
    HEAD_REF master
    PATCHES
        cmake.patch # Backport CMake targets from nmslib/hnswlib #446 to 0.7.0 release.
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHNSWLIB_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/hnswlib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
