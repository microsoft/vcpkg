if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_download_distfile(
    LIBXRES_ARCHIVE
    URLS "https://www.x.org/archive/individual/lib/libXres-${VERSION}.tar.xz"
    FILENAME "libXres-${VERSION}.tar.xz"
    SHA512 385dbc87bd4e0d306a1cad6b317d8431494cd2a381766bc3f9e6b7f488ff41ee1f4f25e756421f6a2b5681976d7da0108cea6305f7a34f7105d861cb6c1ae854
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${LIBXRES_ARCHIVE}"
    PATCHES
        build.patch
)

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

if (VCPKG_CROSSCOMPILING)
    list(APPEND OPTIONS --enable-malloc0returnsnull)
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS ${OPTIONS}
)

vcpkg_make_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
