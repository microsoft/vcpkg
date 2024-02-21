vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LLNL/sundials
    REF aaeab8d907c6b7dfca86041401fdc1448f35f826
    SHA512 0cb81fdb86e748414798e97de63493fdd23fc922050c9f7fe8886e70ecf61c0fced22f68eaed066753543f5072dfb7ac2d8081b9c0c5a6deb2e932bf27b06d99
    HEAD_REF master
    PATCHES
        install-dlls-in-bin.patch
        remove-mpi-include.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SUN_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SUN_BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        arkode      BUILD_ARKODE  
        cvode       BUILD_CVODE
        cvodes      BUILD_CVODES
        ida         BUILD_IDA
        idas        BUILD_IDAS
        kinsol      BUILD_KINSOL
        cuda        ENABLE_CUDA
        ginkgo      ENABLE_GINKGO
        hypre       ENABLE_HYPRE
        klu         ENABLE_KLU
        lapack      ENABLE_LAPACK
        magma       ENABLE_MAGMA
        mpi         ENABLE_MPI
        openmp      ENABLE_OPENMP
        test        _BUILD_EXAMPLES
)

vcpkg_list(SET OPTIONS)

# Only enable the standard test suite.
if(_BUILD_EXAMPLES)
    vcpkg_list(APPEND OPTIONS
        -DEXAMPLES_ENABLE_C=Off
        -DEXAMPLES_ENABLE_CXX=Off
        -DEXAMPLES_ENABLE_CUDA=Off
    )
endif()

if(ENABLE_GINKGO)
    vcpkg_list(SET SUNDIALS_GINKGO_BACKENDS "REF")
    if(ENABLE_OPENMP)
        vcpkg_list(APPEND SUNDIALS_GINKGO_BACKENDS "OMP")
    endif()
    if(ENABLE_CUDA)
        vcpkg_list(APPEND SUNDIALS_GINKGO_BACKENDS "CUDA")
    endif()
    vcpkg_list(APPEND OPTIONS "-DSUNDIALS_GINKGO_BACKENDS=${SUNDIALS_GINKGO_BACKENDS}")
endif()

# MAGMA requires 32-bit sunindextype.
if(ENABLE_MAGMA) 
    vcpkg_list(APPEND OPTIONS "-DSUNDIALS_INDEX_SIZE=32")
endif()

# SUNDIALS requires a Fortran compiler to automatically detect name mangling in
# Fortran external symbols. This is a configuration check and Fortran is not
# otherwise used. If a Fortran compiler is unavailable (typically on Windows),
# just assume the standard convention to disable the check.
if(ENABLE_LAPACK AND NOT CMAKE_Fortran_COMPILER_LOADED)
    vcpkg_list(APPEND OPTIONS
        "-DSUNDIALS_F77_FUNC_CASE=LOWER"
        "-DSUNDIALS_F77_FUNC_UNDERSCORES=ONE"
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_STATIC_LIBS=${SUN_BUILD_STATIC}
        -DBUILD_SHARED_LIBS=${SUN_BUILD_SHARED}
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        ${FEATURE_OPTIONS}
        ${OPTIONS}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/LICENSE")

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
