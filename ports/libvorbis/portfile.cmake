# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/vorbis-143caf4023a90c09a5eb685fdd46fb9b9c36b1ee)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/xiph/vorbis/archive/143caf4023a90c09a5eb685fdd46fb9b9c36b1ee.zip"
    FILENAME "vorbis-143caf4023a90c09a5eb685fdd46fb9b9c36b1ee.zip"
    SHA512 9eeb64b1664ba8a1d118cdc5efc0090fe5f542eff33a16f4676fde8e59031fd0f9017857a7c45ca549899cab34efefd81dd54a57fab97f91f776fd9426f4e37a
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
