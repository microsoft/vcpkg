set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

include(vcpkg_find_fortran)
vcpkg_find_fortran(FORTRAN_CMAKE)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        ${FORTRAN_CMAKE}
        "-DEXPECTED_C_COMPILER=${VCPKG_DETECTED_CMAKE_C_COMPILER}"
        "-DEXPECTED_CXX_COMPILER=${VCPKG_DETECTED_CMAKE_CXX_COMPILER}"
)
vcpkg_cmake_build()
