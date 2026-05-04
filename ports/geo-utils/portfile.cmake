vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gistrec/geo-utils
    REF "v${VERSION}"
    SHA512 9955a991c52634ff9c98b69ed2e7b55eb15e8ece0eff059a0dd8173c3e4e2b51044ea637365722a532de62309aa68109abda1aa1018561d3596944b8cf760ede
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGEO_UTILS_BUILD_TESTS=OFF
        -DGEO_UTILS_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/GeoUtils PACKAGE_NAME GeoUtils)

# Header-only — no compiled artifacts to keep
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
