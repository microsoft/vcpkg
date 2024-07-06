vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO maxbachmann/rapidfuzz-cpp
    REF "v${VERSION}"
    SHA512 c9cc50f7d68756d81a5d2c5efdd76e859fe5a199bf5e45179effcd85e32f0bb98b593b93c2aa57950a04c3d827af98efb13096b9669329881d658ababc059fd5
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
