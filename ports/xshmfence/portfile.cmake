## requires AUTOCONF, LIBTOOL and PKCONF
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxshmfence
    REF  f38b2e73071ba516127f8f5ae47f48df58dc9d53 #1.3
    SHA512 d3342db68b24b2b139977655fc42fde9b22cc1b786e1df6f14c5084e195d2208c11391b9a1769b4d6f9d41d21c163c1d9aa92f72059ada468375daaeee8dffdb
    HEAD_REF master # branch name
    PATCHES unistd.h.patch #patch name
) 
#file(TOUCH ${SOURCE_PATH}/m4/dummy)
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
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}/")
file(TOUCH "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright") #already installed by xproto


