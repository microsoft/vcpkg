vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arximboldi/lager
    REF bcb36050dc908db538fa965e7387c48e32378330
    SHA512 e7d3ef88ab09604990240d4d656af11a97bdea5011c5d45941f0ce48ce5d1ee54f76f6653200f23544198310b93cec8d014f1210600faaa6b6fbb721558c5ab4
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
