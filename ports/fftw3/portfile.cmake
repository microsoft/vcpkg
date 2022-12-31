vcpkg_download_distfile(ARCHIVE
    URLS "https://www.fftw.org/fftw-3.3.10.tar.gz"
    FILENAME "fftw-3.3.10.tar.gz"
    SHA512 2d34b5ccac7b08740dbdacc6ebe451d8a34cf9d9bfec85a5e776e87adf94abfd803c222412d8e10fbaa4ed46f504aa87180396af1b108666cde4314a55610b40
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        omp_test.patch
        patch_targets.patch
        fftw3_arch_fix.patch
        aligned_malloc.patch
        bigobj.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openmp ENABLE_OPENMP
        threads ENABLE_THREADS
        threads WITH_COMBINED_THREADS
        avx2 ENABLE_AVX2
        avx ENABLE_AVX
        sse2 ENABLE_SSE2
        sse ENABLE_SSE
)

set(ENABLE_FLOAT_CMAKE fftw3f)
set(ENABLE_LONG_DOUBLE_CMAKE fftw3l)
set(ENABLE_DEFAULT_PRECISION_CMAKE fftw3)

foreach(PRECISION ENABLE_FLOAT ENABLE_LONG_DOUBLE ENABLE_DEFAULT_PRECISION)
    if(PRECISION STREQUAL "ENABLE_LONG_DOUBLE")
        vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS 
            -D${PRECISION}=ON
            -DENABLE_OPENMP=${ENABLE_OPENMP}
            -DENABLE_THREADS=${HAVE_THREADS}
            -DWITH_COMBINED_THREADS=${HAVE_THREADS}
            -DBUILD_TESTS=OFF
        )
    else()
        vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS 
            -D${PRECISION}=ON
            ${FEATURE_OPTIONS}
            -DBUILD_TESTS=OFF
        )
    endif()

    vcpkg_cmake_install()

    vcpkg_copy_pdbs()

    vcpkg_cmake_config_fixup(PACKAGE_NAME ${${PRECISION}_CMAKE} CONFIG_PATH lib/cmake)
endforeach()

file(READ "${SOURCE_PATH}/api/fftw3.h" _contents)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "defined(FFTW_DLL)" "0" _contents "${_contents}")
else()
    string(REPLACE "defined(FFTW_DLL)" "1" _contents "${_contents}")
endif()
file(WRITE "${SOURCE_PATH}/include/fftw3.h" "${_contents}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
