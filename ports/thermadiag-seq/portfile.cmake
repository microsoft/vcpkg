vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Thermadiag/seq
    REF "v${VERSION}"
    SHA512 2f5e791f6dcc59985c89b83e43e360cd545a24a94f317fb20e744c985ed93a30579885539d11b446d8b90edc8860394e4dd073f20c751ceeb94dc43367c17459
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
