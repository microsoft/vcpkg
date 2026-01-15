vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arximboldi/lager
    REF v${VERSION}
    SHA512 072371ca85f1e2cf915513c9d5bf56795fd871e5ccc174847286dc0ecadf9a34acf8b359404c2d47282cd61cb79f4fcff13dc544f321ef37c2cd5ae7c5fe78d6
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
