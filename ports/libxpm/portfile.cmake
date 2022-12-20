if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxpm
    REF libXpm-3.5.14
    SHA512 1ae8c48b0d928265cfc6baac1286f241f20e70c88d6f9b6881ccccd7f2e290ca0afaf0f3a051ad5526449dec93c6cc41c48bb6e488e29e2baec87238f17f6bcf
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