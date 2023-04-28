vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  afterstep/afterstep
    REF f6da4b795204b390cea6e2f60ad9cf09237c85de
    SHA512 bc0c49dc359066e1ef8eb664f77f6c492551ce30890ec0a507f02c39cde8e791957a84ad749cdf5eaadc8b17991818fe6e09414df401c601285f90863cd76b25
    HEAD_REF master
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}/libAfterImage"
    AUTOCONFIG
    COPY_SOURCE
    OPTIONS
        --without-afterbase
        --with-jpeg
        --with-jpeg-includes=${CURRENT_INSTALLED_DIR}/include
        --with-png
        --with-png-includes=${CURRENT_INSTALLED_DIR}/include
        --with-tiff
        --with-tiff-includes=${CURRENT_INSTALLED_DIR}/include
        --with-ttf
        --with-ttf-includes=${CURRENT_INSTALLED_DIR}/include
        --with-svg
        --enable-staticlibs
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

