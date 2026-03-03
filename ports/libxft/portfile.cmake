if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_download_distfile(
    LIBXFT_ARCHIVE
    URLS "https://www.x.org/releases/individual/lib/libXft-${VERSION}.tar.xz"
    FILENAME "libXft-${VERSION}.tar.xz"
    SHA512 493e4475c0eeab04a510819446eaa871ba9e1695e42d05bb7791d2ed59f7faff31e910dae95efa4b0ac4a7a2da38614b5740a4ca9388134bea80d348e9ad57e5
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${LIBXFT_ARCHIVE}"
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
