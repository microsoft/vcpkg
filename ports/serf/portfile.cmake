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

# Also consider vcpkg_from_* functions if you can; the generated code here is for any web accessable
# source archive.
#  vcpkg_from_github
#  vcpkg_from_gitlab
#  vcpkg_from_bitbucket
#  vcpkg_from_sourceforge
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.apache.org/dist/serf/serf-1.3.10.tar.bz2"
    FILENAME "serf-1.3.10.tar.bz2"
    SHA512 19165274d35c694935cda33f99ef92a7663a5d9c540fb7fd6792aa0efe39941b2fa87ff8b61afd060c6676baec634fd33dc2e9d34ecbee45ed99dfaed077802c
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
  set(SCONS_ARCH "TARGET_ARCH=x86_64")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
  set(SCONS_ARCH "TARGET_ARCH=x86")
else()
  set(SCONS_ARCH "")
endif()

set(EXTRA_MODE "")
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  set(EXTRA_MODE ${EXTRA_MODE} APR_STATIC=yes)
endif()

vcpkg_find_acquire_program(SCONS)

vcpkg_execute_build_process(
    COMMAND ${SCONS}
        SOURCE_LAYOUT=no
        PREFIX=${CURRENT_PACKAGES_DIR}
        LIBDIR=${CURRENT_PACKAGES_DIR}/lib
        OPENSSL=${CURRENT_INSTALLED_DIR}
        ZLIB=${CURRENT_INSTALLED_DIR}
        APR=${CURRENT_INSTALLED_DIR}
        APU=${CURRENT_INSTALLED_DIR}
        ${SCONS_ARCH}
        DEBUG=no
        install-lib install-inc
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME "scons"
)
