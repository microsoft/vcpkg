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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libgeotiff-1.4.2)
vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/geotiff/libgeotiff/libgeotiff-1.4.2.zip"
    FILENAME "libgeotiff-1.4.2.zip"
    SHA512 a95d2786f06a704b7966629c12b4716d2de1b2fff86728e91a313728b73ca65c7317b551ec2c22bea7fab146f72a96fff6a35bfdc67f5a9892c37c70e6a0bc3a
)
vcpkg_extract_source_archive(${ARCHIVE})

# Fix generation of geotiff-config.cmake file:
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}/cmake
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/fix-config-cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

# Move and fix cmake files
file(GLOB RELEASE_CMAKE_FILES "${CURRENT_PACKAGES_DIR}/cmake/*.cmake")
file(INSTALL ${RELEASE_CMAKE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/share/geotiff)
vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_PACKAGES_DIR}/share/geotiff
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/fix-import-prefix.patch
)
file(GLOB DEBUG_CMAKE_FILES "${CURRENT_PACKAGES_DIR}/debug/cmake/*-depends-debug.cmake")
foreach(DEBUG_CMAKE_FILE ${DEBUG_CMAKE_FILES})
    file(READ ${DEBUG_CMAKE_FILE} CONTENTS)
    string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" CONTENTS "${CONTENTS}")
    file(WRITE ${DEBUG_CMAKE_FILE} "${CONTENTS}")
endforeach()
file(INSTALL ${DEBUG_CMAKE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/share/geotiff)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/cmake)



# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/geotiff RENAME copyright)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/geotiff RENAME COPYING)


# Remove include and share directory from debug folder
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)


# Remove doc directory
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/doc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/doc)

# Move executables
file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/bin/*.exe")
file(INSTALL ${BINARY_TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/geotiff)
file(REMOVE ${BINARY_TOOLS})
file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
file(REMOVE ${BINARY_TOOLS})
