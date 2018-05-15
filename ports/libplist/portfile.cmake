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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libplist-2.0.1.195)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    set(MSBUILD_PLATFORM x64)
else()
    set(MSBUILD_PLATFORM Win32)
endif()

set(DEBUG_CONFIG Debug)
set(RELEASE_CONFIG Release)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libimobiledevice-win32/libplist/archive/2.0.1.195.zip"
    FILENAME "libplist-2.0.1.195.zip"
    SHA512 8638fcd4a7ec0b0579823d4b14df0f2a50cc8019b4b1f4359c0339e0a5e26a20123efa2ad5a6035728d0e3e12e6d06206da3ca1df5b7344403d7ea5d8393a40f
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/libplist.sln
    DEBUG_CONFIGURATION ${DEBUG_CONFIG}
    PLATFORM ${MSBUILD_PLATFORM}
    RELEASE_CONFIGURATION ${RELEASE_CONFIG}
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
    ${CURRENT_PACKAGES_DIR}/tools
    ${CURRENT_PACKAGES_DIR}/debug/tools)

file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${DEBUG_CONFIG}/libplist.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${RELEASE_CONFIG}/libplist.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${DEBUG_CONFIG}/libplist.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${RELEASE_CONFIG}/libplist.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

# Copy utilities
file(GLOB debug_tools "${SOURCE_PATH}/${MSBUILD_PLATFORM}/${DEBUG_CONFIG}/*.exe")
file(COPY ${debug_tools} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools)

file(GLOB release_tools "${SOURCE_PATH}/${MSBUILD_PLATFORM}/${RELEASE_CONFIG}/*.exe")
file(COPY ${release_tools} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING.lesser DESTINATION ${CURRENT_PACKAGES_DIR}/share/libplist RENAME copyright)
