vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO z4kn4fein/cpp-semver
    REF "v${VERSION}"
    SHA512 15555d3082c40edbd9647ee6faafd65324fdd9c2bfee84b95da64b3d369c3e5e28cde8f47035fc592e82007390d31825fc7284aa5f13e2721983c29cdab9156b
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSEMVER_BUILD_TESTS=OFF
)
vcpkg_cmake_install()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
