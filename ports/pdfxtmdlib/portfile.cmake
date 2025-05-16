vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Raminkord92/PDFxTMD
    REF "v-${VERSION}"
    SHA512 f6c9b8dba0afb9f556cff51a60e28c3d90f23e7810996900ad611a4ac071dcf8bcd4f6132d738943e3b71e2610a2250fbce2165f8c16a736ce6ebfe422dc9689
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