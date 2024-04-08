vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO absurdworlds/awlib
    REF ${VERSION}
    SHA512 bfb4668abc3db176744bb674a20bf770c6406db522a14191069b8d833414285ca784f042c3ad50404f7f8bc76afe69627dfcf540080e12316abbbfe420955526
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    hudf             AW_ENABLE_HUDF
    graphics         AW_ENABLE_GRAPHICS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/${PORT})

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()
