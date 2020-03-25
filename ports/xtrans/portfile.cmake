set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled) 

## requires AUTOCONF, LIBTOOL and PKCONF
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxtrans
    REF  c4262efc9688e495261d8b23a12f956ab38e006f #v1.4
    SHA512 137f0ffcae97f2375e5babbf21d336b67e7bf35f6a74377b14f035cdba66992d21f8d90f3c1dc243f8fd3d27d32af36c59af45443db59908969d0d65598865a2
    HEAD_REF master # branch name
    PATCHES ip6.patch #patch name
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
    #PRERUN_SHELL "export ACLOCAL=\"aclocal -I ${CURRENT_INSTALLED_DIR}/share/xorg-macros/aclocal/\""
    #OPTIONS
    #OPTIONS_DEBUG
    #OPTIONS_RELEASE
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/xorg/")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}/")
#file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/xorg/aclocal/")
if(NOT WIN32)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}/include")
endif()
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/" "${CURRENT_PACKAGES_DIR}/share/${PORT}/include/") 
# the include folder is moved since it contains source files. It is not meant as a traditional include folder but as a shared files folder for different x libraries. 
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/pkgconfig/" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/aclocal/" "${CURRENT_PACKAGES_DIR}/share/xorg/aclocal")

#file(RENAME "${CURRENT_PACKAGES_DIR}/share/doc/" "${CURRENT_PACKAGES_DIR}/share/xorg/doc")

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}/pkgconfig")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/" "${CURRENT_PACKAGES_DIR}/share/xorg/debug")
endif()

set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/xtrans.pc" )
file(READ "${_file}" _contents)
string(REPLACE "includedir=\${prefix}/include" "includedir=\${prefix}/share/xtrans/include" _contents "${_contents}")
file(WRITE "${_file}" "${_contents}")

set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/xtrans.pc" )
if(EXISTS "${_file}")
    file(READ "${_file}" _contents)
    string(REPLACE "includedir=\${prefix}/../include" "includedir=\${prefix}/../share/xtrans/include" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
