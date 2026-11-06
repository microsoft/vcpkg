set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Exiv2/exiv2
    REF v0.28.7
    SHA512 b53f4989abcd5d346f2a9c726a06707c47e1990ecb2e5e193c963e01d452fefe4dddd14e25eb08ef35e2f8288b8ec4bdee60725aa7dcd6b1c0348ed56c803fc0
    HEAD_REF master
)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-DSOURCE_PATH=${SOURCE_PATH}"
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)
vcpkg_cmake_build()
