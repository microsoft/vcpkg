vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Thermadiag/seq
    REF "v${VERSION}"
    SHA512 a784727e9b720e811ffd4431b194305fdabd5719abeb69df6d6a85e4f16f796ab702e1c4790a3509f70f52d00f38b1775daab33648b781b7771d165c328692f8
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
