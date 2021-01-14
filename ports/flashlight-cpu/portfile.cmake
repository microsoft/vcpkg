if (EXISTS "${CURRENT_INSTALLED_DIR}/share/flashlight-cuda")
  message(FATAL_ERROR "flashlight-cuda is installed; only one Flashlight "
    "backend package can be installed at once. Uninstall and try again:"
    "\n    vcpkg remove flashlight-cuda\n")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookresearch/flashlight
    REF 3c2bdd22d04e75ac7ac78a4d8815ee6231b77c27
    SHA512 6268c6bd400dea7d00ed171e8918f47aa3c6ba9d662304b0b62bfa5bac889f56eb3d23c1980605572a6632be9da5e8d9224b609c100343953463c0f34b875cf1
    HEAD_REF master
)

# Default flags
set(FL_DEFAULT_VCPKG_CMAKE_FLAGS
  -DFL_BUILD_TESTS=OFF
  -DFL_BUILD_EXAMPLES=OFF
  -DFL_BACKEND=CPU # this port is CPU-backend only
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
