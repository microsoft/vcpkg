SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)
set(BLA_VENDOR OpenBLAS)
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
# Make sure BLAS can be found
vcpkg_configure_cmake(SOURCE_PATH ${CURRENT_PORT_DIR}
                      OPTIONS -DCMAKE_PREFIX_PATH="${CURRENT_PACKAGES_DIR}"
                              -DBLA_VENDOR=${BLA_VENDOR})
