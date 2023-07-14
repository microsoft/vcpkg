vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jbaldwin/libcoro
    REF "v${VERSION}"
    SHA512 746607793ba2e0c809e731b39423fa84e451a67129ba311dc3ccc257d5d31be0f94826ca1bffc8a88f9f4675ba4224d3290bab6e46116bcdee50acb2f96fbf81
    HEAD_REF master
    PATCHES
        0001-allow-shared-lib.patch
        0002-disable-git-config.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBCORO_EXTERNAL_DEPENDENCIES=ON
        -DLIBCORO_BUILD_TESTS=OFF
        -DLIBCORO_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()
