set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# Capture pristine toolchain configuration
vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

# Capture (g)fortran configuration
include(vcpkg_find_fortran)
# Side effects!
block(SCOPE_FOR VARIABLES
    PROPAGATE
        FORTRAN_CMAKE
        VCPKG_CRT_LINKAGE
        VCPKG_LIBRARY_LINKAGE
        VCPKG_POLICY_SKIP_DUMPBIN_CHECKS
        VCPKG_USE_INTERNAL_Fortran
    # DO NOT PROPAGATE:
    #   VCPKG_CHAINLOAD_TOOLCHAIN_FILE
)
    set(env_path_backup "$ENV{PATH}")
    vcpkg_find_fortran(FORTRAN_CMAKE)
    set(ENV{PATH} "${env_path_backup}")
endblock()

# Transform
if(VCPKG_USE_INTERNAL_Fortran)
    list(FILTER FORTRAN_CMAKE EXCLUDE REGEX "-DCMAKE_C_COMPILER=")
    string(REPLACE "-DCMAKE_Fortran_COMPILER" "-DMINGW_GFORTRAN" FORTRAN_CMAKE "${FORTRAN_CMAKE}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    DISABLE_PARALLEL_CONFIGURE  # for split stdout/stderr logs
    OPTIONS
        ${FORTRAN_CMAKE}
        "-DEXPECTED_C_COMPILER=${VCPKG_DETECTED_CMAKE_C_COMPILER}"
        "-DEXPECTED_CXX_COMPILER=${VCPKG_DETECTED_CMAKE_CXX_COMPILER}"
        --trace-expand
)
vcpkg_cmake_build()
