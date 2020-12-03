vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookresearch/flashlight
    REF 99acf9f530188fe95313fa3e0e8d8ab86b0f492f
    SHA512 a59de27d17b19c06853c4b44e60ddc8e6d42edbf08f4c26399aafc42f85d941105d306c5d10ee28c5ab32000bd8c31bc2f85ce30b2f045fa54b054dfad4cd15c
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
