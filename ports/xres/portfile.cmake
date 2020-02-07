message(STATUS "----- ${PORT} requires autoconf, libtool and pkconf from the system package manager! -----") #Lex and Yacc

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxres
    REF 84b9156c7833dfd91c65d33542420ff4fe226948 # 1.2.0
    SHA512  3c3ba4b82fbc4856a827022b5b0a774eb39cb1bd53a7d6fdb3056c58648f2a38ea33efee9154611c29291983753dbf775ef74d1cba6aea59c5d8b98527abdecd
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
    PKG_CONFIG_PATHS_RELEASE "${CURRENT_INSTALLED_DIR}/lib/pkgconfig"
    PKG_CONFIG_PATHS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig"
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

