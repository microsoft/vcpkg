vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Raminkord92/PDFxTMD
    REF "v-${VERSION}"
    SHA512 acbe6288198fa9f95711ac4d545453116fd6ce47cdb6df68a178541639434f2fb01704f2f29a0ce39ab71469c2239efcf4c4132924fd66fc12eb01f82f098950
    HEAD_REF main
)
set(VCPKG_POLICY_ALLOW_EMPTY_FOLDERS enabled)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_BUILDING_WRAPPERS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME PDFxTMDLib
 CONFIG_PATH lib/cmake/PDFxTMDLib)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")