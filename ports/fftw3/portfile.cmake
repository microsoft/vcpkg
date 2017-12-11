include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/fftw-3.3.7)

# This can be removed in the next source code update
if(EXISTS "${SOURCE_PATH}/CMakeLists.txt")
    file(READ "${SOURCE_PATH}/CMakeLists.txt" _contents)
    if("${_contents}" MATCHES "-D_OPENMP -DLIBFFTWF33_EXPORTS /openmp /bigobj")
        file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src)
    endif()
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.fftw.org/fftw-3.3.7.tar.gz"
    FILENAME "fftw-3.3.7.tar.gz"
    SHA512 a5db54293a6d711408bed5894766437eee920be015ad27023c7a91d4581e2ff5b96e3db0201e6eaccf7b064c4d32db1a2a8fab3e6813e524b4743ddd6216ba77
)

vcpkg_extract_source_archive(${ARCHIVE})

option(BUILD_SINGLE "Additionally build single precision library" ON)
option(BUILD_LONG_DOUBLE "Additionally build long-double precision library" ON)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_SINGLE=${BUILD_SINGLE} -DBUILD_LONG_DOUBLE=${BUILD_LONG_DOUBLE}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/api/fftw3.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share/fftw3)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)


if (VCPKG_CRT_LINKAGE STREQUAL dynamic)
    vcpkg_apply_patches(
           SOURCE_PATH ${CURRENT_PACKAGES_DIR}/include
           PATCHES
                   ${CMAKE_CURRENT_LIST_DIR}/fix-dynamic.patch)
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/fftw3)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/fftw3/COPYING ${CURRENT_PACKAGES_DIR}/share/fftw3/copyright)
