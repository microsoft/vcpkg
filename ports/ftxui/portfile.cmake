vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArthurSonzogni/FTXUI
    REF "v${VERSION}"
    SHA512 14de98770e8a23707455f9197e9ef3b41effc1b5b8a594a7270b1378034720f58b5a81b99653d8b1f04e003565ae4778a1e5a3d756c8cbf297e2d09e327f608e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DFTXUI_BUILD_EXAMPLES=OFF
        -DFTXUI_ENABLE_INSTALL=ON
        -DFTXUI_BUILD_TESTS=OFF
        -DFTXUI_BUILD_DOCS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/ftxui.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/ftxui.pc")
file(RENAME "${CURRENT_PACKAGES_DIR}/lib/ftxui.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/ftxui.pc")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
