if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_download_distfile(
    LIBXXF86VM_ARCHIVE
    URLS "https://www.x.org/releases/individual/lib/libXxf86vm-${VERSION}.tar.xz"
    FILENAME "libXxf86vm-${VERSION}.tar.xz"
    SHA512 7fb3ac4302eea43b70d5106f6c7a113e28e2807da22d2bb7f040e0c4afd322cad4b7f258a5bd6da3940b6b6b39065e1acb218a6dc0ba06b9dd86ea3849231266
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
