vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO peter-winter/ctpg
    REF "v${VERSION}"
    SHA512 630fb49e0dd46dfede6ea8ae1b62019e2b3119ff18abe0e398a771d83d9980e4e47f57d500f2d69d34ef7f4653e4a5edcdacf0634fcd014c6bdb2824023a96a4
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCTPG_ENABLE_INSTALL=ON
        -DCTPG_ENABLE_TESTS=OFF
        -DCTPG_INSTALL_CMAKEDIR="${CURRENT_PACKAGES_DIR}/share/${PORT}"
        -DCTPG_WARNING_FLAGS=OFF
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
