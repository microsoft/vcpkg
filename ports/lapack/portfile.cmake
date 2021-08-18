SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

#x_vcpkg_find_fortran(FORTRAN_CMAKE)
# Make sure LAPACK can be found
vcpkg_configure_cmake(SOURCE_PATH ${CURRENT_PORT_DIR}
                      OPTIONS -DCMAKE_PREFIX_PATH="${CURRENT_PACKAGES_DIR}"
                              #--trace-expand
                              )
