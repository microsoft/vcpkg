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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/liblas-1.8.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libLAS/libLAS/archive/1.8.1.zip"
    FILENAME "liblas-1.8.1.zip"
    SHA512 ab66a1e972898e6cb017111cf92518c58b35a61cc28e6932031867df84abc81d65d8965bede49f99fc7941b1917107e1cba5d1c45af26720765407ee55a05c51
)
vcpkg_extract_source_archive(${ARCHIVE})

# Turn off Boost_USE_STATIC_LIBS:
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/boost_static_libs.patch
)

# Remove modules directory (contains all kinds of Find*.cmake modules that interfere with vcpkg)
file(REMOVE_RECURSE ${SOURCE_PATH}/cmake/modules)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DWITH_LASZIP=ON
        -DBUILD_OSGEO4W=OFF
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblas RENAME copyright)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblas RENAME COPYING)


# Remove include and share directory from debug folder
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)


# Move cmake directory
file(RENAME ${CURRENT_PACKAGES_DIR}/cmake ${CURRENT_PACKAGES_DIR}/share/liblas/cmake)

# Patch relative path in liblas-config.cmake:
file(READ ${CURRENT_PACKAGES_DIR}/share/liblas/cmake/liblas-config.cmake LIBLAS_CONFIG)
string(REPLACE "\"\${_DIR}/..\"" "\"\${_DIR}/../../..\"" LIBLAS_CONFIG "${LIBLAS_CONFIG}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/liblas/cmake/liblas-config.cmake "${LIBLAS_CONFIG}")

file(APPEND ${CURRENT_PACKAGES_DIR}/share/liblas/cmake/liblas-config.cmake "\n# laszip is not correctly found without this call:\n")
file(APPEND ${CURRENT_PACKAGES_DIR}/share/liblas/cmake/liblas-config.cmake "find_package(laszip)")
file(APPEND ${CURRENT_PACKAGES_DIR}/share/liblas/cmake/liblas-config.cmake "\n# (Feels like a hack, should be automatically resolved by CMake...?)\n")


# Patch _IMPORT_PREFIX
vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_PACKAGES_DIR}/share/liblas/cmake
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/fix-import-prefix.patch
)


# Adapt and move debug targets file:
file(READ ${CURRENT_PACKAGES_DIR}/debug/cmake/liblas-depends-debug.cmake LIBLAS_TARGETS_DEBUG)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" LIBLAS_TARGETS_DEBUG "${LIBLAS_TARGETS_DEBUG}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/liblas/cmake/liblas-depends-debug.cmake "${LIBLAS_TARGETS_DEBUG}")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake)


# Remove doc directory
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/doc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/doc)

# Move executables
file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/bin/*.exe")
file(INSTALL ${BINARY_TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/liblas)
file(REMOVE ${BINARY_TOOLS})
file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
file(REMOVE ${BINARY_TOOLS})

