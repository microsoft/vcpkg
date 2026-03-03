if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_download_distfile(
    LIBXSCRNSAVER_ARCHIVE
    URLS "https://www.x.org/releases/individual/lib/libXScrnSaver-${VERSION}.tar.xz"
    FILENAME "libXScrnSaver-${VERSION}.tar.xz"
    SHA512 1c0be0d15c5e7b50a3eb4a239e2c833c44b693b111c7f64c409f9abf8051356572acadebc8b295555683ff6bd4895acdbe32b15a538c971f15d8aa4e6b7fd51b
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${LIBXSCRNSAVER_ARCHIVE}"
)

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

if (VCPKG_CROSSCOMPILING)
    list(APPEND OPTIONS --enable-malloc0returnsnull)
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS ${OPTIONS}
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
