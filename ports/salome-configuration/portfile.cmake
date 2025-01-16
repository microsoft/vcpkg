string(REPLACE "." "_" UNDERSCORE_VERSION "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_CONFIG
    REPO SalomePlatform/configuration
    REF "V${UNDERSCORE_VERSION}"
    SHA512 e905a0f1e1105f5a630153036b80942032ccc07fad411d390e4da19d56561e224ac2ac681873b97d811d33ce4b0c9518ce3488b54414a42e011c39628d8e1673
    HEAD_REF master
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
