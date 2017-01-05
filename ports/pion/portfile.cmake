# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/intelight-old-pion-net-08aa24212b04)
vcpkg_download_distfile(ARCHIVE
    URLS "http://intelight.s3.amazonaws.com/vendor/intelight-old-pion-net-08aa24212b04.tar.bz2"
    FILENAME "intelight-old-pion-net-08aa24212b04.tar.bz2"
    SHA512 9a7c91abde2dea0c42ef9ae3f976dba541795eeae7e45bfb446f300930ceca5a2287d966a64c94ae7cab8221000da01d183de136822255038bf89f3a9fe8bb47
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DCMAKE_EXPORT_DESTINATION_DIR:PATH=share/pion
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/pion RENAME copyright)

# move debug cmake export files
file(COPY ${CURRENT_PACKAGES_DIR}/debug/share/pion/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/pion)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# fix debug cmake export file
file(READ ${CURRENT_PACKAGES_DIR}/share/pion/pion-config-debug.cmake DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" DEBUG_MODULE "${DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/pion/pion-config-debug.cmake "${DEBUG_MODULE}")
