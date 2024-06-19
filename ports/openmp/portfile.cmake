SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/openmp/vcpkg-cmake-wrapper.cmake" COPYONLY)
