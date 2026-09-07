vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Sigmyne/redisx
    REF "v${VERSION}"
    SHA512 518a7b55c0d16de7ca916f5bc71e43084eba7e4becd3cf7968ea912fc3c681d758ee4221d45c07ba040402b4fba4a61d18152acac4a4ca16b4d69d9a2f9904b6
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tls              ENABLE_TLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_CLI=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/redisx" PACKAGE_NAME "redisx")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
