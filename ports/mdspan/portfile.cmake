vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kokkos/mdspan
    REF "mdspan-${VERSION}"
    SHA512 d0e247b5ed5765f3ddd04634462c428b19beceb81b0b7d8221443b3f6ab122e232e85c15d56c208b244be2f6667d7e1db571848b61190b64ec110f7d31c3e0c9
    HEAD_REF stable
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mdspan)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
