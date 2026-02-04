vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gul-cpp/gul17
    REF "v${VERSION}"
    SHA512 e9da84a4eac1ecaa65d31034a746289b8e168a146cf878ffae9c91ab8d196aa516b598583908ea0adfcc6887843199795c49adca11479564814637dd2f69f5c3
    HEAD_REF main
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -Dtests=false
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

# Install copyright file
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
