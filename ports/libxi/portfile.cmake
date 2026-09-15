if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_download_distfile(
    LIBXCOMPOSITE_ARCHIVE
    URLS "https://www.x.org/releases/individual/lib/libXi-${VERSION}.tar.xz"
    FILENAME "libXi-${VERSION}.tar.xz"
    SHA512 5fb8273424467c102d3bab01cb273169038ff6fae739f6873ca357be8890c4fd30ba2952bca2759249458796df53ad130e2c9c3674b385602afd13c718faf79a
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${LIBXCOMPOSITE_ARCHIVE}"
    PATCHES
        fix-configure.patch
)

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

if (VCPKG_CROSSCOMPILING)
    list(APPEND OPTIONS --enable-malloc0returnsnull)
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        --with-asciidoc=no
        --with-fop=no
        --with-xmlto=no
        --with-xsltproc=no
        ${OPTIONS}
)

vcpkg_make_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
