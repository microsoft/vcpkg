vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aliyun/aliyun-oss-cpp-sdk
    REF "${VERSION}"
    SHA512 7773961ad380d28cda96e16ae6491a76e03f0cb5f0c5135b660179dd449d730e1dfffb916489ed60e13815f53566c24cd9cfd8985c468438369341358eeed3bd
    HEAD_REF master
    PATCHES
        0001-dependency-and-targets.patch
        0003-suppress-fmt-warning.patch
        disable-werror.diff
)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/0002-unofficial-export.cmake" DESTINATION "${SOURCE_PATH}/sdk/")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_SAMPLE=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
