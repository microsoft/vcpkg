include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/speexdsp-1.2.0)
set(CMAKE_PATH ${CMAKE_CURRENT_LIST_DIR})
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://downloads.xiph.org/releases/speex/speexdsp-1.2.0.tar.gz"
    FILENAME "speexdsp-1.2.0.tar.gz"
    SHA512 e357cd5377415ea66c862302c7cf8bf6a10063cacd903f0846478975b87974cf5bdf00e2c6759d8f4f453c4c869cf284e9dc948a84a83d7b2ab96bd5405c05ec
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
