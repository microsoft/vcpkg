SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# Make sure LAPACK can be found
vcpkg_cmake_configure(SOURCE_PATH "${CURRENT_PORT_DIR}"
                      OPTIONS "-DCMAKE_PREFIX_PATH=${CURRENT_PACKAGES_DIR}")
