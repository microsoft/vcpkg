vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zint/zint
    REF 2.12.0
    SHA512 398502efc1f07718e7c86a1e91f6e94c88b7f7c5e3c59fd507f3a5966488f4b0bb230ae9696515583aa536e2357c9a6295be7de6b4bc83daf5b4eb3be5e69b24
    HEAD_REF master
    PATCHES
        0004-windows-static-build.patch
        0005-export-include-directories.patch
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
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES zint AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/apps")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
