vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LibreCAD/libdxfrw
    REF 92d7466ed9146badcd4fb44c82d1dd8302b3c7db
    SHA512 2c65780dc378221489d860a4c13799e57c1d4375ac1df187a55e675d9a509896f300980b0f75d0d8dda837a6e335c19f8c23131577b962e92e04140e903e50ac
    HEAD_REF master
    PATCHES
        remove-werror.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dwg2dxf LIBDXFRW_BUILD_DWG2DXF
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBDXFRW_BUILD_DOC=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

if("dwg2dxf" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES dwg2dxf AUTO_CLEAN)
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/libdxfrw")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
