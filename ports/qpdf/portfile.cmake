vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qpdf/qpdf
    REF "v${VERSION}"
    SHA512 fdd605ef711d313bdec9979cb8cefb2589f45fc1086f9a6f763348b1c098071a085bdbbd2dccd5b17bf212c42374dc86f4c95e3de935df62d259ab110fad0e6b
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/qpdf)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
