# portfile.cmake for quran
# This port builds libquran from a source archive.

# HEAD_REF is the branch name used when installing with --head
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SENODROOM/libquran
    REF "v${VERSION}"
    SHA512 a906c9734162dddb3af69949e88547d45cc4ebc079c6535cf6568741b034e2fbdbb5a34fffbcacfaa3fded1c42a90bdbdf72ee7ac547107e0d979f3b8a9b4da1
    HEAD_REF main
)

# Alternatively, when distributing as a local overlay port with the
# source bundled alongside, use:
#
#   set(SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}/src")
#
# and include the full source tree inside ports/quran/src/.

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQURAN_BUILD_TESTS=OFF
        -DQURAN_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME quran
    CONFIG_PATH  lib/cmake/quran
)

# Remove duplicate includes installed under debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Install the license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Validate
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
