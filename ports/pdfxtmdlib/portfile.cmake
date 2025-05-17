vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Raminkord92/PDFxTMD
    REF "v-${VERSION}"
    SHA512 69cfbf45a788f7c53fb935abff1f5a225a5afdf7e4ebfbebae12542a0e484bdf7f2b1e8fa328dcb9a42743f7beb3585accd99d9a73761ec54e167b9c1ccc1de3
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