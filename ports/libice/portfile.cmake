if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_download_distfile(
    LIBICE_ARCHIVE
    URLS "https://www.x.org/releases/individual/lib/libICE-${VERSION}.tar.xz"
    FILENAME "libICE-${VERSION}.tar.xz"
    SHA512 340f51ffa1f14ed442ab8bcea92dd63df147c48242e232e818cafe02f43de7ab6e99c5430b9cb8d0dc661295239d2b3f6bdb6a092ce51a98afa06235257e9b1f
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${LIBICE_ARCHIVE}"
    PATCHES
        fix_build.patch
        replace_macros.patch
)

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
