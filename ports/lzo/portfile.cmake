# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/lzo-2.09)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.oberhumer.com/opensource/lzo/download/lzo-2.09.tar.gz"
    FILENAME "lzo-2.09.tar.gz"
    SHA512 7c64e5e7d2050d75ac8c59d613f6f7230b74746b1d207666755b07450053c8b73980f12f8a1ec59d2af0bada02beec126aaacb675b8088b5fe65e97ff7e6bfc7
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/do-not-declare-setargv.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${CURRENT_BUILDTREES_DIR}/src/lzo-2.09/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/lzo)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/lzo/COPYING ${CURRENT_PACKAGES_DIR}/share/lzo/copyright)
