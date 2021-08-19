# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arximboldi/immer
    REF a11df7243cb516a1aeffc83c31366d7259c79e82
    SHA512 7aefa894d57167e8606ffd20c78490731885da610da084ffdc4ee677e40c7a3b4edcd0fbf74e354fc68866d09ec7a35a7c549f78ce91f2f1a84bb6ccc605e135
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "docs"  immer_BUILD_DOCS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_PYTHON=OFF
        -DENABLE_GUILE=OFF
        -DENABLE_BOOST_COROUTINE=OFF
        -Dimmer_BUILD_TESTS=OFF
        -Dimmer_BUILD_EXAMPLES=OFF
        -Dimmer_BUILD_EXTRAS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Immer)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
