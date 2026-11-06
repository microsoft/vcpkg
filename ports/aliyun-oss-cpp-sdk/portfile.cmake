vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aliyun/aliyun-oss-cpp-sdk
    REF "${VERSION}"
    SHA512 4bcc1f609e77ea514a1f5ba76e63b51acc322d034e2889e3be545c3eb8d5e783ec9eee30745d536c6ad35474029eb921e31ceaa18f03d4678fccddf66d6604fe
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
