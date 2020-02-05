set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
# requires AUTOCONF, LIBTOOL and PKCONF
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO font/util
    REF  d45011b8324fecebb4fc79e57491d341dd96e325 #1.3.2
    SHA512 d783cbb5b8b0975891a247f98b78c2afadfd33e1d26ee8bcf7ab7ccc11615b0150d07345c719182b0929afc3c54dc3288a01a789b5374e18aff883ac23d15b04
    HEAD_REF master # branch name
    #PATCHES example.patch #patch name
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
    PKG_CONFIG_PATHS_RELEASE "${CURRENT_INSTALLED_DIR}/lib/pkgconfig/"
    PKG_CONFIG_PATHS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig/"
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/xorg/")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/aclocal/" "${CURRENT_PACKAGES_DIR}/share/xorg/aclocal")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/fonts/" "${CURRENT_PACKAGES_DIR}/share/xorg/fonts")
#file(RENAME "${CURRENT_PACKAGES_DIR}/share/font-util/" "${CURRENT_PACKAGES_DIR}/share/xorg/font-util")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}/man")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/man/" "${CURRENT_PACKAGES_DIR}/share/${PORT}/man")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")

set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/fontutil.pc")
file(READ "${_file}" _contents)
string(REPLACE "datarootdir=\${prefix}/share" "datarootdir=\${prefix}/share/xorg" _contents "${_contents}")
string(REPLACE "exec_prefix=\${prefix}" "exec_prefix=\${prefix}/tools/${PORT}" _contents "${_contents}")
file(WRITE "${_file}" "${_contents}")

set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/fontutil.pc")
file(READ "${_file}" _contents)
string(REPLACE "datarootdir=\${prefix}/share" "datarootdir=\${prefix}/../share/xorg" _contents "${_contents}")
string(REPLACE "exec_prefix=\${prefix}" "exec_prefix=\${prefix}/../tools/${PORT}" _contents "${_contents}")
file(WRITE "${_file}" "${_contents}")

# # Handle copyright
#file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}/")
#file(TOUCH "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright") #already installed by xproto
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
#file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/font-util)
#file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
