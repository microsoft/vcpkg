if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_download_distfile(
    LIBXXF86VM_ARCHIVE
    URLS "https://www.x.org/releases/individual/lib/libXxf86vm-${VERSION}.tar.xz"
    FILENAME "libXxf86vm-${VERSION}.tar.xz"
    SHA512 d1051c9698a884d86e5beb00d5ee148d2b5ded7fd05168861f722b89643ad9b7f7d220f0cbb64b290a69faf9a6630181533aaddb01c9c68b46f1e5625030f094
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${LIBXXF86VM_ARCHIVE}"
)

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

if(VCPKG_CROSSCOMPILING)
    set(OPTIONS --enable-malloc0returnsnull=yes
                xorg_cv_malloc0_returns_null=yes)
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
