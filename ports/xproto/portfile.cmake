## requires AUTOCONF, LIBTOOL and PKCONF
message(STATUS "${PORT} requires autoconf, libtool and pkconf from the system package manager!")

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO proto/xorgproto
    REF f61f9a3ee1aa77ebcc67730cda9bfde88e4e9c5f # 2019.2
    SHA512 52540660d22e80a40c16c0f36fe66d76ce738a32a31c294126f0ec4519cc696f553ab46abf889487295b3e2e32feff94be4ce2a1e74dd66d964a1ff903a58e1e
    HEAD_REF master # branch name
    #PATCHES example.patch #patch name
) 

set(ENV{ACLOCAL} "aclocal -I ${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/")

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    #SKIP_CONFIGURE
    #NO_DEBUG
    #AUTO_HOST
    #AUTO_DST
    #PRERUN_SHELL "export ACLOCAL=\"aclocal -I ${CURRENT_INSTALLED_DIR}/share/xorg-macros/aclocal/\""
    OPTIONS --enable-legacy
    #OPTIONS_DEBUG
    #OPTIONS_RELEASE
    PKG_CONFIG_PATHS_RELEASE "${CURRENT_INSTALLED_DIR}/lib/pkgconfig/"
    PKG_CONFIG_PATHS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig/"
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig/" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/pkgconfig/" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
# # Handle copyright
file(GLOB_RECURSE _files "${SOURCE_PATH}/COPYING*")
file(INSTALL ${_files} DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(TOUCH "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")


