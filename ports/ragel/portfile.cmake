# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/ragel-6.9)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.colm.net/files/ragel/ragel-6.9.tar.gz"
    FILENAME "ragel-6.9.tar.gz"
    SHA512 46886a37fa0b785574c03ba6581d99bbeaa11ca65cf4fdc37ceef42f4869bd695694cd69b4b974a25cf539f004cb106e3debda17fc26e1a9a6a4295992733dbd
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config.h DESTINATION ${SOURCE_PATH}/ragel)

vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/0001-Remove-unistd.h-include-1.patch"
        "${CMAKE_CURRENT_LIST_DIR}/0002-Remove-unistd.h-include-2.patch"
        "${CMAKE_CURRENT_LIST_DIR}/0003-Fix-rsxgoto.cpp-build.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    GENERATOR "Visual Studio 14 2015"
)

vcpkg_install_cmake()

file(WRITE ${CURRENT_PACKAGES_DIR}/include/ragel.txt)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/ragel)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ragel/COPYING ${CURRENT_PACKAGES_DIR}/share/ragel/copyright)
