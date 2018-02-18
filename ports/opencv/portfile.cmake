include(vcpkg_common_functions)

set (OPENCV_PORT_VERSION "3.4.0")

set(BUILD_opencv_sfm OFF)
if("sfm" IN_LIST FEATURES)
  set(BUILD_opencv_sfm ON)
endif()

set(BUILD_opencv_contrib OFF)
if("contrib" IN_LIST FEATURES)
  set(BUILD_opencv_contrib ON)
endif()

set(WITH_CUDA OFF)
if("cuda" IN_LIST FEATURES)
  set(WITH_CUDA ON)
endif()

set(WITH_FFMPEG OFF)
if("ffmpeg" IN_LIST FEATURES)
  set(WITH_FFMPEG ON)
endif()

set(WITH_QT OFF)
if("qt" IN_LIST FEATURES)
  set(WITH_QT ON)
endif()

set(WITH_VTK OFF)
if("vtk" IN_LIST FEATURES)
  set(WITH_VTK ON)
endif()

set(WITH_GDCM OFF)
if("gdcm" IN_LIST FEATURES)
  set(WITH_GDCM ON)
endif()

set(WITH_MSMF ON)
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  set(WITH_MSMF OFF)
endif()


vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO opencv/opencv
    REF ${OPENCV_PORT_VERSION}
    SHA512 aa7e475f356ffdaeb2ae9f7e9380c92cae58fabde9cd3b23c388f9190b8fde31ee70d16648042d0c43c03b2ff1f15e4be950be7851133ea0aa82cf6e42ba4710
    HEAD_REF master
)


vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
    "${CMAKE_CURRENT_LIST_DIR}/cmake__OpenCVCompilerOptions.cmake.patch"
    "${CMAKE_CURRENT_LIST_DIR}/cmake__OpenCVFindLibsVideo.cmake.patch"
    "${CMAKE_CURRENT_LIST_DIR}/cmake__OpenCVGenConfig.cmake.patch"
    "${CMAKE_CURRENT_LIST_DIR}/cmake__OpenCVGenHeaders.cmake.patch"
    "${CMAKE_CURRENT_LIST_DIR}/cmake__OpenCVModule.cmake.patch"
    "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt.patch"
    "${CMAKE_CURRENT_LIST_DIR}/data__CMakeLists.txt.patch"
    "${CMAKE_CURRENT_LIST_DIR}/include__CMakeLists.txt.patch"
    "${CMAKE_CURRENT_LIST_DIR}/modules__core__src__utils__filesystem.cpp.patch"
    "${CMAKE_CURRENT_LIST_DIR}/modules__highgui__include__opencv2__highgui__highgui_winrt.hpp.patch"
    "${CMAKE_CURRENT_LIST_DIR}/modules__highgui__src__window_winrt_bridge.hpp.patch"
    "${CMAKE_CURRENT_LIST_DIR}/modules__videoio__src__cap_winrt__CaptureFrameGrabber.cpp.patch"
)

file(COPY ${CURRENT_PORT_DIR}/FindFFMPEG.cmake DESTINATION ${CURRENT_BUILDTREES_DIR}/src/opencv-${OPENCV_PORT_VERSION}/cmake/)

if(BUILD_opencv_contrib)
  vcpkg_from_github(
      OUT_SOURCE_PATH CONTRIB_SOURCE_PATH
      REPO opencv/opencv_contrib
      REF ${OPENCV_PORT_VERSION}
      SHA512 53f6127304f314d3be834f79520d4bc8a75e14cad8c9c14a66a7a6b37908ded114d24e3a2c664d4ec2275903db08ac826f29433e810c6400f3adc2714a3c5be7
      HEAD_REF master
  )
  set(BUILD_WITH_CONTRIB_FLAG "-DOPENCV_EXTRA_MODULES_PATH=${CONTRIB_SOURCE_PATH}/modules")
endif()

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" BUILD_WITH_STATIC_CRT)

set(BUILD_integrated_JPEG OFF)
set(BUILD_integrated_TIFF OFF)
set(BUILD_opencv_line_descriptor ON)
set(BUILD_opencv_saliency ON)
set(BUILD_opencv_bgsegm ON)
if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
  set(BUILD_opencv_line_descriptor OFF)
  set(BUILD_opencv_saliency OFF)
  set(BUILD_opencv_bgsegm OFF)
endif()
if(VCPKG_LIBRARY_LINKAGE MATCHES "static")
  set(BUILD_integrated_JPEG ON)
  set(BUILD_integrated_TIFF ON)
endif()


vcpkg_configure_cmake(
    PREFER_NINJA_NONPARALLEL_CONFIG
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        # Ungrouped Entries
        -DOpenCV_DISABLE_ARCH_PATH=ON
        -DPROTOBUF_UPDATE_FILES=ON
        -DUPDATE_PROTO_FILES=ON
        # BUILD
        -DBUILD_DOCS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_JPEG=${BUILD_integrated_JPEG}   #when building as a static lib, vcpkg's libjpeg-turbo is not correctly distinguished between release/debug
        -DBUILD_PACKAGE=OFF
        -DBUILD_PERF_TESTS=OFF
        -DBUILD_PNG=OFF
        -DBUILD_PROTOBUF=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_TIFF=${BUILD_integrated_TIFF}   #when building as a static lib, we have linking problems because vcpkg's tiff library depends on lzma, which is not imported as a dependency
        -DBUILD_WITH_DEBUG_INFO=ON
        -DBUILD_WITH_STATIC_CRT=${BUILD_WITH_STATIC_CRT}
        -DBUILD_ZLIB=OFF
        -DBUILD_opencv_apps=OFF
        -DBUILD_opencv_dnn=ON
        -DBUILD_opencv_flann=ON
        -DBUILD_opencv_python2=OFF
        -DBUILD_opencv_python3=OFF
        -DBUILD_opencv_sfm=${BUILD_opencv_sfm}
        -DBUILD_opencv_line_descriptor=${BUILD_opencv_line_descriptor}
        -DBUILD_opencv_saliency=${BUILD_opencv_saliency}
        -DBUILD_opencv_bgsegm=${BUILD_opencv_bgsegm}
        # CMAKE
        -DCMAKE_DISABLE_FIND_PACKAGE_JNI=ON
        # ENABLE
        -DENABLE_CXX11=ON
        -DENABLE_PYLINT=OFF
        # INSTALL
        -DINSTALL_FORCE_UNIX_PATHS=ON
        -DINSTALL_LICENSE=OFF
        # OPENCV
        -DOPENCV_CONFIG_INSTALL_PATH=share/opencv
        "-DOPENCV_DOWNLOAD_PATH=${DOWNLOADS}/opencv-cache"
        ${BUILD_WITH_CONTRIB_FLAG}
        -DOPENCV_OTHER_INSTALL_PATH=share/opencv
        # WITH
        -DWITH_CUBLAS=OFF
        -DWITH_CUDA=${WITH_CUDA}
        -DWITH_FFMPEG=${WITH_FFMPEG}
        -DWITH_LAPACK=OFF
        -DWITH_MSMF=${WITH_MSMF}
        -DWITH_OPENCLAMDBLAS=OFF
        -DWITH_OPENGL=ON
        -DWITH_QT=${WITH_QT}
        -DWITH_VTK=${WITH_VTK}
        -DWITH_GDCM=${WITH_GDCM}
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
        -DINSTALL_OTHER=OFF
)

vcpkg_install_cmake()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/opencv)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/opencv/LICENSE ${CURRENT_PACKAGES_DIR}/share/opencv/copyright)
file(REMOVE ${CURRENT_PACKAGES_DIR}/LICENSE)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/LICENSE)

if(VCPKG_PLATFORM_TOOLSET STREQUAL "v141")
  set(OpenCV_RUNTIME vc15)
else()
  set(OpenCV_RUNTIME vc14)
endif()
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  set(OpenCV_ARCH x64)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
  set(OpenCV_ARCH ARM)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
  set(OpenCV_ARCH ARM64)
else()
  set(OpenCV_ARCH x86)
endif()

file(GLOB BIN_AND_LIB ${CURRENT_PACKAGES_DIR}/${OpenCV_ARCH}/${OpenCV_RUNTIME}/*)
file(COPY ${BIN_AND_LIB} DESTINATION ${CURRENT_PACKAGES_DIR})
file(GLOB DEBUG_BIN_AND_LIB ${CURRENT_PACKAGES_DIR}/debug/${OpenCV_ARCH}/${OpenCV_RUNTIME}/*)
file(COPY ${DEBUG_BIN_AND_LIB} DESTINATION ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/${OpenCV_ARCH})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/${OpenCV_ARCH})

file(GLOB STATICLIB ${CURRENT_PACKAGES_DIR}/staticlib/*)
if(STATICLIB)
  file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib)
  file(COPY ${STATICLIB} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/staticlib)
endif()
file(GLOB STATICLIB ${CURRENT_PACKAGES_DIR}/debug/staticlib/*)
if(STATICLIB)
  file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib)
  file(COPY ${STATICLIB} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/staticlib)
endif()

file(READ ${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVConfig.cmake OPENCV_CONFIG)
string(REPLACE "/staticlib/"
               "/lib/" OPENCV_CONFIG "${OPENCV_CONFIG}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVConfig.cmake "${OPENCV_CONFIG}")

file(READ ${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVModules-release.cmake OPENCV_CONFIG_LIB)
string(REPLACE "/staticlib/"
               "/lib/" OPENCV_CONFIG_LIB "${OPENCV_CONFIG_LIB}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVModules-release.cmake "${OPENCV_CONFIG_LIB}")

file(READ ${CURRENT_PACKAGES_DIR}/debug/share/opencv/OpenCVModules-debug.cmake OPENCV_CONFIG_LIB)
string(REPLACE "/staticlib/"
               "/lib/" OPENCV_CONFIG_LIB "${OPENCV_CONFIG_LIB}")
string(REPLACE "PREFIX}/lib"
               "PREFIX}/debug/lib" OPENCV_CONFIG_LIB "${OPENCV_CONFIG_LIB}")
string(REPLACE "PREFIX}/bin"
               "PREFIX}/debug/bin" OPENCV_CONFIG_LIB "${OPENCV_CONFIG_LIB}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVModules-debug.cmake "${OPENCV_CONFIG_LIB}")

file(RENAME ${CURRENT_PACKAGES_DIR}/debug/share/opencv/OpenCVModules.cmake ${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVModules.cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/opencv)

vcpkg_copy_pdbs()
