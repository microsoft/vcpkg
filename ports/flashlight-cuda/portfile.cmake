vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookresearch/flashlight
    REF 94486a1108fd0511a05523bfa1cf734bc14022f7
    SHA512 73a7547a26020be21d26393c2758cc235b452a0fb5d8537777bdbcc556f71846e07eca649167902dd7d0743cb7d10738b4e38cd7fe69b51b6122f3241e2edd84
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
