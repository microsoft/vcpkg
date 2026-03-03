if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_download_distfile(
    LIBXPRESENT_ARCHIVE
    URLS "https://www.x.org/releases/individual/lib/libXpresent-${VERSION}.tar.xz"
    FILENAME "libXpresent-${VERSION}.tar.xz"
    SHA512 7e12c386e5d1404db359f8004a141223b4c08a138a5589d087537ca667e9dd5cdc190f170a5fa991c1f8dd022896bb07bff540e262a0d30d542a3faea06d8c93
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${LIBXPRESENT_ARCHIVE}"
)

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
