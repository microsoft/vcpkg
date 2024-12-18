set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

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
    vcpkg_find_fortran(FORTRAN_CMAKE)
endblock()

if(VCPKG_USE_INTERNAL_Fortran)
    list(FILTER FORTRAN_CMAKE EXCLUDE REGEX "-DCMAKE_C_COMPILER=")
    list(APPEND FORTRAN_CMAKE --trace-expand)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        ${FORTRAN_CMAKE}
        "-DEXPECTED_C_COMPILER=${VCPKG_DETECTED_CMAKE_C_COMPILER}"
        "-DEXPECTED_CXX_COMPILER=${VCPKG_DETECTED_CMAKE_CXX_COMPILER}"
)
vcpkg_cmake_build()
