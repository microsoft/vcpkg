if (EXISTS "${CURRENT_INSTALLED_DIR}/share/flashlight-cpu")
  message(FATAL_ERROR "flashlight-cpu is installed; only one Flashlight "
    "backend package can be installed at once. Uninstall and try again:"
    "\n    vcpkg remove flashlight-cpu\n")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO flashlight/flashlight
    REF 76f7fa7f5a162c73d6bf8befdb8e197a4dc7515d # 0.3 branch tip
    SHA512 87786f9443d27ac9b513cf582caea13dccfa344e55a4970c0c2c7df7530260ad38cc578690ebf2fa256e8ea943abea547e0e6d5ee0ba090b336c4f7af8d2f53f
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
    objdet FL_BUILD_APP_OBJDET
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
  list(APPEND FLASHLIGHT_TOOLS
    fl_img_imagenet_resnet34
    fl_img_imagenet_eval
    fl_img_imagenet_vit
  )
endif()
if ("asr" IN_LIST FEATURES)
  list(APPEND FLASHLIGHT_TOOLS
    fl_asr_train
    fl_asr_test
    fl_asr_decode
    fl_asr_align
    fl_asr_voice_activity_detection_ctc
    fl_asr_arch_benchmark
  )
endif()
if ("lm" IN_LIST FEATURES)
  list(APPEND FLASHLIGHT_TOOLS
    fl_lm_dictionary_builder
    fl_lm_train
    fl_lm_test
    )
endif()
list(LENGTH FLASHLIGHT_TOOLS NUM_TOOLS)
if (NUM_TOOLS GREATER 0)
  vcpkg_copy_tools(TOOL_NAMES ${FLASHLIGHT_TOOLS} AUTO_CLEAN)
endif()

# Copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
