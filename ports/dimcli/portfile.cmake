# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

set(ver 1.0.3)
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/dimcli-${ver})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/gknowles/dimcli/archive/v${ver}.zip"
    FILENAME "dimcli-${ver}.zip"
    SHA512 5168aff22223cb85421fabd4ce82f3ec0bcab6551704484bc5b05be02ead23bd3d4a629c558a15f214e9d999eccc9c129649d066fdacfda3c839a40b48f8ec17
)
vcpkg_extract_source_archive(${ARCHIVE})

set(staticCrt OFF)
if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(staticCrt ON)
endif()
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DLINK_STATIC_RUNTIME:BOOL=${staticCrt} 
)

vcpkg_install_cmake()

# Remove includes from ${CMAKE_INSTALL_PREFIX}/debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" 
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/dimcli"
    RENAME copyright)

