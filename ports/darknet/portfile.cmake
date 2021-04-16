vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO AlexeyAB/darknet
  REF 00d578e327c22638ea12e73c4efb74c798c08de5
  SHA512 ef2d46fab670759e9c22d0233b60192bfe47669e29d2ec1e020a77dfaf09894a93160c11de070bc39d86109dd2a37ca7172fbb081809b1ea2783207a6e385b2c
  HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    cuda ENABLE_CUDA
    cudnn ENABLE_CUDNN
)

#do not move following features to vcpkg_check_features because they break themselves: one off will turn off the others even if true
set(ENABLE_OPENCV FALSE)
if ("opencv-base" IN_LIST FEATURES OR "opencv2-base" IN_LIST FEATURES OR "opencv3-base" IN_LIST FEATURES)
  set(ENABLE_OPENCV TRUE)
endif()
set(ENABLE_OPENCV FALSE)
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
if ("opencv-cuda" IN_LIST FEATURES OR "opencv2-cuda" IN_LIST FEATURES OR "opencv3-cuda" IN_LIST FEATURES)
vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES uselib_track)

file(COPY ${SOURCE_PATH}/cfg DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(COPY ${SOURCE_PATH}/data DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/scripts/download_weights.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/scripts)
message(STATUS "To download weight files, please go to ${CURRENT_PACKAGES_DIR}/tools/${PORT}/scripts and run ./download_weights.ps1")
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
