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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libirecovery-1.0.21)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    set(MSBUILD_PLATFORM  x64)
else()
    set(MSBUILD_PLATFORM  Win32)
endif()

set(DEBUG_CONFIG Debug)
set(RELEASE_CONFIG Release)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libimobiledevice-win32/libirecovery/archive/1.0.21.zip"
    FILENAME "libirecovery-1.0.21.zip"
    SHA512 5d9b53526c6f5daefdf3e9feb697a94800635a511808129169c4823a971e9d994f084c7bd927c21b50f4fbad482cb4c2fb7bf1132129089d1e1a078b87e03b0b
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/libirecovery.sln
    DEBUG_CONFIGURATION ${DEBUG_CONFIG}
    RELEASE_CONFIGURATION ${RELEASE_CONFIG}
    PLATFORM ${MSBUILD_PLATFORM}
    USE_VCPKG_INTEGRATION
)

# Copy headers
file (MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/include)
file(COPY            ${SOURCE_PATH}/include/
     DESTINATION     ${CURRENT_PACKAGES_DIR}/include
     FILES_MATCHING PATTERN "*.h")

# Copy binary files
file (MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/lib
    ${CURRENT_PACKAGES_DIR}/debug/lib
    ${CURRENT_PACKAGES_DIR}/bin
    ${CURRENT_PACKAGES_DIR}/debug/bin)

file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${DEBUG_CONFIG}/irecovery.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${RELEASE_CONFIG}/irecovery.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${DEBUG_CONFIG}/irecovery.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${RELEASE_CONFIG}/irecovery.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${DEBUG_CONFIG}/irecovery.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${RELEASE_CONFIG}/irecovery.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

# Copy utilities
file(GLOB debug_tools "${SOURCE_PATH}/${MSBUILD_PLATFORM}/${DEBUG_CONFIG}/*.exe")
file(COPY ${debug_tools} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools)

file(GLOB release_tools "${SOURCE_PATH}/${MSBUILD_PLATFORM}/${RELEASE_CONFIG}/*.exe")
file(COPY ${release_tools} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libirecovery RENAME copyright)
