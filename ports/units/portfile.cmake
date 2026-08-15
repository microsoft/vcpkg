vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nholthaus/units
    REF v${VERSION}
    SHA512 547ff44975ed502b3b02d90fe502ccbf21e2610ad4ec025fe1b7d829f60c91e43dfd2eba31ae63b2453bcd751baec2b87027742a7259ac9af6ac12d68eee33ea
    PATCHES
        fix-project-version.patch
)

set(VCPKG_BUILD_TYPE "release")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUNITS_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/units)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")  # from CMake config

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
