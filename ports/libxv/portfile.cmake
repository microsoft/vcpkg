set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_download_distfile(
    LIBXV_ARCHIVE
    URLS "https://www.x.org/releases/individual/lib/libXv-${VERSION}.tar.xz"
    FILENAME "libXv-${VERSION}.tar.xz"
    SHA512 80d7a11e6415fbe0fc50c3c2a1abf8f0f2ec38446c9c8d88ff48875cd94b8949cb1028f2ab37476c4b25cbd7eac34dde9132dd998c4e04ea576b95ae411ba946
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${LIBXV_ARCHIVE}"
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
