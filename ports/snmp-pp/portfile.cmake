# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/intelight-snmp-0b0f75e41b09)
vcpkg_download_distfile(ARCHIVE
    URLS "http://intelight.s3.amazonaws.com/vendor/intelight-snmp-0b0f75e41b09.tar.bz2"
    FILENAME "intelight-snmp-0b0f75e41b09.tar.bz2"
    SHA512 c026b67d35317bde8b0a1e43b27940b4ec9b59f12b87d70bd129c056ce6be8ca747eee597633fa8649fbe872e7dd1d402dd121b54ed7ba1789985d2e375dfc16
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DCMAKE_EXPORT_DESTINATION_DIR:PATH=share/snmp-pp
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/README.v3 DESTINATION ${CURRENT_PACKAGES_DIR}/share/snmp-pp RENAME copyright)

# move debug cmake export files
file(COPY ${CURRENT_PACKAGES_DIR}/debug/share/snmp-pp/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/snmp-pp)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# fix debug cmake export file
file(READ ${CURRENT_PACKAGES_DIR}/share/snmp-pp/snmp-pp-config-debug.cmake DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" DEBUG_MODULE "${DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/snmp-pp/snmp-pp-config-debug.cmake "${DEBUG_MODULE}")
