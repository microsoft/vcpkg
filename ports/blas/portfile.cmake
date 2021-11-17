SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# Make sure BLAS can be found
vcpkg_configure_cmake(SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}" PREFER_NINJA)
