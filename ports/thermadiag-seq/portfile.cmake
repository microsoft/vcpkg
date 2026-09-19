vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Thermadiag/seq
    REF "v${VERSION}"
    SHA512 2973ee803ccd480fda51fe8be2cfaf811578da129a7122e87e41e7e90298db95b39840845b6104fbd920c6d0fa37d1c8df0ff16dfb20887f1c9023331484b592 # Temporary blank hash
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DSEQ_BUILD_TESTS=OFF
    -DSEQ_BUILD_BENCHS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME seq CONFIG_PATH lib/cmake/seq)
vcpkg_fixup_pkgconfig()
file(RENAME "${CURRENT_PACKAGES_DIR}/share/pkgconfig/seq.pc" "${CURRENT_PACKAGES_DIR}/share/pkgconfig/${PORT}.pc")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
