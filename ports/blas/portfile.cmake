SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# Make sure BLAS can be found
vcpkg_configure_cmake(SOURCE_PATH ${CURRENT_PORT_DIR}
                      OPTIONS -DCMAKE_PREFIX_PATH="${CURRENT_PACKAGES_DIR}")
