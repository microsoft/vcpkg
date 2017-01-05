# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/intelight-hiredis-e8b31f431257)
vcpkg_download_distfile(ARCHIVE
    URLS "http://intelight.s3.amazonaws.com/vendor/intelight-hiredis-e8b31f431257.tar.bz2"
    FILENAME "intelight-hiredis-e8b31f431257.tar.bz2"
    SHA512 4eb95f5325250a97c6fc3f926f471bba3fac04b89d1faa7e11ab6c0b8f6ece89ebccd44e64a461f3317cdc41c5ce8e56b50dff5a555b269aaf034b7b88c31a04
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

# cleanup unused files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/hiredis/examples)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/hiredis RENAME copyright)
