SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# Make sure BLAS can be found
vcpkg_cmake_configure(SOURCE_PATH "${CURRENT_PORT_DIR}"
                      OPTIONS -DVCPKG_HOST_TRIPLET=${HOST_TRIPLET})
