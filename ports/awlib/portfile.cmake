vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO absurdworlds/awlib
    REF ${VERSION}
    SHA512 096c70759e3243b29132f243cc05a44fa7a6f5e05357dc191296776fa3fc86b5b1aa33367304c845b22bfc7d688ebad9d7e4d7b569d4e133970bd662cbb32ce0
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    hudf             AW_ENABLE_HUDF
    graphics         AW_ENABLE_GRAPHICS
    # awgraphics links awimage and awmesh unconditionally
    graphics         AW_ENABLE_IMAGE
    graphics         AW_ENABLE_MESH
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DAW_MAKE_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/${PORT})

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()
