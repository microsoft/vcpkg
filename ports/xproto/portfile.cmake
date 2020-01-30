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
vcpkg_fail_port_install(MESSAGE "${PORT} currently only supports Linux and Mac platforms" ON_TARGET "Windows")

## requires AUTOCONF, LIBTOOL and PKCONF
message(STATUS "${PORT} requires autoconf, libtool and pkconf from the system package manager!")

#vcpkg_from_gitlab(
#    GITLAB_URL https://gitlab.freedesktop.org/xorg
#    OUT_SOURCE_PATH SOURCE_XTRANS
#    REPO lib/libxtrans
#    REF  c4262efc9688e495261d8b23a12f956ab38e006f #v1.4
#    SHA512 137f0ffcae97f2375e5babbf21d336b67e7bf35f6a74377b14f035cdba66992d21f8d90f3c1dc243f8fd3d27d32af36c59af45443db59908969d0d65598865a2
#    HEAD_REF master # branch name
#    #PATCHES example.patch #patch name
#) 

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
    #OPTIONS
    #OPTIONS_DEBUG
    #OPTIONS_RELEASE
    PKG_CONFIG_PATHS "${CURRENT_INSTALLED_DIR}/share/xorg/pkgconfig/"
    PKG_CONFIG_PATHS_RELEASE "${CURRENT_INSTALLED_DIR}/lib/pkgconfig/"
    PKG_CONFIG_PATHS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig/"
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/xorg/")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/pkgconfig/" "${CURRENT_PACKAGES_DIR}/share/xorg/pkgconfig")

# # Moves all .cmake files from /debug/share/Xlib/ to /share/Xlib/
# # See /docs/maintainers/vcpkg_fixup_cmake_targets.md for more details
# vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/Xlib)

# # Handle copyright
file(GLOB_RECURSE _files "${SOURCE_PATH}/COPYING*")
file(INSTALL ${_files} DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(TOUCH "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")

# # Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME Xlib)
