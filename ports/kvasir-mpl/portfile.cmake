vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kvasir-io/mpl
    REF  a9060b46c37c769e5517e0116b060fec923b6fdb
    SHA512 bbe7267d288eda9ded81ce82e428d237cb5a9d686cd1b68a334b1ae53db4bf25e37fb86d991e7cf61542ee91ccae8db7498efde91a07332fd68594a229ff35ca
    HEAD_REF development
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS FEATURES
    test   BUILD_WITH_TEST
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DBUILD_TESTING=${BUILD_WITH_TEST}
)

vcpkg_cmake_install()

# Move CMake config files to the right place
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/kvasir_mpl)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)