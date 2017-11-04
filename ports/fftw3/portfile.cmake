include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/fftw-3.3.7)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.fftw.org/fftw-3.3.7.tar.gz"
    FILENAME "fftw-3.3.7.tar.gz"
    SHA512 a5db54293a6d711408bed5894766437eee920be015ad27023c7a91d4581e2ff5b96e3db0201e6eaccf7b064c4d32db1a2a8fab3e6813e524b4743ddd6216ba77
)

vcpkg_extract_source_archive(${ARCHIVE})

option(BUILD_SINGLE "Additionally build single precision library" ON)
option(BUILD_LONG_DOUBLE "Additionally build long-double precision library" ON)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config.h DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_SINGLE=${BUILD_SINGLE} -DBUILD_LONG_DOUBLE=${BUILD_LONG_DOUBLE}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/api/fftw3.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

if (VCPKG_CRT_LINKAGE STREQUAL dynamic)
    vcpkg_apply_patches(
           SOURCE_PATH ${CURRENT_PACKAGES_DIR}/include
           PATCHES
                   ${CMAKE_CURRENT_LIST_DIR}/fix-dynamic.patch)
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/fftw3)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/fftw3/COPYING ${CURRENT_PACKAGES_DIR}/share/fftw3/copyright)
