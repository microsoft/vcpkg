vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DavidPetkovsek/semver
    REF "v${VERSION}"
    SHA512 7edb53250ab4bf0a4960449ff475abc9b9ee51210cba658db790904161c2a0515a9204d9039597b29281a2c0084d2f9304eca13771a63147040c7904eb057044
    HEAD_REF main
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SEMVER_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSEMVER_BUILD_SHARED=${SEMVER_SHARED}
        -DSEMVER_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME dpetkov-semver
    CONFIG_PATH lib/cmake/dpetkov-semver
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
