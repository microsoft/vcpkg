include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/speexdsp-1.2rc3)
set(CMAKE_PATH ${CMAKE_CURRENT_LIST_DIR})
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://downloads.xiph.org/releases/speex/speexdsp-1.2rc3.tar.gz"
    FILENAME "speexdsp-1.2rc3.tar.xz"
    SHA512 29dfa8345df025eeb076561648a9b5c0485692be699b6da3c2a3734b4329187a1c2eb181252f4df12b21f1309ecdf59797437dfb123d160fd723491ab216e858
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

set(USE_SSE OFF)
set(USE_NEON OFF)
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(USE_SSE ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${CMAKE_PATH}
    PREFER_NINJA
    OPTIONS -DSOURCE_PATH=${SOURCE_PATH} -DUSE_SSE=${USE_SSE}
)

vcpkg_install_cmake()

# Remove debug include
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Copy copright information
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/speexdsp" RENAME "copyright")

vcpkg_copy_pdbs()
