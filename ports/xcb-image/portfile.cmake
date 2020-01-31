## requires AUTOCONF, LIBTOOL and PKCONF
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxcb-image
    REF  d882052fb2ce439c6483fce944ba8f16f7294639 #v 0.4.0
    SHA512 60d933d60351071fa47540a7943a34fd57bd46ebcd7441020c8f3f0ef4abc44fbb8e86e72e328d64992254ce20d5b718bede9f4994dbd0674fbf5ce88050c307
    HEAD_REF master # branch name
    #PATCHES example.patch #patch name
) 
file(TOUCH ${SOURCE_PATH}/m4/dummy)
set(ENV{ACLOCAL} "aclocal -I ${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/")

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
    PKG_CONFIG_PATHS "${CURRENT_INSTALLED_DIR}/share/xorg/pkgconfig/"
    PKG_CONFIG_PATHS_RELEASE "${CURRENT_INSTALLED_DIR}/lib/pkgconfig/"
    PKG_CONFIG_PATHS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig/"
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# # Handle copyright
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}/")
file(TOUCH "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright") #already installed by xproto


