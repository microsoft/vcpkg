vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tehreer/SheenBidi
    REF "v${VERSION}"
    SHA512 67c8ef7bea9fc677fbb83601403b40bcc274842597df53a699fd5758f4f170ac5d1fc9a719d590da25f6a72769fe59a2a1cf57e54f0ef6859561bfb77c0c72c4
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "text-api" SB_CONFIG_EXPERIMENTAL_TEXT_API
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSB_CONFIG_UNITY=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SheenBidi)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
