vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libexif/libexif
    REF "v${VERSION}"
    SHA512 c586cf0b31bcdae126943453af8b2631c96a6854c10e6370772f61d1e38a8f8353536ff50c4222956e5bb5908c687c58e8ceb092e105bd0e5325994a34f28324
    HEAD_REF master
    PATCHES
        fix-ssize.patch
)

vcpkg_list(SET options)
if("nls" IN_LIST FEATURES)
    vcpkg_list(APPEND options "--enable-nls")
else()
    vcpkg_list(APPEND options "--disable-nls")
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        ${options}
        --enable-internal-docs=no
        --enable-ship-binaries=no
)

vcpkg_make_install()
vcpkg_fixup_pkgconfig()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-libexif-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
