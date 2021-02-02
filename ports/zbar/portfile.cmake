vcpkg_fail_port_install(ON_TARGET "Windows" "OSX")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ZBar/ZBar
    REF 67003d2a985b5f9627bee2d8e3e0b26d0c474b57
    SHA512 680fba4674d610e1eb5e5f746dba13c08befc555bb53cd2b0fa2654225ad3c7bf32c9cd15235c0b3eb5b96fc8cbecf2da721f85b074a025802ad23191847e168
    HEAD_REF master
    PATCHES
        fix-build-error.patch # https://github.com/ZBar/ZBar/pull/9/files
        disable-warnings.patch
        fix-install-doc.patch
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --with-zlib-prefix=${CURRENT_INSTALLED_DIR}
        --with-libpng-prefix=${CURRENT_INSTALLED_DIR}
        --without-qt
        --without-gtk
        --without-imagemagick
        --without-python
)

vcpkg_install_make()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/zbar" RENAME copyright)