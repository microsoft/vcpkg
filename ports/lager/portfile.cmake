vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arximboldi/lager
    REF c87a4c7fd0368bea346f41191b8bc0b54a3e9d80
    SHA512 788586078fdc07f0bd899148ddb0ad255fc6e18254901de65c2d1e43f9637ed8a8c121e8d0d26f043e86c7764ea1ff6ce323a791ba7d577589b4c80a329619d4
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
