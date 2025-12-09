if (EXISTS "${CURRENT_INSTALLED_DIR}/share/flashlight")
  message(FATAL_ERROR "Only one of flashlight-cpu and flashlight-cuda"
    "can be installed at once. Uninstall and try again:"
    "\n    vcpkg remove flashlight-cuda\n")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO flashlight/flashlight
    REF 626914e79073c5547513de649af706f7e2b796ad # 0.3 branch tip
    SHA512 a22057cfa4cfe7acd95cbc5445a30870cce3cdde89066d1d75f40be0d73b069a49e89b226fe5337488cfe5618dd25958679c0636a3e4008312f01606328becfa
    HEAD_REF master
    PATCHES fix-dependencies.patch
)

################################### Build ###################################
# Default flags
set(FL_DEFAULT_VCPKG_CMAKE_FLAGS
  -DFL_BUILD_TESTS=OFF
  -DFL_BUILD_EXAMPLES=OFF
  -DFL_BACKEND=CPU # this port is CPU-backend only
  -DFL_BUILD_STANDALONE=OFF
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
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        ${FL_DEFAULT_VCPKG_CMAKE_FLAGS} 
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        "-DFL_INSTALL_CMAKE_DIR=${CURRENT_PACKAGES_DIR}/debug/share/flashlight"
    OPTIONS_RELEASE
        "-DFL_INSTALL_CMAKE_DIR=${CURRENT_PACKAGES_DIR}/share/flashlight"
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME flashlight)

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
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
