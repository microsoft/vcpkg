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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/LASzip-2.2.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/LASzip/LASzip/archive/v2.2.0.zip"
    FILENAME "laszip-v2.2.0.zip"
    SHA512 ee2f8487a41e96d2683d735ca9e1dce848daa27607ed5a1c9dab1e17dc8b52cf86a5a1e7cf0d8788f21c0efe5e1c9b0151d3d181c3ec8536ff79b02daf01727d
)
vcpkg_extract_source_archive(${ARCHIVE})

# Apply patch to disable BuildOSGeo4W target:
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES 
      ${CMAKE_CURRENT_LIST_DIR}/disable_buildosgeo4w.patch
      ${CMAKE_CURRENT_LIST_DIR}/export_targets.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
)

vcpkg_install_cmake()

# Handle copyright:
file(INSTALL ${SOURCE_PATH}/AUTHORS DESTINATION ${CURRENT_PACKAGES_DIR}/share/laszip RENAME copyright)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/laszip RENAME license)

# Adapt and move debug targets file:
file(READ ${CURRENT_PACKAGES_DIR}/debug/share/laszip/laszipTargets-debug.cmake LASZIP_TARGETS_DEBUG)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" LASZIP_TARGETS_DEBUG "${LASZIP_TARGETS_DEBUG}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/laszip/laszipTargets-targets-debug.cmake ${LASZIP_TARGETS_DEBUG})


# Remove include and share directory from debug folder
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)


# Move executables
file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/bin/*.exe")
file(INSTALL ${BINARY_TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/laszip)
file(REMOVE ${BINARY_TOOLS})
file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
file(REMOVE ${BINARY_TOOLS})
