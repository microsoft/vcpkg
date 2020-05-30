set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO data/cursors
    REF  28ade0ae2f0237303ca188b62fdb2bd02486ec34 #1.0.6
    SHA512 1291b813ca73eee67172b6f20e762d21614ed812e381c2e4833bb58d2d20f621525a4a66449e80fdccb4e91ba847363b6b2d218c9b0922fed55e5ee72198d888
    HEAD_REF master # branch name
    #PATCHES example.patch #patch name
) 

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

set(ENV{XCURSORGEN} "${CURRENT_INSTALLED_DIR}/tools/xcursorgen/bin/xcursorgen${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)


# # Handle copyright
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}/")
file(TOUCH "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright") #already installed by xproto


