if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_download_distfile(
    LIBXINERAMA_ARCHIVE
    URLS "https://www.x.org/releases/individual/lib/libXinerama-${VERSION}.tar.xz"
    FILENAME "libXinerama-${VERSION}.tar.xz"
    SHA512 64bff837941625120da43b8876db4204bc5740bcf3147997fc4df1475f90d6d9e3f9caa8748c7ebbf69d681be8e5ab4bc40f82c56c367dddcec3ab27d1c71573
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${LIBXINERAMA_ARCHIVE}"
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
