vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arximboldi/lager
    REF v${VERSION}
    SHA512 ac942a55c2cdc5cb8846534f772e13d9395d8762298978a0edfa84c6282fa83fa5105160ad65fff5170e6861568228ce9d20d1b44617b006ca3c4e57e1964d54
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        docs  lager_BUILD_DOCS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dlager_BUILD_EXAMPLES=OFF
        -Dlager_BUILD_TESTS=OFF
        ${FEATURE_OPTIONS}
)


vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Lager)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/lager/resources_path.hpp" "${CURRENT_PACKAGES_DIR}" ".")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
