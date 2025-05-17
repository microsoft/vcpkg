vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Raminkord92/PDFxTMD
    REF "v-${VERSION}"
    SHA512 60a18d787a52cd400dedc2f222f1ba3574c9968bd426df5d2f627570ef79f423e191674c880dccee37a799b6d09b3c15e3ccb32b6da9c11cdf1ba0808d2ef721
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