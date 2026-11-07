vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Sigmyne/xchange
    REF "v${VERSION}"
    SHA512 26eb7d94358a34426492b1effaf57eaad27f7269928711f1b224afe57996ca9ab20b787393bb703da5d5613f8aa9d441dd94b9daa16511367fe469486c9d08f2
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/xchange" PACKAGE_NAME "xchange")

set(debug_pc "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/xchange.pc")
if(EXISTS "${debug_pc}")
    vcpkg_replace_string("${debug_pc}" "-lxchange " "-lxchanged ")
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
