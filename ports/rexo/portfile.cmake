vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "christophercrouzet/rexo"
    REF "v0.2.0"
    SHA512 "f22ca5be1b5d1a5159377609d2b666eaa69643281294202d2c37b8ab5c9d28acd5b67c2a3d5a0c4e6bae487b9ceff00a11dae1847e7a1e5f72193d9ad34b1457"
    HEAD_REF "main"
    PATCHES
        fix-include-path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DREXO_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

configure_file("${SOURCE_PATH}/UNLICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
