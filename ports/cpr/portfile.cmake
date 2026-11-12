vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libcpr/cpr
    REF "${VERSION}"
    SHA512 e27a0afe02a8a1ff2fdad5d5cda6d4d422c49f4dc76067cc7551979b5f48f8da53950c89442394d4f2ccfe0f87ecb71e375b01bdac20f80d5dab21cc4451b25c
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl CPR_ENABLE_SSL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCPR_BUILD_TESTS=OFF
        -DCPR_USE_SYSTEM_CURL=ON
        -DCPR_WARNINGS_AS_ERRORS=OFF
        ${FEATURE_OPTIONS}
        # skip test for unused sanitizer flags
        -DTHREAD_SANITIZER_AVAILABLE=OFF
        -DADDRESS_SANITIZER_AVAILABLE=OFF
        -DLEAK_SANITIZER_AVAILABLE=OFF
        -DUNDEFINED_BEHAVIOUR_SANITIZER_AVAILABLE=OFF
        -DALL_SANITIZERS_AVAILABLE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cpr)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
