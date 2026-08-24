set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-shm
    REF "v${VERSION}"
    SHA512 39504cf5552c84032046137fd91ae01c0545da93ecaae68aac39edcbe9d24a1ce2d8112167511807fa14144a145bbb57c1572f68121b27af2222a522999afa97
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
