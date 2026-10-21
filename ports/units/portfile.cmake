vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nholthaus/units
    REF v${VERSION}
    SHA512 69fe6641c465c3a9a675babc3c63c4097c1137f7e893eb06ec3687f60fecd9df0731dbc5e3414e3192b5b90c771a8ec6096c5386f57f29e72156dedce6e39306
)

set(VCPKG_BUILD_TYPE "release")

# units is header-only. Turning tests off also turns the examples off (they follow UNITS_BUILD_TESTS), so the
# configure step compiles nothing and the install stages only the header tree and the CMake package files.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUNITS_BUILD_TESTS=OFF
        -DUNITS_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/units)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib") # header-only: no libraries, only the CMake config moved above

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
