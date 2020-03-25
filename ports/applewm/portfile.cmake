vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libapplewm
    REF 78e9081bd1dc88e4a86fc6e401647bdb5265fef7 # 1.4.1
    SHA512  a4afb77458e980f61b0d51d8d89f89c2b47eaca6674b7ff2473745d04b9dd59921401db74f53fe24e5b5e4221f311f69fcbfcaa0d5e0b37c53e68a6844e655bc
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

