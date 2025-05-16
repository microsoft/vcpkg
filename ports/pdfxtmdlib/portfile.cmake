vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Raminkord92/PDFxTMD
    REF "v-${VERSION}"
    SHA512 f50bb7464e3ad331812caf9839f6e0ce75e3b3f7891b94ed47cce49373fc7cfde04e858e45ef0154962e84701ae2452d479601951d4587d9936e1ff4f38e2cd0
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