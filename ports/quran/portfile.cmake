vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SENODROOM/libquran
    REF "v${VERSION}"
    SHA512 a906c9734162dddb3af69949e88547d45cc4ebc079c6535cf6568741b034e2fbdbb5a34fffbcacfaa3fded1c42a90bdbdf72ee7ac547107e0d979f3b8a9b4da1
    HEAD_REF main
)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQURAN_BUILD_TESTS=OFF
        -DQURAN_BUILD_EXAMPLES=OFF
        -DBUILD_SHARED_LIBS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME quran
    CONFIG_PATH  lib/cmake/quran
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")