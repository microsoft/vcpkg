# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/vorbis-112d3bd0aaacad51305e1464d4b381dabad0e88b)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/xiph/vorbis/archive/112d3bd0aaacad51305e1464d4b381dabad0e88b.zip"
    FILENAME "vorbis-112d3bd0aaacad51305e1464d4b381dabad0e88b.zip"
    SHA512 94e773a34f3e8d1c8ed0422f0eab345b35f76a96760141af83d69d007ebf076fca2d083a77d36bfa4ea10dfefa03a8fa35201aced963655ab8a524aaa7580b11
)

vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0001-Dont-export-vorbisenc-functions.patch
        ${CMAKE_CURRENT_LIST_DIR}/0002-Allow-deprecated-functions.patch
)

file(TO_NATIVE_PATH "${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/include" OGG_INCLUDE)
file(TO_NATIVE_PATH "${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/lib/ogg.lib" OGG_LIB_REL)
file(TO_NATIVE_PATH "${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/debug/lib/ogg.lib" OGG_LIB_DBG)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DOGG_INCLUDE_DIRS=${OGG_INCLUDE}
    OPTIONS_RELEASE -DOGG_LIBRARIES=${OGG_LIB_REL}
    OPTIONS_DEBUG -DOGG_LIBRARIES=${OGG_LIB_DBG}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libvorbis)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libvorbis/COPYING ${CURRENT_PACKAGES_DIR}/share/libvorbis/copyright)

vcpkg_copy_pdbs()
