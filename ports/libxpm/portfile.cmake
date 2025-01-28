if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxpm
    REF "libXpm-${VERSION}"
    SHA512 30d473b6184d56643114ab1f7719f033ac5ecfd9fd46ebefc03db171a82a809d996046a039c922c184046310fc12a088467ca73740386b3e73b1e699bde78db7
    PATCHES
        remove_strings_h.patch
        fix-dependency-gettext.patch
        strcasecmp.patch
        subdirs.diff
        tools.patch # will look for libxt otherwise
)

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

if ("gettext" IN_LIST FEATURES)
    set(EXTRA_OPTIONS --with-gettext=yes)
else()
    set(EXTRA_OPTIONS --with-gettext=no)
endif()

vcpkg_configure_make(
     SOURCE_PATH "${SOURCE_PATH}"
     AUTOCONFIG
     OPTIONS
        ${EXTRA_OPTIONS}
 )

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
