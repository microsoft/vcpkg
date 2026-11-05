vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mas-bandwidth/netcode
    REF "v${VERSION}"
    SHA512 df66e0ce9196e6a357e674427517efc159614e5ec8b0fa6cad466726ae2aa2d235f642dce048035b4987f1ad83f5fb6eccfb93315de561d8d561b41dfa0eb640
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNETCODE_SYSTEM_SODIUM=ON
        -DNETCODE_BUILD_TESTS=OFF
        -DNETCODE_INSTALL=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENCE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
