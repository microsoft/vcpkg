## requires AUTOCONF, LIBTOOL and PKCONF

file(GLOB_RECURSE _xorgfiles "${CURRENT_INSTALLED_DIR}/share/xorg/*")
message(STATUS "############# xorg files: ${_xorgfiles}")
file(GLOB_RECURSE _xcbfiles "${CURRENT_INSTALLED_DIR}/share/xcb/*")
message(STATUS "############# xcb files: ${_xcbfiles}")
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxcb
    REF  8287ebd7b752c33b0cabc4982606fe4831106f7e #v1.13.1 
    SHA512 625939b67d129f681503a2f784daa75897b31b09daba0b9ea72457c9dffdab34a644c0b73068282de01ddfdcd5fc29242e4db5367d39b795984374846c1319c8
    HEAD_REF master # branch name
    #PATCHES example.patch #patch name
) 

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
file(TO_NATIVE_PATH "${PYTHON3_DIR}" PYTHON3_DIR_NATIVE)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    #SKIP_CONFIGURE
    #NO_DEBUG
    #AUTO_HOST
    #AUTO_DST
    #PRERUN_SHELL ${SHELL_PATH}
    #OPTIONS
    #OPTIONS_DEBUG
    #OPTIONS_RELEASE
    PKG_CONFIG_PATHS_RELEASE "${CURRENT_INSTALLED_DIR}/lib/pkgconfig/"
    PKG_CONFIG_PATHS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig/"
)
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/xcb/")
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
