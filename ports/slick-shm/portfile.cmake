set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-shm
    REF "v${VERSION}"
    SHA512 de5272d222885913d7bd4ea67baae36bcee4493815d9a23813e1eaec93cd79805203dc7fee5d6c934d87c7147e5a6a6f610dbf34b2c69b446a9d7ae1595852c6
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSLICK_SHM_BUILD_EXAMPLES=OFF
        -DSLICK_SHM_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/slick-shm
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
