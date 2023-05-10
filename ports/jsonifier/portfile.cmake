vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realtimechris/jsonifier
    REF "v${VERSION}"
    SHA512 c912258d44d71f789a151505dd605854bda00ef7dc3e8a23764a6a645cbb3a2c4523d0d58fb2c1194d857e6ed1499334813a5765ff5ce4466176bea256ec772a
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
