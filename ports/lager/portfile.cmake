vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arximboldi/lager
    REF 2016df38be90ee176bcb73ea414be2318bc1ef31
    SHA512 07d9f2cf128ad2e751abbfaa03969524ffba785ac2696e6b94ee8e28166fc3ab427de2fc6a98eba50d2f936879b9e878a011c3ba9a25ba39109e7939d39c4902
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
