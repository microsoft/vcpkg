if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxpm
    REF "libXpm-${VERSION}"
    SHA512 006d5fb2fd951b8857b8d409d65ebe4f819dc51df3bbe933ef9b879a9dc832b0828481c7c0cac453a82a1e81f39990fc49819314a443a1082bdaea6044bb3013
    PATCHES
        remove_strings_h.patch
        fix-dependency-gettext.patch
        strcasecmp.patch
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

vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES pthread)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static OR NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

#vcpkg_copy_tools(TOOL_NAMES sxpm cxpm AUTOCLEAN)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
endif()
