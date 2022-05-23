# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arximboldi/immer
    REF a1271fa712342f5c6dfad876820da17e10c28214
    SHA512 7ea544c88b7a3742ebeedabe5ff7ba78178b3523c1c8564b5c0daae4044dda22340b0531e1382618557d1c118222da4a7ce06dde02e4bc05833514dde1cf2dd1
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
