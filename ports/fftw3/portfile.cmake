vcpkg_download_distfile(ARCHIVE
    URLS "https://www.fftw.org/fftw-3.3.10.tar.gz"
    FILENAME "fftw-3.3.10.tar.gz"
    SHA512 2d34b5ccac7b08740dbdacc6ebe451d8a34cf9d9bfec85a5e776e87adf94abfd803c222412d8e10fbaa4ed46f504aa87180396af1b108666cde4314a55610b40
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fftw3_arch_fix.patch
        aligned_malloc.patch
        bigobj.patch
        fix-openmp.patch
        install-subtargets.patch
        fix-wrong-version.patch # https://github.com/FFTW/fftw3/commit/0842f00ae6b6e1f3aade155bc0edd17a7313fa6a
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openmp  ENABLE_OPENMP
        openmp  CMAKE_REQUIRE_FIND_PACKAGE_OpenMP
        threads ENABLE_THREADS
        threads WITH_COMBINED_THREADS
        avx2    ENABLE_AVX2
        avx     ENABLE_AVX
        sse2    ENABLE_SSE2
        sse     ENABLE_SSE
)

set(package_names  fftw3 fftw3f fftw3l)
set(fftw3_options  "")
set(fftw3f_options -DENABLE_FLOAT=ON)
set(fftw3l_options -DENABLE_LONG_DOUBLE=ON -DENABLE_AVX2=OFF -DENABLE_AVX=OFF -DENABLE_SSE2=OFF)

foreach(package_name IN LISTS package_names)
    message(STATUS "${package_name}...")
    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        LOGFILE_BASE "config-${package_name}-${TARGET_TRIPLET}"
        OPTIONS 
            ${FEATURE_OPTIONS}
            ${${package_name}_options} # may override FEATURE_OPTIONS
            -DBUILD_TESTS=OFF
        MAYBE_UNUSED_VARIABLES
            CMAKE_REQUIRE_FIND_PACKAGE_OpenMP
    )
    vcpkg_cmake_build(
        LOGFILE_BASE "install-${package_name}"
        TARGET install
    )
    vcpkg_copy_pdbs()

    vcpkg_cmake_config_fixup(PACKAGE_NAME "${package_name}" CONFIG_PATH "lib/cmake/${package_name}")
endforeach()
vcpkg_fixup_pkgconfig()

file(READ "${SOURCE_PATH}/api/fftw3.h" _contents)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "defined(FFTW_DLL)" "0" _contents "${_contents}")
else()
    string(REPLACE "defined(FFTW_DLL)" "1" _contents "${_contents}")
endif()
file(WRITE "${SOURCE_PATH}/include/fftw3.h" "${_contents}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
