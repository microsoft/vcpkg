#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO greg7mdp/gtl
    REF "v${VERSION}"
    SHA512 068d37b7028979538884db5956a76e1de301202eb6b015104c6d8b246e894f9166b1d2b97aff47b2641b6948e7dd1cd20a74396f1a6d276e2ade74469d27c3c2
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
