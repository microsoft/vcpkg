message(STATUS "----- ${PORT} requires autoconf, libtool and pkconf from the system package manager! -----")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/pthread-stubs
    REF 50f0755a7f894acae168f19c66e52a3f139ca4ec # 0.4.0
    SHA512  15fcb2144a8abb7b9b1b8f6d9732759351268fb440c7a59380b0ca6ddf48b74a37ce5afbf777ce58fc1993df0c8d6ffb82e452800ce2fcaf16edcbcc1750e338
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
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

