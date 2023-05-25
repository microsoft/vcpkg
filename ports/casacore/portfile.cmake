include(vcpkg_find_fortran)

vcpkg_from_github(
    OUT_SOURCE_PATH src
    REPO "casacore/casacore"
    REF "v3.5.0"
    SHA512 5ec72450dc60b833864416850e08a4a0903f02b9917e0218aafcef15475dedce88318ea526f44e27b214acad14d31542fed7ea2462d6b9590d178c1085466db4
    PATCHES
        001-casacore-cmake.patch
)

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)
vcpkg_find_fortran(fortran_args)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tablelocking        ENABLE_TABLELOCKING
        deprecated          BUILD_DEPRECATED
        dysco               BUILD_DYSCO
        threads             USE_THREADS
        readline            USE_READLINE
        adios2              USE_ADIOS2
        hdf5                USE_HDF5
        mpi                 USE_MPI
        openmp              USE_OPENMP
        python3             BUILD_PYTHON3
        stacktrace          USE_STACKTRACE
        casabuild           CASA_BUILD)

if(${BUILD_PYTHON3} STREQUAL "ON")
    message(FATAL_ERROR "Python3 Support not available: https://github.com/microsoft/vcpkg/discussions/29645")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${src}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_PYTHON=OFF
        -DBUILD_TESTING=OFF
        ${fortran_args}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${src}/COPYING")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
