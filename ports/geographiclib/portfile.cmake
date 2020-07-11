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
# vcpkg_fail_port_install(MESSAGE "geographiclib currently only supports Linux and Mac platforms" ON_TARGET "Windows")

vcpkg_from_sourceforge (
  OUT_SOURCE_PATH SOURCE_PATH
  REPO geographiclib
  REF distrib
  FILENAME "GeographicLib-1.50.1.tar.gz"
  SHA512 1db874f30957a0edb8a1df3eee6db73cc993629e3005fe912e317a4ba908e7d7580ce483bb0054c4b46370b8edaec989609fb7e4eb6ba00c80182db43db436f1
  PATCHES cxx-library-only.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  vcpkg_configure_cmake (
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DGEOGRAPHICLIB_LIB_TYPE=SHARED
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    )
else ()
  vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DGEOGRAPHICLIB_LIB_TYPE=STATIC
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    )
endif ()

vcpkg_install_cmake ()

vcpkg_fixup_cmake_targets (CONFIG_PATH share/geographiclib)
vcpkg_copy_pdbs ()

file (REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file (REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Install usage
configure_file (${CMAKE_CURRENT_LIST_DIR}/usage
  ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)

# Post-build test for cmake libraries
vcpkg_test_cmake(PACKAGE_NAME GeographicLib)
