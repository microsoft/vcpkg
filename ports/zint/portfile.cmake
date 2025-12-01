vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zint/zint
    REF ${VERSION}
    SHA512 70838fdc88aa8e157ce8a0099fe1184b98c8e5fd0a980a8ecdb40d7e4cbf1519b99a2326ffe7a1b3272dc58aa20fafa06fa0d3e6fb26f445eaa59b4b20be18cc
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
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES zint AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/apps")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
