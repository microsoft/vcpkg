vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mchehab/zbar
    REF "${VERSION}"
    SHA512 d73d71873bec68ee021997512a9edbd223f5f5fe43c66c4dd3502224ba6009be2e5e1714766cb8e1056244673e87e0939ed0319116f61d7371b5ab79fb5e04eb
    HEAD_REF master
    PATCHES
        c99.patch
        issue219.patch
        windows.patch
        x64.patch
)

vcpkg_list(SET options)
if("nls" IN_LIST FEATURES)
    vcpkg_list(APPEND options "--enable-nls")
else()
    vcpkg_list(APPEND options "--disable-nls")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${options}
        --without-dbus
        --without-gtk
        --without-imagemagick
        --without-java
        --without-jpeg
        --without-python
        --without-qt
        --disable-video
        --without-xv
    OPTIONS_RELEASE
        --disable-assert
)

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
    "${CURRENT_PACKAGES_DIR}/tools"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
