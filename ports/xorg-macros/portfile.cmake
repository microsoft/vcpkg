set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

## requires AUTOCONF, LIBTOOL and PKCONF
message(STATUS "----- ${PORT} requires autoconf, libtool and pkconf from the system package manager! \n ----- sudo apt-get install autogen autoconf libtool-----")

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO util/macros
    REF  771b773b50717884b37f6b2473166b4be4670076 #v1.19.2
    SHA512 7a4048fb609b4c83127758f0aa53163114da4a4a9f1414f3bda5d44cebcf49dfe41b1daa82f232420a25e6b3a7a163848f3ce30fd3c77bdb289d4ee00bec31a6
    HEAD_REF master # branch name
    #PATCHES example.patch #patch name
) 

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
    PKG_CONFIG_PATHS_RELEASE "${CURRENT_INSTALLED_DIR}/lib/pkgconfig"
    PKG_CONFIG_PATHS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig"
)

vcpkg_install_make()

 file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/xorg/")
if(NOT WIN32)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/xorg/aclocal/")
endif()

file(RENAME "${CURRENT_PACKAGES_DIR}/share/aclocal/" "${CURRENT_PACKAGES_DIR}/share/xorg/aclocal")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/util-macros/" "${CURRENT_PACKAGES_DIR}/share/xorg/util-macros")

file(READ "${CURRENT_PACKAGES_DIR}/share/pkgconfig/xorg-macros.pc" _contents)
string(REPLACE "${CURRENT_PACKAGES_DIR}" "${CURRENT_INSTALLED_DIR}" _contents "${_contents}")
string(REPLACE "datarootdir=\${prefix}/share" "datarootdir=\${prefix}/share/xorg" _contents "${_contents}")
string(REPLACE "includedir=${CURRENT_INSTALLED_DIR}/include" "includedir=\${prefix}/include" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/pkgconfig/xorg-macros.pc" "${_contents}")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/pkgconfig/" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig/xorg-macros.pc")
    file(READ "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig/xorg-macros.pc" _contents)
    string(REPLACE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_INSTALLED_DIR}/debug" _contents "${_contents}")
    string(REPLACE "datarootdir=\${prefix}/share}" "datarootdir=\${prefix}/share/xorg/debug}" _contents "${_contents}")
    string(REPLACE "includedir=${CURRENT_INSTALLED_DIR}/debug/include" "includedir=\${prefix}/../include" _contents "${_contents}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig/xorg-macros.pc" "${_contents}")
    if(NOT WIN32)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/xorg/debug/")
    endif()
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(RENAME  "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig/" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
    file(RENAME  "${CURRENT_PACKAGES_DIR}/debug/share/" "${CURRENT_PACKAGES_DIR}/share/xorg/debug/")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share/)
vcpkg_fixup_pkgconfig()

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
# # Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME Xlib)
