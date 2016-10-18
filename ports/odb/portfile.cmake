# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/odb-2.4.0)
vcpkg_download_distfile(TOOL_ARCHIVE_FILE
    URLS "http://www.codesynthesis.com/download/odb/2.4/odb-2.4.0-i686-windows.zip"
    FILENAME "odb-2.4.0.zip"
)
vcpkg_extract_source_archive(${TOOL_ARCHIVE_FILE})



# Handle copyright
#file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/odb)
#file(RENAME ${CURRENT_PACKAGES_DIR}/share/odb/LICENSE ${CURRENT_PACKAGES_DIR}/share/odb/copyright)
