SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(USE_OPENCV_VERSION "4")
configure_file("${CURRENT_PORT_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/opencv/vcpkg-cmake-wrapper.cmake" @ONLY)
