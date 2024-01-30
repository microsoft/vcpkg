vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tcbrindle/flux
    REF 1c128b50af95fc39b6683d437f9210239e219836
    SHA512 c07d3053227d6a62f5a7b0aba8535c0ed42195249d131a77989b3ee79a697f8d540b68639dcd9e89b5cdd76ee5d7f07db9b3be23bc325761c85af625f507e393
    HEAD_REF master
    PATCHES
        targets-fixup.patch
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFLUX_BUILD_EXAMPLES=OFF
        -DFLUX_BUILD_TESTS=OFF
)


vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/flux)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
