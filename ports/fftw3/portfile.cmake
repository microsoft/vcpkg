
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/fftw-3.3.6-pl2)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.fftw.org/fftw-3.3.6-pl2.tar.gz"
    FILENAME "fftw-3.3.6-pl2.tar.gz"
    SHA512 e130309856752a1555b6d151c4d0ce9eb4b2c208fff7e3e89282ca8ef6104718f865cbb5e9c4af4367b3615b69b0d50fd001a26d74fd5324ff2faabe14fe3472
)

vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config.h DESTINATION ${SOURCE_PATH})

option(BUILD_SINGLE "Additionally build single precision library" ON)
option(BUILD_LONG_DOUBLE "Additionally build long-double precision library" ON)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
      -DBUILD_SINGLE=${BUILD_SINGLE}
      -DBUILD_LONG_DOUBLE=${BUILD_LONG_DOUBLE}
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
