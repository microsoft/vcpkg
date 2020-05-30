vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO app/xcursorgen
    REF 291d9a052aec0ad4a315c09a9af8b451c94ed57a 
    SHA512  eb834227020d2158d33ca2c9683592572bdba2ca9b6e5f940171ad13a4c3d893447cf261e679fc1e67f46e1fc86804e14abf3275d29055aa6996d502fc367970
    HEAD_REF master # branch name
    #PATCHES example.patch #patch name
) 

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    #SKIP_CONFIGURE
    #NO_DEBUG
    #AUTO_HOST
    #AUTO_DST
    #PRERUN_SHELL "export ACLOCAL=\"aclocal -I ${CURRENT_INSTALLED_DIR}/share/xorg-macros/aclocal/\""
    #OPTIONS
    #OPTIONS_DEBUG
    #OPTIONS_RELEASE
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

