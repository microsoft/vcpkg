# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   CURRENT_INSTALLED_DIR     = ${VCPKG_ROOT_DIR}\installed\${TRIPLET}
#   DOWNLOADS                 = ${VCPKG_ROOT_DIR}\downloads
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#   VCPKG_TOOLCHAIN           = ON OFF
#   TRIPLET_SYSTEM_ARCH       = arm x86 x64
#   BUILD_ARCH                = "Win32" "x64" "ARM"
#   MSBUILD_PLATFORM          = "Win32"/"x64"/${TRIPLET_SYSTEM_ARCH}
#   DEBUG_CONFIG              = "Debug Static" "Debug Dll"
#   RELEASE_CONFIG            = "Release Static"" "Release DLL"
#   VCPKG_TARGET_IS_WINDOWS
#   VCPKG_TARGET_IS_UWP
#   VCPKG_TARGET_IS_LINUX
#   VCPKG_TARGET_IS_OSX
#   VCPKG_TARGET_IS_FREEBSD
#   VCPKG_TARGET_IS_ANDROID
#   VCPKG_TARGET_IS_MINGW
#   VCPKG_TARGET_EXECUTABLE_SUFFIX
#   VCPKG_TARGET_STATIC_LIBRARY_SUFFIX
#   VCPKG_TARGET_SHARED_LIBRARY_SUFFIX
#
# 	See additional helpful variables in /docs/maintainers/vcpkg_common_definitions.md

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
# # Specifies if the port install should fail immediately given a condition
vcpkg_fail_port_install(MESSAGE "${PORT} currently only supports Linux and Mac platforms" ON_TARGET "Windows")

## requires AUTOCONF, LIBTOOL and PKCONF
message(STATUS "----- ${PORT} requires autoconf, libtool and pkconf from the system package manager! -----")

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
)

vcpkg_install_make()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}/aclocal/")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/aclocal/" "${CURRENT_PACKAGES_DIR}/share/${PORT}/aclocal/")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/util-macros/" "${CURRENT_PACKAGES_DIR}/share/${PORT}/util-macros")

file(READ "${CURRENT_PACKAGES_DIR}/share/pkgconfig/xorg-macros.pc" _contents)
string(REPLACE "${CURRENT_PACKAGES_DIR}" "${CURRENT_INSTALLED_DIR}" _contents "${_contents}")
string(REPLACE "datarootdir=\${prefix}/share}" "datarootdir=\${prefix}/share/${PORT}}" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/pkgconfig/xorg-macros.pc" "${_contents}")
#file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}/pkgconfig/")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/pkgconfig/" "${CURRENT_PACKAGES_DIR}/share/${PORT}/pkgconfig")

file(READ "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig/xorg-macros.pc" _contents)
string(REPLACE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_INSTALLED_DIR}/debug" _contents "${_contents}")
string(REPLACE "datarootdir=\${prefix}/share}" "datarootdir=\${prefix}/share/${PORT}/debug}" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig/xorg-macros.pc" "${_contents}")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}/debug/")
file(RENAME  "${CURRENT_PACKAGES_DIR}/debug/share/" "${CURRENT_PACKAGES_DIR}/share/${PORT}/debug/")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
# # Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME Xlib)
