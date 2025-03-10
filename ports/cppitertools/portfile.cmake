vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ryanhaining/cppitertools
    REF "v${VERSION}"
    SHA512 27b6b50e5cbb901a844adf65f2c3ad27368907acfc972267b51700b8f2d3d2205a0da4f130f88c0df791d23d84198083caffbf54ab5114354ddc43728538f44c
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dcppitertools_INSTALL_CMAKE_DIR=share
)

vcpkg_cmake_install()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/share/cppitertools-config-version.cmake")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/cppitertools"
    RENAME copyright)
