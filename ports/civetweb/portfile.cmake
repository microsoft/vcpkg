# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/intelight-civetweb-98404bcd4e79)
vcpkg_download_distfile(ARCHIVE
    URLS "http://intelight.s3.amazonaws.com/vendor/intelight-civetweb-98404bcd4e79.tar.bz2"
    FILENAME "intelight-civetweb-98404bcd4e79.tar.bz2"
    SHA512 afa33553c766ead1bdcb50213351b61240ab9959f698779c27cee328c979843db532f77a6e466235e33d9b2fc5e8d4ec2283b074edc40de9788b4a9a5cd23a40
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DCMAKE_EXPORT_DESTINATION_DIR:PATH=share/civetweb
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/civetweb RENAME copyright)

# move debug cmake export files
file(COPY ${CURRENT_PACKAGES_DIR}/debug/share/civetweb/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/civetweb)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# fix debug cmake export file
file(READ ${CURRENT_PACKAGES_DIR}/share/civetweb/civetweb-config-debug.cmake DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" DEBUG_MODULE "${DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/civetweb/civetweb-config-debug.cmake "${DEBUG_MODULE}")
