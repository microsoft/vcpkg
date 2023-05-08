# Backport CMake targets from develop
vcpkg_download_distfile(
    CMAKE_TARGETS_PATCH
    URLS "https://github.com/nmslib/hnswlib/commit/dccd4f98acb9da404b7439606a97c4e3077a8d44.patch"
    FILENAME dccd4f98acb9da404b7439606a97c4e3077a8d44.patch
    SHA512 e514feaf9b5138627aa9847c12cba111acd6ae7315acff14aabe151e3339600418473f805053bb3b28ed92b32751ccac675feaa95cc3881090de672b70983140
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nmslib/hnswlib
    REF "v${VERSION}"
    SHA512 fd74c23040598973d7e0b5a6af73eb884ee2d30703187d1702fdd48eaf8f7f96d8fbb125d3763f90111d9fb7c5ab3434ebdb818da8717d35c5571e99083c812b
    HEAD_REF master
    PATCHES
        ${CMAKE_TARGETS_PATCH}
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
