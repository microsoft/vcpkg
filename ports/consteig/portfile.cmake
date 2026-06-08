set(VCPKG_BUILD_TYPE release) # header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MitchellThompkins/consteig
    REF "${VERSION}"
    SHA512 5ac9458afcdf3e4dd9827eadfc84e0328b60bf9f075ec743d7517ad2205bd7d9a11b0b154ca5be1d1e61273700743379c1118be6ca5b50cbb6c9c3f41224dc97
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCONSTEIG_VERSION=${VERSION}"
        -DCONSTEIG_BUILD_TESTS=OFF
        -DCONSTEIG_BUILD_EXAMPLES=OFF
        -DCONSTEIG_BUILD_PROFILING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/consteig)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
