vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rollbear/trompeloeil
    REF "v${VERSION}"
    SHA512 f1a7212eacfb79f73cea075a147066b4cb10da76a6826e4594c29412395ae69647bb852d12936dd3f9b5c5a7f0aad3ebae246fdfb4006072c39b1efcd51876f5
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/trompeloeil)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")
