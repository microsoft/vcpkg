vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO driver/xf86-input-keyboard
    REF  0c7f51291f91eee61fcaf05080001a5e9b22fb53 #1.9.0
    SHA512 bc0dcdd932ccc473ca7182523561ed5a777b5be385bdec1d091bf0e48124a1bb22a29ec47d15f72a837d7dfb41adb94c7d1cee6a1c0157c4dc02224f8a47d64c
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
    #PRERUN_SHELL ${SHELL_PATH}
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


