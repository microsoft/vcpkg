vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hyird/Ruvia
    REF "v${VERSION}"
    SHA512 3b210c8bf8013b6eb72a68b45e2db06597418541b7fb88ce2179f78dd0e109f28bad4bec8d38afe684c0d2e8f3e1e8cfe748f940ebe4dffc59c92a438d06ef57
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        jwt RUVIA_ENABLE_JWT
        mariadb RUVIA_ENABLE_MARIADB
        redis RUVIA_ENABLE_REDIS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DRUVIA_BUILD_EXAMPLES=OFF
        -DRUVIA_BUILD_TECHEMPOWER=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ruvia CONFIG_PATH lib/cmake/ruvia)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
