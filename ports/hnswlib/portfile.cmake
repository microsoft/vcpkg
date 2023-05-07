vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nmslib/hnswlib
    REF dccd4f98acb9da404b7439606a97c4e3077a8d44 # v0.7.0 + CMake targets from develop
    SHA512 4faa7c3dc75e45c506a14bd2932b62d42e919e7b6c6e275513ae5162ee6b203d63edbd9d0ce6cfb67c3b935460c2ea200a69beafa2b426eccb4b969d269e34bb
    HEAD_REF master
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
