if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_download_distfile(
    LIBXDAMAGE_ARCHIVE
    URLS "https://www.x.org/releases/individual/lib/libXdamage-${VERSION}.tar.xz"
    FILENAME "libXdamage-${VERSION}.tar.xz"
    SHA512 9406e39cbc426d7fa3c66bf1eec202fdb5af5db99a0ff49c2be995b1ff7326a6c1fb395c46391e1c32f5a6569a5d6e02bdd5b79fc79dd468fc3ebd698496bbc2
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${LIBXDAMAGE_ARCHIVE}"
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
