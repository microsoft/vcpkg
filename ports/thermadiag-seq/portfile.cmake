vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Thermadiag/seq
    REF "v${VERSION}"
    SHA512 e76468c46f95200fdb4f6e8b7389a86b25702c702096e4c8b1022e086141f91e695dd8b2cb072be0b8ed2e68de1c753d1b69758a466301e609d5b11e99fa13b1
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

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/LICENSES/komihash.txt"
        "${SOURCE_PATH}/LICENSES/sse2neon.txt"
)
