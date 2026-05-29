vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xqq/libaribcaption
    REF "v${VERSION}"
    SHA512 3f3c802ae68734126d9b4a0525b3353af4c1a3807cd21bfa04b89f2092fe565cb2413bcdd0b762313d40b7e0ab75c7e8066bf4a1879c16637f35ee164f6ef6a4
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
