# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libccd-16b9379fb6e8610566fe5e1396166daf7106f165)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/danfis/libccd/archive/16b9379fb6e8610566fe5e1396166daf7106f165.zip"
    FILENAME "libccd-16b9379fb6e8610566fe5e1396166daf7106f165.zip"
    SHA512 6cb3ea713f1b1ac1bf48c9ee7e14cb85b3ec5c822ce239330913edc00cb84c846b49ec090cbfa226ef8de70bac97199eb2bf4c651225e3cfc6f6a9dd441aa7db
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_copy_pdbs()
endif()

# Avoid a copy of file in debug
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/BSD-LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libccd)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libccd/BSD-LICENSE ${CURRENT_PACKAGES_DIR}/share/libccd/copyright)
