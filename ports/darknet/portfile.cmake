include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO AlexeyAB/darknet
  REF 81290b07376c5abb4988a492dda70913bb90133d
  SHA512 094197cde851dfdd1e102a3ffaed34d67a789dd75dc288bde611144dc9aa484ca0b9e3468abc297d075d3753553f7f09a214be279af9e58ccb642aa757909f79
  HEAD_REF master
)

# enable CUDA inside DARKNET
set(ENABLE_CUDA OFF)
if("cuda" IN_LIST FEATURES)
  set(ENABLE_CUDA ON)
endif()

set(ENABLE_OPENCV OFF)
# enable OPENCV (basic version) inside DARKNET
if("opencv-base" IN_LIST FEATURES)
  set(ENABLE_OPENCV ON)
endif()
if("opencv3-base" IN_LIST FEATURES)
  set(ENABLE_OPENCV ON)
endif()

# enable OPENCV (with its own CUDA feature enabled) inside DARKNET
# (note: this does not mean that DARKNET itself will have CUDA support since by design it is independent, to have it you must require both opencv-cuda and cuda features!)
# DARKNET will be automatically able to distinguish an OpenCV that is built with or without CUDA support.
if("opencv-cuda" IN_LIST FEATURES)
  set(ENABLE_OPENCV ON)
endif()
if("opencv3-cuda" IN_LIST FEATURES)
  set(ENABLE_OPENCV ON)
endif()

# enable CUDNN inside DARKNET (which depends on the "cuda" feature by design)
set(ENABLE_CUDNN OFF)
if("cudnn" IN_LIST FEATURES)
  set(ENABLE_CUDNN ON)
endif()

if ("cuda" IN_LIST FEATURES)
  if (NOT VCPKG_CMAKE_SYSTEM_NAME AND NOT ENV{CUDACXX})
    #CMake looks for nvcc only in PATH and CUDACXX env vars for the Ninja generator. Since we filter path on vcpkg and CUDACXX env var is not set by CUDA installer on Windows, CMake cannot find CUDA when using Ninja generator, so we need to manually enlight it if necessary (https://gitlab.kitware.com/cmake/cmake/issues/19173). Otherwise we could just disable Ninja and use MSBuild, but unfortunately CUDA installer does not integrate with some distributions of MSBuild (like the ones inside Build Tools), making CUDA unavailable otherwise in those cases, which we want to avoid
    set(ENV{CUDACXX} "$ENV{CUDA_PATH}/bin/nvcc.exe")
  endif()
endif()

if("weights" IN_LIST FEATURES)
  vcpkg_download_distfile(YOLOV3_WEIGHTS
    URLS "https://pjreddie.com/media/files/yolov3.weights"
    FILENAME "darknet-cache/yolov3.weights"
    SHA512 293c70e404ff0250d7c04ca1e5e053fc21a78547e69b5b329d34f25981613e59b982d93fff2c352915ef7531d6c3b02a9b0b38346d05c51d6636878d8883f2c1
  )
  vcpkg_download_distfile(YOLOV2_WEIGHTS
    URLS "https://pjreddie.com/media/files/yolov2.weights"
    FILENAME "darknet-cache/yolov2.weights"
    SHA512 5271da2dd2da915172ddd034c8e894877e7066051f105ae82e25e185a2b4e4157d2b9514653c23780e87346f2b20df6363018b7e688aba422e2dacf1d2fbf6ab
  )
  vcpkg_download_distfile(YOLOV3-TINY_WEIGHTS
    URLS "https://pjreddie.com/media/files/yolov3-tiny.weights"
    FILENAME "darknet-cache/yolov3-tiny.weights"
    SHA512 981a56459515f727bb7b3d3341b95f4117499b6726eab2798e1c3e524de1ee8ed0d954c11b27bbbb926da2cc955526a194eddf69c55d65923994ab2e8af07042
  )
  vcpkg_download_distfile(YOLOV2-TINY_WEIGHTS
    URLS "https://pjreddie.com/media/files/yolov2-tiny.weights"
    FILENAME "darknet-cache/yolov2-tiny.weights"
    SHA512 f0857a7a02cf4322354d288c9afa0b87321b23082b719bc84ea64e2f3556cc1fafeb836ee5bf9fb6dcf448839061b93623a067dfde7afa1338636865ea88989a
  )
endif()

if("weights-train" IN_LIST FEATURES)
  vcpkg_download_distfile(IMAGENET_CONV_WEIGHTS_V3
    URLS "https://pjreddie.com/media/files/darknet53.conv.74"
    FILENAME "darknet-cache/darknet53.conv.74"
    SHA512 8983e1c129e2d6e8e3da0cc0781ecb7a07813830ef5a87c24b53100df6a5f23db6c6e6a402aec78025a93fe060b75d1958f1b8f7439a04b54a3f19c81e2ae99b
  )
  vcpkg_download_distfile(IMAGENET_CONV_WEIGHTS_V2
    URLS "https://pjreddie.com/media/files/darknet19_448.conv.23"
    FILENAME "darknet-cache/darknet19_448.conv.23"
    SHA512 8016f5b7ddc15c5d7dad231592f5351eea65f608ebdb204f545034dde904e11962f693080dfeb5a4510e7b71bdda151a9121ba0f8a243018d680f01b1efdbd31
  )
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
  OPTIONS
    -DINSTALL_BIN_DIR:STRING=bin
    -DINSTALL_LIB_DIR:STRING=lib
    -DENABLE_CUDA=${ENABLE_CUDA}
    -DENABLE_CUDNN=${ENABLE_CUDNN}
    -DENABLE_OPENCV=${ENABLE_OPENCV}
)

vcpkg_install_cmake()

file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/darknet${VCPKG_TARGET_EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/uselib${VCPKG_TARGET_EXECUTABLE_SUFFIX})
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/bin/uselib_track${VCPKG_TARGET_EXECUTABLE_SUFFIX})
  file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/uselib_track${VCPKG_TARGET_EXECUTABLE_SUFFIX})
endif()
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/darknet${VCPKG_TARGET_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/${PORT}/darknet${VCPKG_TARGET_EXECUTABLE_SUFFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/uselib${VCPKG_TARGET_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/${PORT}/uselib${VCPKG_TARGET_EXECUTABLE_SUFFIX})
if(EXISTS ${CURRENT_PACKAGES_DIR}/bin/uselib_track${VCPKG_TARGET_EXECUTABLE_SUFFIX})
  file(RENAME ${CURRENT_PACKAGES_DIR}/bin/uselib_track${VCPKG_TARGET_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/${PORT}/uselib_track${VCPKG_TARGET_EXECUTABLE_SUFFIX})
endif()
file(COPY ${SOURCE_PATH}/cfg DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(COPY ${SOURCE_PATH}/data DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

if("weights" IN_LIST FEATURES)
  file(COPY ${VCPKG_ROOT_DIR}/downloads/darknet-cache/yolov3.weights DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
  file(COPY ${VCPKG_ROOT_DIR}/downloads/darknet-cache/yolov2.weights DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
  file(COPY ${VCPKG_ROOT_DIR}/downloads/darknet-cache/yolov3-tiny.weights DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
  file(COPY ${VCPKG_ROOT_DIR}/downloads/darknet-cache/yolov2-tiny.weights DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
endif()

if("weights-train" IN_LIST FEATURES)
  file(COPY ${VCPKG_ROOT_DIR}/downloads/darknet-cache/darknet53.conv.74 DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
  file(COPY ${VCPKG_ROOT_DIR}/downloads/darknet-cache/darknet19_448.conv.23 DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
endif()
