vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brevzin/rivers
    REF cfbd4c3e0ca9fcde03075327d6dd628e57589342
    SHA512 4dfa4a1e657c6a12446abe6d7c54d5bc3d47d82e8639eb91f98c7120b3ca79a6cfa761a357dc2285027823177ee76be346adddc7861f0f213cd0bc7cde041ab8
    HEAD_REF main
    PATCHES add-install-configuration.patch
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        fmt RVR_IMPORT_FMT
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT} CONFIG_PATH "lib/cmake/unofficial-rivers")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
