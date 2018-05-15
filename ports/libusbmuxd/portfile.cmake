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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libusbmuxd-1.0.105)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    set(MSBUILD_PLATFORM x64)
else()
    set(MSBUILD_PLATFORM Win32)
endif()

set(DEBUG_CONFIG Debug)
set(RELEASE_CONFIG Release)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libimobiledevice-win32/libusbmuxd/archive/1.0.105.zip"
    FILENAME "libusbmuxd-1.0.105.zip"
    SHA512 584edbbf3002b215c42f5b924bdf5508fb1f1eae38a84a33acf118933c5cf51d5c03e501004519e5cd082b196c550fd0fed63182fbf008f973449f32e5991dd6
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/libusbmuxd.vcxproj
    DEBUG_CONFIGURATION ${DEBUG_CONFIG}
    RELEASE_CONFIGURATION ${RELEASE_CONFIG}
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
    ${CURRENT_PACKAGES_DIR}/debug/lib)

file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${DEBUG_CONFIG}/libusbmuxd.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${RELEASE_CONFIG}/libusbmuxd.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${DEBUG_CONFIG}/libusbmuxd.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${RELEASE_CONFIG}/libusbmuxd.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libusbmuxd RENAME copyright)
