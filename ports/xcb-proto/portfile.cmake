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

# # Specifies if the port install should fail immediately given a condition
# vcpkg_fail_port_install(MESSAGE "Xlib currently only supports Linux and Mac platforms" ON_TARGET "Windows")
vcpkg_fail_port_install(MESSAGE "Xlib currently only supports Linux and Mac platforms" ON_TARGET "Windows")

## requires AUTOCONF, LIBTOOL and PKCONF
message(STATUS "----- ${PORT} requires autoconf, libtool, pkconf and xmllint from the system package manager! -----")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

find_program(XMLLINT_PATH NAMES xmllint PATHS "${CURRENT_INSTALLED_DIR}/tools/libxml2")
if(NOT XMLLINT_PATH)
    message(FATAL_ERROR "${PORT} requires xmllint which was not found!")
endif()

string(REGEX REPLACE "/[^/]+$" "" XMLLINT_DIR "${XMLLINT_PATH}")
file(TO_NATIVE_PATH "${XMLLINT_DIR}" XMLLINT_DIR_NATIVE)
vcpkg_add_to_path("${XMLLINT_DIR_NATIVE}")
#(also requires python2?)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO proto/xcbproto
    REF  94228cde97d9aecfda04a8e699d462ba2b89e3a0 #v1.13
    SHA512 a6d44efb2fe7ff0b731e6024436cc6b07633839c69716e835c4aa8c02d67686068e966f811da61722ea5e2545cd621b76fb6a0f5775840387727acb61a9bdd44
    HEAD_REF master # branch name
    #PATCHES example.patch #patch name
) 

file(COPY "${CURRENT_INSTALLED_DIR}/share/xorg-macros/aclocal/xorg-macros.m4" DESTINATION "${SOURCE_PATH}/m4")

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

file(READ "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/xcb-proto.pc" _contents)
string(REPLACE "libdir=${CURRENT_PACKAGES_DIR}/lib" "libdir=\${prefix}/lib" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/xcb-proto.pc" "${_contents}")

file(READ "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/xcb-proto.pc" _contents)
string(REPLACE "libdir=${CURRENT_PACKAGES_DIR}/debug/lib" "libdir=\${prefix}/lib" _contents "${_contents}")
string(REPLACE "datarootdir=\${prefix}/share" "datarootdir=\${prefix}/../share" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/xcb-proto.pc" "${_contents}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# # Moves all .cmake files from /debug/share/Xlib/ to /share/Xlib/
# # See /docs/maintainers/vcpkg_fixup_cmake_targets.md for more details
# vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/Xlib)

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# # Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME Xlib)
