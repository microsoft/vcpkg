#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO greg7mdp/gtl
    REF v1.1.5
    SHA512 87666a975d3e355d24463f31bd7fe9796eb9e90b557b678807432fc3797a2b501e76acefae490cbaa503f993efe7f44c04a7cc8bd48662c38293c90741c8f7df
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
