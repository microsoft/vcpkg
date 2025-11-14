# Use local source for testing
set(SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../stardots-sdk-cpp")

# Suppress warnings for official submission
set(VCPKG_POLICY_ALLOW_DEBUG_INCLUDE enabled)
set(VCPKG_POLICY_SKIP_MISPLACED_CMAKE_FILES_CHECK enabled)
set(VCPKG_POLICY_SKIP_LIB_CMAKE_MERGE_CHECK enabled)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DCMAKE_BUILD_TYPE=Release
)

vcpkg_install_cmake()

# Install usage file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_install_copyright(
  FILE_LIST "${SOURCE_PATH}/LICENSE"
)
