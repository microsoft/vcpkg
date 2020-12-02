vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookresearch/flashlight
    REF b4b8f4a506210dd63fbf4eaf9e2b49b89a8762b6
    SHA512 47b97dedab4aaf7367f723dc9f66adec02f4de878371b31ece2c8727454f9cc90450abb8142edeaa734c1cf610d15b6d573a3140ee4479c9de29fecd45ca78ec
    HEAD_REF master
)

################################### Build ###################################
# Default flags
set(FL_DEFAULT_VCPKG_CMAKE_FLAGS
  -DFL_BUILD_TESTS=OFF
  -DFL_BUILD_EXAMPLES=OFF
  -DFL_BACKEND=CUDA # this port is CUDA-backend only
  -DFL_BUILD_STANDALONE=OFF
  -DFL_INSTALL_CMAKE_DIR=${CURRENT_PACKAGES_DIR}/share/${PORT} # for CMake configs/targets
  )

# Determine which backend to build via specified feature
vcpkg_check_features(
  OUT_FEATURE_OPTIONS FL_BACKEND_FEATURE_OPTIONS
  FEATURES
    lib FL_BUILD_LIBRARIES
    fl FL_BUILD_CORE
    asr FL_BUILD_APP_ASR
    imgclass FL_BUILD_APP_IMG_CLASS
)

# Build and install
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FL_DEFAULT_VCPKG_CMAKE_FLAGS} ${FL_BACKEND_FEATURE_OPTIONS}
)
vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Binaries/tools
set(FLASHLIGHT_TOOLS "")
if ("imgclass" IN_LIST FEATURES)
  list(APPEND FLASHLIGHT_TOOLS fl_imageNetResnet34)
endif()
if ("asr" IN_LIST FEATURES)
  list(APPEND FLASHLIGHT_TOOLS fl_asr_train fl_asr_test fl_asr_decode)
endif()
list(LENGTH FLASHLIGHT_TOOLS NUM_TOOLS)
if (NUM_TOOLS GREATER 0)
  vcpkg_copy_tools(TOOL_NAMES ${FLASHLIGHT_TOOLS} AUTO_CLEAN)
endif()

# Copyright and license
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/flashlight-cuda RENAME copyright)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/flashlight-cuda RENAME license)
