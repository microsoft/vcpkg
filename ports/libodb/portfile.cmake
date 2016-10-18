# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libodb-2.4.0)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.codesynthesis.com/download/odb/2.4/libodb-2.4.0.tar.gz"
    FILENAME "libodb-2.4.0.tar.gz"
    SHA512 f1311458634695eb6ba307ebfd492e3b260e7beb06db1c5c46df58c339756be4006322cdc4e42d055bf5b2ad14ce4656ddcafcc4e16c282034db8a77d255c3eb
)
vcpkg_extract_source_archive(${ARCHIVE})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG
        -DLIBODB_INSTALL_HEADERS=OFF
)
# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libodb)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libodb/LICENSE ${CURRENT_PACKAGES_DIR}/share/libodb/copyright)
