include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/fftw-3.3.8)

# This can be removed in the next source code update
if(EXISTS "${SOURCE_PATH}/CMakeLists.txt")
    file(READ "${SOURCE_PATH}/CMakeLists.txt" _contents)
    if("${_contents}" MATCHES "-D_OPENMP -DLIBFFTWF33_EXPORTS /openmp /bigobj")
        file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src)
    endif()
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.fftw.org/fftw-3.3.8.tar.gz"
    FILENAME "fftw-3.3.8.tar.gz"
    SHA512 ab918b742a7c7dcb56390a0a0014f517a6dff9a2e4b4591060deeb2c652bf3c6868aa74559a422a276b853289b4b701bdcbd3d4d8c08943acf29167a7be81a38
)

vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/omp_test.patch
        ${CMAKE_CURRENT_LIST_DIR}/patch_targets.patch
        ${CMAKE_CURRENT_LIST_DIR}/fftw3_arch_fix.patch
)

if ("openmp" IN_LIST FEATURES)
    set(ENABLE_OPENMP ON)
else()
    set(ENABLE_OPENMP OFF)
endif()

if ("avx" IN_LIST FEATURES)
    set(HAVE_AVX ON)
    set(HAVE_SSE ON)
    set(HAVE_SSE2 ON)
else()
    set(HAVE_AVX OFF)
endif()

if ("avx2" IN_LIST FEATURES)
    set(HAVE_AVX2 ON)
    set(HAVE_FMA ON)
    set(HAVE_SSE ON)
    set(HAVE_SSE2 ON)
else()
    set(HAVE_AVX2 OFF)
    set(HAVE_FMA OFF)
endif()

if ("sse" IN_LIST FEATURES)
    set(HAVE_SSE ON)
else()
    set(HAVE_SSE OFF)
endif()

if ("sse2" IN_LIST FEATURES)
    set(HAVE_SSE2 ON)
    set(HAVE_SSE ON)
else()
    set(HAVE_SSE2 OFF)
endif()

if ("threads" IN_LIST FEATURES)
    set(HAVE_THREADS ON)
else()
    set(HAVE_THREADS OFF)
endif()

foreach(PRECISION ENABLE_DEFAULT_PRECISION ENABLE_FLOAT ENABLE_LONG_DOUBLE)
    if(${PRECISION} MATCHES "ENABLE_LONG_DOUBLE")
        vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS 
            -D${PRECISION}=ON
            -DENABLE_OPENMP=${ENABLE_OPENMP}
            -DENABLE_THREADS=${HAVE_THREADS}
        )
    else()
        vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS 
            -D${PRECISION}=ON
            -DENABLE_OPENMP=${ENABLE_OPENMP}
            -DHAVE_SSE=${HAVE_SSE}
            -DHAVE_SSE2=${HAVE_SSE2}
            -DHAVE_AVX=${HAVE_AVX}
            -DHAVE_AVX2=${HAVE_AVX2}
            -DHAVE_FMA=${HAVE_FMA}
            -DENABLE_THREADS=${HAVE_THREADS}
        )
    endif()

    vcpkg_install_cmake()
    vcpkg_copy_pdbs()

    file(COPY ${SOURCE_PATH}/api/fftw3.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

    if (VCPKG_CRT_LINKAGE STREQUAL dynamic)
        vcpkg_apply_patches(
               SOURCE_PATH ${CURRENT_PACKAGES_DIR}/include
               PATCHES
                       ${CMAKE_CURRENT_LIST_DIR}/fix-dynamic.patch)
    endif()

    # Cleanup
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
endforeach()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/fftw3)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/fftw3/COPYING ${CURRENT_PACKAGES_DIR}/share/fftw3/copyright)
