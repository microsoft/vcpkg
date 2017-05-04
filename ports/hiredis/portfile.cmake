# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/hiredis-74b348cbb24748d8874c97602284d36fc277dd0d)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Intelight/hiredis/archive/74b348cbb24748d8874c97602284d36fc277dd0d.zip"
    FILENAME "hiredis-74b348cbb2.zip"
    SHA512 932bbb2f256b12da96ad30742dfa2e6467858dbc83b5d2041157ce4e119a1913637d1a5b6ef4c9a5f96f19627bbdaa8d26897b6465153ba390eb7c2b18345fc9
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
