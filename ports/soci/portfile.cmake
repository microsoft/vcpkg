# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/soci-6eb1a3e9775ab7cdbf0f7f5aa5891792313cd8d9)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/SOCI/soci/archive/6eb1a3e9775ab7cdbf0f7f5aa5891792313cd8d9.zip"
    FILENAME "soci-master-2016.10.22.zip"
    SHA512 6bb0f7d3442de627089760485d3e663f12873b4871c4b4b4dfac5d380bad014865ac8382f7356e02514e9140f187dea8dcf8d6c25ac9c3e827e9fa69e9ed13b5
)
vcpkg_extract_source_archive(${ARCHIVE})

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(PORT_EXTRA_OPTIONS -DSOCI_STATIC=ON
                           -DSOCI_SHARED=OFF)
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(PORT_EXTRA_OPTIONS -DSOCI_STATIC=OFF
                           -DSOCI_SHARED=ON)
endif()
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DSOCI_TESTS=OFF
        -DSOCI_CXX_C11=ON
        -DLIBDIR=lib
)

vcpkg_install_cmake()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/soci)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/cmake/SOCI.cmake ${CURRENT_PACKAGES_DIR}/share/soci/SOCIConfig.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/cmake/SOCI-release.cmake ${CURRENT_PACKAGES_DIR}/share/soci/SOCI-release.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/cmake/SOCI-debug.cmake ${CURRENT_PACKAGES_DIR}/share/soci/SOCI-debug.cmake)
file(READ ${CURRENT_PACKAGES_DIR}/share/soci/SOCIConfig.cmake CONFIG_FILE)
set(pattern "get_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\n")
string(REPLACE "${pattern}" "${pattern}${pattern}" CONFIG_FILE ${CONFIG_FILE})
file(WRITE ${CURRENT_PACKAGES_DIR}/share/soci/SOCIConfig.cmake ${CONFIG_FILE})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/cmake)
# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/soci)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/soci/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/soci/copyright)

vcpkg_copy_pdbs()