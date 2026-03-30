set(VCPKG_BUILD_TYPE release) # header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MitchellThompkins/consteig
    REF "${VERSION}"
    SHA512 7edee6224fd819b8a6c280c0644dd74bd268e19507281baec07f92bb783eae6347467c16f22c1ebd83a3090af07ae64c27e17d4ffbc765f16a327748b030a4e6
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCONSTEIG_VERSION="${VERSION}"
        -DCONSTEIG_BUILD_TESTS=OFF
        -DCONSTEIG_BUILD_EXAMPLES=OFF
        -DCONSTEIG_BUILD_PROFILING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/consteig)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
