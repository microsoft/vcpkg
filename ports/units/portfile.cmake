vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nholthaus/units
    REF v${VERSION}
    SHA512 ea1db481723a60a50327e986eea6a160ac8fb4b43f0a4684e89463de5ec2ba0198611e806ab14a3e5225573e0f828741db82c462c2c463dd5294d210b9c591c0
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
