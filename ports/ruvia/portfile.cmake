vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hyird/Ruvia
    REF "v${VERSION}"
    SHA512 ed759f9b39d984d3873c58e9e1e2c4925bb69e9123fcf7338dbf73e8738693a3d6c78cbeaf469a00a5b4f44927fc2b5893990fc86adc47a08b50950d93e315f1
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
