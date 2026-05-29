vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aliyun/aliyun-oss-c-sdk
    REF ${VERSION}
    SHA512 b00f17e0a55fbf6dfc94c3a109013ea31cb234ce444c4e824749e380aa4d90c0d8440a1705aa8f8ab57c883f03c37757e4f2d09d1a0d960fd2f158128501727e
    HEAD_REF master
    PATCHES
        patch.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
