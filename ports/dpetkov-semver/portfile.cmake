vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DavidPetkovsek/semver
    REF "v${VERSION}"
    SHA512 f41100b989097f8091053cbacf5f1ac8a96dd1e0c0b406ab063fd45e289dcb90428e187315c2257877c145212d5dab66e02ea9bde063c34fbdf27c09ffcd5182
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
    PACKAGE_NAME semver
    CONFIG_PATH lib/cmake/semver
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")