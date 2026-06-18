vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zint/zint
    REF ${VERSION}
    SHA512 819d1f91186106acf7dacada85b69e409358e3d39ad9b714297d00168c76d363f92c12c57ca8b11bc08fbe2c078ed4ac5c0cfc0e3e6391048acafa59b662c098
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        png ZINT_USE_PNG
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ZINT_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ZINT_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DZINT_STATIC=${ZINT_STATIC}
        -DZINT_SHARED=${ZINT_SHARED}
        -DZINT_USE_QT=OFF
        -DZINT_TEST=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/zint)
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES zint AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/apps")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
