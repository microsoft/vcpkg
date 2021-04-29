vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO AlexeyAB/darknet
  REF 91efb7c7f6c00a4616ed58735f7c670908d0a849
  SHA512 7f6187f8ccc89295daf7b15288bae0bf53638970422ced80a4a755e2b4765cda36f532ebc5c32a28804a2ed0ac6375e9a8f7449a9002e1b373378635a54f2c96
  HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    cuda ENABLE_CUDA
    cudnn ENABLE_CUDNN
)

#do not move following features to vcpkg_check_features because they break themselves: one off will turn off the others even if true
set(ENABLE_OPENCV FALSE)
set(ENABLE_OPENCV_WITH_CUDA FALSE)
if ("opencv-base" IN_LIST FEATURES OR "opencv2-base" IN_LIST FEATURES OR "opencv3-base" IN_LIST FEATURES)
  set(ENABLE_OPENCV TRUE)
endif()
if ("opencv-cuda" IN_LIST FEATURES OR "opencv2-cuda" IN_LIST FEATURES OR "opencv3-cuda" IN_LIST FEATURES)
  set(ENABLE_OPENCV TRUE)
  set(ENABLE_OPENCV_WITH_CUDA TRUE)
endif()

if ("cuda" IN_LIST FEATURES)
  if (NOT VCPKG_CMAKE_SYSTEM_NAME AND NOT ENV{CUDACXX})
    #CMake looks for nvcc only in PATH and CUDACXX env vars for the Ninja generator. Since we filter path on vcpkg and CUDACXX env var is not set by CUDA installer on Windows, CMake cannot find CUDA when using Ninja generator, so we need to manually enlight it if necessary (https://gitlab.kitware.com/cmake/cmake/issues/19173). Otherwise we could just disable Ninja and use MSBuild, but unfortunately CUDA installer does not integrate with some distributions of MSBuild (like the ones inside Build Tools), making CUDA unavailable otherwise in those cases, which we want to avoid
    set(ENV{CUDACXX} "$ENV{CUDA_PATH}/bin/nvcc.exe")
  endif()
endif()

#make sure we don't use any integrated pre-built library nor any unnecessary CMake module
file(REMOVE_RECURSE ${SOURCE_PATH}/3rdparty)
file(REMOVE ${SOURCE_PATH}/cmake/Modules/FindPThreads_windows.cmake)
file(REMOVE ${SOURCE_PATH}/cmake/Modules/FindCUDNN.cmake)
file(REMOVE ${SOURCE_PATH}/cmake/Modules/FindStb.cmake)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  DISABLE_PARALLEL_CONFIGURE
  PREFER_NINJA
  OPTIONS ${FEATURE_OPTIONS}
    -DINSTALL_BIN_DIR:STRING=bin
    -DINSTALL_LIB_DIR:STRING=lib
    -DENABLE_OPENCV:BOOL=${ENABLE_OPENCV}
    -DENABLE_OPENCV_WITH_CUDA:BOOL=${ENABLE_OPENCV_WITH_CUDA}
)

vcpkg_install_cmake()
vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES darknet uselib)
if ("opencv-cuda" IN_LIST FEATURES OR "opencv3-cuda" IN_LIST FEATURES)
  vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES uselib_track)
endif()

file(COPY ${SOURCE_PATH}/cfg DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(COPY ${SOURCE_PATH}/data DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/scripts/download_weights.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/scripts)
message(STATUS "To download weight files, please go to ${CURRENT_INSTALLED_DIR}/tools/${PORT}/scripts and run ./download_weights.ps1")
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
