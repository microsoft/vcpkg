# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/physfs-2.0.3)
vcpkg_download_distfile(ARCHIVE
    URLS "https://icculus.org/physfs/downloads/physfs-2.0.3.tar.bz2"
    FILENAME "physfs-2.0.3.tar.bz2"
    SHA512 47eff0c81b8dc3bb526766b0a8ad2437d2951867880116d6e6e8f2ec1490e263541fb741867fed6517cc3fa8a9c5651b36e3e02a499f19cfdc5c7261c9707e80
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/test_physfs.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/test_physfs.exe)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/physfs)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/physfs/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/physfs/copyright)
