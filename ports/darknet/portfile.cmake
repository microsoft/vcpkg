vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO AlexeyAB/darknet
  REF 19dde2f296941a75b0b9202cccd59528bde7f65a
  SHA512 3f24fd5c69a00032e63fc8479d46dedf9008909c5e0f37847f0427c39f35e68f35a5ee89820cd0a179cb282e49730e6b1465a027d89bef585e9a1cfca6e3d3a2
  HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    cuda ENABLE_CUDA
    cudnn ENABLE_CUDNN
)

#do not move following features to vcpkg_check_features because they break themselves: one off will turn off the others even if true
set(ENABLE_OPENCV FALSE)
if ("opencv-base" IN_LIST FEATURES OR "opencv-cuda" IN_LIST FEATURES)
  set(ENABLE_OPENCV TRUE)
endif()

if ("cuda" IN_LIST FEATURES)
  if (NOT VCPKG_CMAKE_SYSTEM_NAME AND NOT ENV{CUDACXX})
    #CMake looks for nvcc only in PATH and CUDACXX env vars for the Ninja generator. Since we filter path on vcpkg and CUDACXX env var is not set by CUDA installer on Windows, CMake cannot find CUDA when using Ninja generator, so we need to manually enlight it if necessary (https://gitlab.kitware.com/cmake/cmake/issues/19173). Otherwise we could just disable Ninja and use MSBuild, but unfortunately CUDA installer does not integrate with some distributions of MSBuild (like the ones inside Build Tools), making CUDA unavailable otherwise in those cases, which we want to avoid
    set(ENV{CUDACXX} "$ENV{CUDA_PATH}/bin/nvcc.exe")
  endif()
endif()

#make sure we don't use any integrated pre-built library nor any unnecessary CMake module
file(REMOVE_RECURSE "${SOURCE_PATH}/3rdparty")
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake/Modules")

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  DISABLE_PARALLEL_CONFIGURE
  OPTIONS
    ${FEATURE_OPTIONS}
    -DINSTALL_BIN_DIR:STRING=bin
    -DINSTALL_LIB_DIR:STRING=lib
    -DENABLE_OPENCV:BOOL=${ENABLE_OPENCV}
    -DSKIP_INSTALL_RUNTIME_LIBS:BOOL=ON
)

vcpkg_cmake_install()
vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES darknet uselib kmeansiou)
if ("opencv-cuda" IN_LIST FEATURES)
  vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES uselib_track)
endif()

file(COPY "${SOURCE_PATH}/cfg" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(COPY "${SOURCE_PATH}/data" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/scripts/download_weights.ps1" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/scripts")
message(STATUS "To download weight files, please go to ${CURRENT_INSTALLED_DIR}/tools/${PORT}/scripts and run ./download_weights.ps1")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
