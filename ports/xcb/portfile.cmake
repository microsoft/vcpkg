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
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxcb
    REF  8287ebd7b752c33b0cabc4982606fe4831106f7e #v1.13.1 
    SHA512 625939b67d129f681503a2f784daa75897b31b09daba0b9ea72457c9dffdab34a644c0b73068282de01ddfdcd5fc29242e4db5367d39b795984374846c1319c8
    HEAD_REF master # branch name
    #PATCHES example.patch #patch name
) 

file(COPY "${CURRENT_INSTALLED_DIR}/share/xorg-macros/aclocal/xorg-macros.m4" DESTINATION "${SOURCE_PATH}/m4")

set(PKG_PATHS "$ENV{PKG_CONFIG_PATH}")
set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}:${CURRENT_INSTALLED_DIR}/share/xorg-macros/pkgconfig/:${CURRENT_INSTALLED_DIR}/lib/pkgconfig/")
#Alternatively, you may set the environment variables XCBPROTO_CFLAGS
#and XCBPROTO_LIBS to avoid the need to call pkg-config.
#See the pkg-config man page for more details.
#Package xcb-proto was not found in the pkg-config search path.
#Perhaps you should add the directory containing `xcb-proto.pc'
#to the PKG_CONFIG_PATH environment variable
#Package 'xcb-proto', required by 'world', not found

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

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# # Moves all .cmake files from /debug/share/Xlib/ to /share/Xlib/
# # See /docs/maintainers/vcpkg_fixup_cmake_targets.md for more details
# vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/Xlib)

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# # Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME Xlib)
