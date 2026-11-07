set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO greg7mdp/parallel-hashmap
    REF "v${VERSION}"
    SHA512 373928a769bce519aa321b92a855838e663d4ccf123de0e9f66ac7ced28fda2aeb299085532f7d4867a630c06ed2a5c6ee32aadb692887d496e156c0c0b1f83d
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPHMAP_BUILD_TESTS=OFF
        -DPHMAP_BUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()

file(COPY "${SOURCE_PATH}/phmap.natvis" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
