## requires AUTOCONF, LIBTOOL and PKCONF
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libinput/libinput
    REF 5b500c0e744db962fceadccd029fd5075654f4bc # 1.3.4 
    SHA512  fb89248ca67996fe1b5bd42162153b7b913ced2a7f85b8f3b1e9feb2f1a298907d4a04c3b3cc67417553c8f4e82f74454e3febf5ec187e16969456bb89c55d60
    HEAD_REF master # branch name
    #PATCHES example.patch #patch name
) 

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -Dtests=false
            -Ddocumentation=false
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES pthread)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
