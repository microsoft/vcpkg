# in case of errors on Ubuntu, please try installing first
# sudo apt-get install libv4l-dev

include(vcpkg_common_functions)

if (EXISTS "${CURRENT_INSTALLED_DIR}/share/OpenCV")
    message(FATAL_ERROR "FATAL ERROR: opencv and opencv2 are incompatible.")
endif()

set(OPENCV_PORT_VERSION "2.4.13.6")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO opencv/opencv
    REF ${OPENCV_PORT_VERSION}
    SHA512 022b131ea90aa69c580a9ebe34f9db565a0312b36ec69684d21436534fd8fc8bd76f90d155c4a5adc11d484a6eda52825e04443d2ec6f232d15d7f82617931ca
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
      "${CMAKE_CURRENT_LIST_DIR}/0001-fix-path.patch"
      "${CMAKE_CURRENT_LIST_DIR}/0002-add-ffmpeg-missing-defines.patch"
      "${CMAKE_CURRENT_LIST_DIR}/0003-fix-cuda.patch"
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" BUILD_WITH_STATIC_CRT)

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

set(WITH_OPENGL OFF)
if("opengl" IN_LIST FEATURES)
  set(WITH_OPENGL ON)
endif()

set(WITH_JPEG OFF)
if("jpeg" IN_LIST FEATURES)
  set(WITH_JPEG ON)
endif()

set(WITH_JASPER OFF)
if("jasper" IN_LIST FEATURES)
  set(WITH_JASPER ON)
endif()

set(WITH_PNG OFF)
if("png" IN_LIST FEATURES)
  set(WITH_PNG ON)
endif()

set(WITH_EIGEN OFF)
if("eigen" IN_LIST FEATURES)
  set(WITH_EIGEN ON)
endif()

if(NOT VCPKG_CMAKE_SYSTEM_NAME MATCHES "Linux" AND NOT VCPKG_CMAKE_SYSTEM_NAME MATCHES "Darwin")
  set(WITH_MSMF ON)
  if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(WITH_MSMF OFF)
  endif()
else()
  set(WITH_MSMF OFF)
endif()

vcpkg_configure_cmake(
    PREFER_NINJA
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        # Do not build docs/examples/tests
        -DBUILD_DOCS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_PERF_TESTS=OFF
        -DBUILD_PACKAGE=OFF
        -DBUILD_WITH_STATIC_CRT=${BUILD_WITH_STATIC_CRT}
        -DBUILD_WITH_DEBUG_INFO=ON
        # Do not build integrated libraries, use external ones
        -DBUILD_ZLIB=OFF
        -DBUILD_TIFF=OFF
        -DBUILD_JASPER=OFF
        -DBUILD_JPEG=OFF
        -DBUILD_PNG=OFF
        -DBUILD_OPENEXR=OFF
        -DBUILD_TBB=OFF
        # Select which OpenCV modules should be built
        -DBUILD_opencv_apps=OFF
        -DBUILD_opencv_python=OFF
        # WITH
        -DWITH_CUBLAS=OFF
        -DWITH_CUDA=${WITH_CUDA}
        -DWITH_EIGEN=${WITH_EIGEN}
        -DWITH_FFMPEG=${WITH_FFMPEG}
        -DWITH_IPP=OFF
        -DWITH_JASPER=${WITH_JASPER}
        -DWITH_JPEG=${WITH_JPEG}
        -DWITH_LAPACK=OFF
        -DWITH_MSMF=${WITH_MSMF}
        -DWITH_OPENCLAMDBLAS=OFF
        -DWITH_OPENEXR=OFF
        -DWITH_OPENGL=${WITH_OPENGL}
        -DWITH_PNG=${WITH_PNG}
        -DWITH_PROTOBUF=${WITH_PROTOBUF}
        -DWITH_QT=${WITH_QT}
        -DWITH_TIFF=OFF
        -DWITH_VTK=${WITH_VTK}
        -DWITH_ZLIB=ON
)

vcpkg_install_cmake(DISABLE_PARALLEL)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/opencv2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/opencv2/LICENSE ${CURRENT_PACKAGES_DIR}/share/opencv2/copyright)
file(REMOVE ${CURRENT_PACKAGES_DIR}/LICENSE)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/LICENSE)

if(NOT VCPKG_CMAKE_SYSTEM_NAME MATCHES "Linux" AND NOT VCPKG_CMAKE_SYSTEM_NAME MATCHES "Darwin")
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

  file(REMOVE ${CURRENT_PACKAGES_DIR}/OpenCVConfig.cmake)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/OpenCVConfig-version.cmake)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/OpenCVModules.cmake)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/OpenCVConfig.cmake)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/OpenCVConfig-version.cmake)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/OpenCVConfig.cmake)

  file(RENAME ${CURRENT_PACKAGES_DIR}/lib/OpenCVConfig.cmake ${CURRENT_PACKAGES_DIR}/share/OpenCV/OpenCVConfig.cmake)
  file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/OpenCVModules.cmake ${CURRENT_PACKAGES_DIR}/share/OpenCV/OpenCVModules.cmake)
  file(RENAME ${CURRENT_PACKAGES_DIR}/lib/OpenCVModules-release.cmake ${CURRENT_PACKAGES_DIR}/share/OpenCV/OpenCVModules-release.cmake)
  file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/OpenCVModules-debug.cmake ${CURRENT_PACKAGES_DIR}/share/OpenCV/OpenCVModules-debug.cmake)

  file(READ ${CURRENT_PACKAGES_DIR}/share/OpenCV/OpenCVModules-debug.cmake OPENCV_MODULES)
  string(REPLACE "PREFIX}/lib" "PREFIX}/../debug/lib" OPENCV_MODULES "${OPENCV_MODULES}")
  file(WRITE ${CURRENT_PACKAGES_DIR}/share/OpenCV/OpenCVModules-debug.cmake "${OPENCV_MODULES}")

  file(READ ${CURRENT_PACKAGES_DIR}/share/OpenCV/OpenCVModules-release.cmake OPENCV_MODULES)
  string(REPLACE "PREFIX}/lib" "PREFIX}/../lib" OPENCV_MODULES "${OPENCV_MODULES}")
  file(WRITE ${CURRENT_PACKAGES_DIR}/share/OpenCV/OpenCVModules-release.cmake "${OPENCV_MODULES}")

  file(READ ${CURRENT_PACKAGES_DIR}/share/OpenCV/OpenCVConfig.cmake OPENCV_CONFIG)
  string(REPLACE "${OpenCV_CONFIG_PATH}/include" "${OpenCV_CONFIG_PATH}/../../include" OPENCV_CONFIG "${OPENCV_CONFIG}")
  file(WRITE ${CURRENT_PACKAGES_DIR}/share/OpenCV/OpenCVConfig.cmake "${OPENCV_CONFIG}")
else()
  file(REMOVE ${CURRENT_PACKAGES_DIR}/share/OpenCV/OpenCVConfig.cmake)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/share/OpenCV/OpenCVConfig-version.cmake)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/share/OpenCV/OpenCVModules.cmake)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/share/OpenCV/OpenCVConfig.cmake)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/share/OpenCV/OpenCVConfig-version.cmake)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/share/OpenCV/OpenCVConfig.cmake)

  file(RENAME ${CURRENT_PACKAGES_DIR}/debug/share/OpenCV/OpenCVModules.cmake ${CURRENT_PACKAGES_DIR}/share/OpenCV/OpenCVModules.cmake)
  file(RENAME ${CURRENT_PACKAGES_DIR}/debug/share/OpenCV/OpenCVModules-debug.cmake ${CURRENT_PACKAGES_DIR}/share/OpenCV/OpenCVModules-debug.cmake)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

if(NOT VCPKG_CMAKE_SYSTEM_NAME MATCHES "Linux" AND NOT VCPKG_CMAKE_SYSTEM_NAME MATCHES "Darwin")
  set(VCPKG_LIBRARY_LINKAGE "dynamic")
  set(VCPKG_POLICY_ALLOW_OBSOLETE_MSVCRT enabled)
endif()
