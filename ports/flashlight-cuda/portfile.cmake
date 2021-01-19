if (EXISTS "${CURRENT_INSTALLED_DIR}/share/flashlight-cpu")
  message(FATAL_ERROR "flashlight-cpu is installed; only one Flashlight "
    "backend package can be installed at once. Uninstall and try again:"
    "\n    vcpkg remove flashlight-cpu\n")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookresearch/flashlight
    REF 81c4d8d5ea57e9ceaa6db3b17f0861491fd31383
    SHA512 988da269be81f7b4897d72e52683259f4223029b5012150958b9b21c7103fe49a2458ffa5623ed53c125a98f7294541af46cd68b17e9213269e5a2aecfaabb67
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

# Determine which components to build via specified feature
vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    lib FL_BUILD_LIBRARIES
    fl FL_BUILD_CORE
    asr FL_BUILD_APP_ASR
    imgclass FL_BUILD_APP_IMGCLASS
    lm FL_BUILD_APP_LM
)

# Build and install
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        ${FL_DEFAULT_VCPKG_CMAKE_FLAGS} 
        ${FEATURE_OPTIONS}
)
vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Binaries/tools
set(FLASHLIGHT_TOOLS "")
if ("imgclass" IN_LIST FEATURES)
  list(APPEND FLASHLIGHT_TOOLS fl_img_imagenet_resnet34)
endif()
if ("asr" IN_LIST FEATURES)
  list(APPEND FLASHLIGHT_TOOLS
    fl_asr_train
    fl_asr_test
    fl_asr_decode
    fl_asr_align
    fl_asr_voice_activity_detection_ctc
  )
endif()
if ("lm" IN_LIST FEATURES)
  list(APPEND FLASHLIGHT_TOOLS fl_lm_train fl_lm_dictionary_builder)
endif()
list(LENGTH FLASHLIGHT_TOOLS NUM_TOOLS)
if (NUM_TOOLS GREATER 0)
  vcpkg_copy_tools(TOOL_NAMES ${FLASHLIGHT_TOOLS} AUTO_CLEAN)
endif()

# Copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
