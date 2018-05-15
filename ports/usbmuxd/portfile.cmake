# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/usbmuxd-1.1.1.133)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    set(MSBUILD_PLATFORM  x64)
else()
    set(MSBUILD_PLATFORM  Win32)
endif()

set(DEBUG_CONFIG Debug)
set(RELEASE_CONFIG Release)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libimobiledevice-win32/usbmuxd/archive/1.1.1.133.zip"
    FILENAME "usbmuxd-1.1.1.133"
    SHA512 17a4c06983b570755ad720196316d7ab54b02b1ce0eb9f82c5bf479a0d57e8beb44940e233cd8353aa978122f7a20ca7710dedb3a08608a1df3d3b939a5e2f66
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/usbmuxd.vcxproj
    DEBUG_CONFIGURATION ${DEBUG_CONFIG}
    RELEASE_CONFIGURATION ${RELEASE_CONFIG}
    USE_VCPKG_INTEGRATION
)

# No headers
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

# Copy binary files
file (MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/tools
    ${CURRENT_PACKAGES_DIR}/debug/tools)

file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${DEBUG_CONFIG}/usbmuxd.exe
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools)
file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${RELEASE_CONFIG}/usbmuxd.exe
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${DEBUG_CONFIG}/usbmuxd.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools)
file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${RELEASE_CONFIG}/usbmuxd.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING.GPLv2 DESTINATION ${CURRENT_PACKAGES_DIR}/share/usbmuxd RENAME copyright)
