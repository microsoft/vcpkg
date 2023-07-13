SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

file(INSTALL "${CURRENT_INSTALLED_DIR}/share/opencv4/OpenCVConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CURRENT_INSTALLED_DIR}/share/opencv4/OpenCVConfig-version.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CURRENT_INSTALLED_DIR}/share/opencv4/OpenCVModules.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CURRENT_INSTALLED_DIR}/share/opencv4/OpenCVModules-release.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
if (NOT VCPKG_BUILD_TYPE)
  file(INSTALL "${CURRENT_INSTALLED_DIR}/share/opencv4/OpenCVModules-debug.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()
