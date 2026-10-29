vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO efficient/libcuckoo
    REF ea8c36c65bf9cf83aaf6b0db971248c6ae3686cf
    SHA512 5c36ebf6047afb3fa980049dc2e38b8e34443d40cff7ba9b7ee1fa8b78ff3dd92b2d0a346667a71eec6d0bfc917b3080c883146f97681f20f71ce618eac3f37f
    HEAD_REF master
)

# header-only library
set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_STRESS_TESTS=OFF
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_UNIVERSAL_BENCHMARK=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/${PORT})

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
