if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_download_distfile(
    LIBXCOMPOSITE_ARCHIVE
    URLS "https://www.x.org/releases/individual/lib/libXcomposite-${VERSION}.tar.xz"
    FILENAME "libXcomposite-${VERSION}.tar.xz"
    SHA512 24a03e3242f22b113aa6a3f9341858c072730f0f0073a1a7b9d36b982cd5b77223151aad32b61d1a38bbcb9f8ffedaf67b882dcb95f197d80ece9dbc99332c36
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${LIBXCOMPOSITE_ARCHIVE}"
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
