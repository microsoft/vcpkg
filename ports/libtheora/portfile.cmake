# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libtheora-1.1.1)
vcpkg_download_distfile(ARCHIVE
    URLS "http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.bz2"
    FILENAME "libtheora-1.1.1.tar.bz2"
    SHA512 9ab9b3af1c35d16a7d6d84f61f59ef3180132e30c27bdd7c0fa2683e0d00e2c791accbc7fd2c90718cc947d8bd10ee4a5940fb55f90f1fd7b0ed30583a47dbbd
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/FindOGG.cmake DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libtheora)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libtheora/LICENSE ${CURRENT_PACKAGES_DIR}/share/libtheora/copyright)
