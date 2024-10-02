SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

file(WRITE "${CURRENT_PACKAGES_DIR}/share/opencv/vcpkg-cmake-wrapper.cmake"
[[
set(OpenCV_DIR "${CMAKE_CURRENT_LIST_DIR}/../opencv4/" CACHE PATH "Path to OpenCVConfig.cmake" FORCE)
set(OpenCV_ROOT "${CMAKE_CURRENT_LIST_DIR}/../opencv4/") #to force find_package(OpenCV) to look for specific version and not randomly pick one in between opencv* installed
_find_package(${ARGS})
]])
