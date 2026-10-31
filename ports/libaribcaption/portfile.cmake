vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xqq/libaribcaption
    REF "v${VERSION}"
    SHA512 78937780b3295ec1179dfb6d0859add2c6c6338093a8f7322e786b56a0bf9618e1ea8b8b2d8aa5a4cee4c30721528765535fbe26d2ddf05514c4e4fe39452dd5
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gdi      ARIBCC_USE_GDI_FONT
    INVERTED_FEATURES
        renderer ARIBCC_NO_RENDERER
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ARIBCC_SHARED_LIBRARY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DARIBCC_BUILD_TESTS=OFF
        -DARIBCC_SHARED_LIBRARY=${ARIBCC_SHARED_LIBRARY}
        -DARIBCC_USE_EMBEDDED_FREETYPE=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME aribcaption CONFIG_PATH "lib/cmake/aribcaption")

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
