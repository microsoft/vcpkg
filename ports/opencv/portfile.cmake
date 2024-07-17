SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

file(WRITE "${CURRENT_INSTALLED_DIR}/share/opencv/vcpkg-cmake-wrapper.cmake"
[[
set(OpenCV_DIR "${CURRENT_INSTALLED_DIR}/share/opencv4/" CACHE PATH "Path to OpenCVConfig.cmake" FORCE)
set(OpenCV_ROOT "${CURRENT_INSTALLED_DIR}/share/opencv4/") #to force find_package(OpenCV) to look for specific version and not randomly pick one in between opencv* installed
_find_package(${ARGS})
]])
