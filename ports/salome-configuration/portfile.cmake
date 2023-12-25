vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH_CONFIG
    URL "https://git.salome-platform.org/gitpub/tools/configuration.git"
    REF "25f724f7a6c0000330a40c3851dcd8bc2493e1fa"
)

file(COPY "${SOURCE_PATH_CONFIG}/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH_CONFIG}/copyright/CEA_EDF.txt")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake" [[set(SALOME_CONFIGURATION_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}")]])

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

file(READ "${CURRENT_PACKAGES_DIR}/share/${PORT}/cmake/SalomeMacros.cmake" contents)
if(HDF5_WITH_PARALLEL)
    string(PREPEND contents "set(SALOME_USE_MPI ON)\n")
endif()
string(REPLACE [[SET(CMAKE_PREFIX_PATH "${${_envvar}}")]] "" contents "${contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/cmake/SalomeMacros.cmake" "${contents}")
