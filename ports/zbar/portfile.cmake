vcpkg_fail_port_install(ON_TARGET "Windows" "OSX")

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zbar/zbar
    REF 0.10
    SHA512 76cb8a469e3ac9ea7932a95c500cf933501249cdb8dce4df558bf5681bd44c62111327b494e6e887079a5fd30b32154887dcc12962e6d27b1453f55457483db4
    FILENAME zbar-0.10.tar.bz2
    PATCHES
        fix-build-error.patch # https://github.com/ZBar/ZBar/pull/9/files
        disable-warnings.patch
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
        --disable-video
)

vcpkg_install_make()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/tools"
    "${CURRENT_PACKAGES_DIR}/share/zbar/man1"
    "${CURRENT_PACKAGES_DIR}/share/zbar/zbar"
)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/zbar" RENAME copyright)