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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/pangomm-2.40.1)
vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnome.org/pub/GNOME/sources/pangomm/2.40/pangomm-2.40.1.tar.xz"
    FILENAME "pangomm-2.40.1.tar.xz"
    SHA512 bed19800b76e69cc51abeb5997bdc2f687f261ebcbe36aeee51f1fbf5010a46f4b9469033c34a912502001d9985135fd5c7f7574d3de8ba33cc5832520c6aa6f
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/fix_properties.patch ${CMAKE_CURRENT_LIST_DIR}/fix_charset.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/msvc_recommended_pragmas.h DESTINATION ${SOURCE_PATH}/MSVC_Net2013)

set(VS_PLATFORM ${VCPKG_TARGET_ARCHITECTURE})
if(${VCPKG_TARGET_ARCHITECTURE} STREQUAL x86)
    set(VS_PLATFORM "Win32")
endif(${VCPKG_TARGET_ARCHITECTURE} STREQUAL x86)
vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/MSVC_Net2013/pangomm.sln
    TARGET pangomm
    PLATFORM ${VS_PLATFORM}
    USE_VCPKG_INTEGRATION
)

# Handle headers
file(COPY ${SOURCE_PATH}/MSVC_Net2013/pangomm/pangommconfig.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/pango/pangomm.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(
    COPY
    ${SOURCE_PATH}/pango/pangomm
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
    FILES_MATCHING PATTERN *.h
)

# Handle libraries
file(
    COPY
    ${SOURCE_PATH}/MSVC_Net2013/Release/${VS_PLATFORM}/bin/pangomm.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin
)
file(
    COPY
    ${SOURCE_PATH}/MSVC_Net2013/Release/${VS_PLATFORM}/bin/pangomm.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)
file(
    COPY
    ${SOURCE_PATH}/MSVC_Net2013/Debug/${VS_PLATFORM}/bin/pangomm.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
)
file(
    COPY
    ${SOURCE_PATH}/MSVC_Net2013/Debug/${VS_PLATFORM}/bin/pangomm.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)

vcpkg_copy_pdbs()

# Handle copyright and readme
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/pangomm RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README DESTINATION ${CURRENT_PACKAGES_DIR}/share/pangomm RENAME readme.txt)
