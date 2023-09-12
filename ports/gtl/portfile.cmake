#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO greg7mdp/gtl
    REF "v${VERSION}"
    SHA512 c6ab1ae6bfdee7f4fa49ab6ea27138cfe7159b5b0fb918a65f27cc7fff74e632f2567508453d1767bc406ac6286ff3a12edeffd185b5b2acf0ef304d4175b86e
    HEAD_REF main
)

# Use greg7mdp/gtl's own build process, skipping examples and tests
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGTL_BUILD_TESTS=OFF
        -DGTL_BUILD_EXAMPLES=OFF
        -DGTL_BUILD_BENCHMARKS=OFF
)
vcpkg_cmake_install()

# Delete redundant directories
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/share/doc")

# Put the licence file where vcpkg expects it
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
