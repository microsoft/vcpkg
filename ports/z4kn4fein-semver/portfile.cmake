vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO z4kn4fein/cpp-semver
    REF v0.2.1
    SHA512 1eac4bfc87d8719c3172a32897ff50063959faee0df747cb9b45a1bc32dd4f2a2e4f6ac5700e99854f9c06e7e70f3bfbc4a1bedbb99730fef06c0e587f4614ff
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSEMVER_BUILD_TESTS=OFF
)
vcpkg_cmake_install()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
