if (EXISTS "${CURRENT_INSTALLED_DIR}/share/opencv3")
  message(FATAL_ERROR "OpenCV 3 is installed, please uninstall and try again:\n    vcpkg remove opencv3")
endif()

if (EXISTS "${CURRENT_INSTALLED_DIR}/share/opencv4")
  message(FATAL_ERROR "OpenCV 4 is installed, please uninstall and try again:\n    vcpkg remove opencv4")
endif()

if (VCPKG_TARGET_IS_UWP)
  # - opengl feature is broken on UWP
  # - jasper and openexr are not available on UWP due to missing dependencies
  # - opencv2 code itself fails even if previous conditions are avoided
  message(FATAL_ERROR "${PORT} doesn't support UWP")
endif()

set(OPENCV_VERSION "2.4.13.7")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO opencv/opencv
    REF ${OPENCV_VERSION}
    SHA512 de7d24ac7ed78ac14673011cbecc477cae688b74222a972e553c95a557b5cb8e5913f97db525421d6a72af30998ca300112fa0b285daed65f65832eb2cf7241a
    HEAD_REF master
    PATCHES
      0002-install-options.patch
      0003-force-package-requirements.patch
      0004-add-ffmpeg-missing-defines.patch
      0005-fix-cuda.patch
)

file(REMOVE "${SOURCE_PATH}/cmake/FindCUDA.cmake")
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake/FindCUDA")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
 "cuda"     WITH_CUDA
 "eigen"    WITH_EIGEN
 "ffmpeg"   WITH_FFMPEG
 "jasper"   WITH_JASPER
 "jpeg"     WITH_JPEG
 "openexr"  WITH_OPENEXR
 "opengl"   WITH_OPENGL
 "png"      WITH_PNG
 "qt"       WITH_QT
 "tiff"     WITH_TIFF
 "world"    BUILD_opencv_world
)

set(WITH_MSMF ON)
if(NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP)
  set(WITH_MSMF OFF)
endif()

if("ffmpeg" IN_LIST FEATURES)
  if(VCPKG_TARGET_IS_UWP)
    set(VCPKG_C_FLAGS "/sdl- ${VCPKG_C_FLAGS}")
    set(VCPKG_CXX_FLAGS "/sdl- ${VCPKG_CXX_FLAGS}")
  endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ###### ocv_options
        -DCMAKE_DEBUG_POSTFIX=d
        # Do not build docs/examples
        -DBUILD_DOCS=OFF
        -DBUILD_EXAMPLES=OFF
        ###### Disable build 3rd party libs
        -DBUILD_JASPER=OFF
        -DBUILD_JPEG=OFF
        -DBUILD_OPENEXR=OFF
        -DBUILD_PNG=OFF
        -DBUILD_TIFF=OFF
        -DBUILD_TBB=OFF
        -DBUILD_ZLIB=OFF
        ###### OpenCV Build components
        -DBUILD_opencv_apps=OFF
        -DBUILD_PACKAGE=OFF
        -DBUILD_PERF_TESTS=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_WITH_DEBUG_INFO=ON
        # CMAKE
        -DCMAKE_DISABLE_FIND_PACKAGE_JNI=ON
        ###### customized properties
        ## Options from vcpkg_check_features()
        ${FEATURE_OPTIONS}
        -DWITH_1394=OFF
        -DWITH_IPP=OFF
        -DWITH_LAPACK=OFF
        -DWITH_MSMF=${WITH_MSMF}
        -DWITH_OPENCLAMDBLAS=OFF
        -DWITH_OPENMP=OFF
        -DWITH_ZLIB=ON
        -DWITH_CUBLAS=OFF   # newer libcublas cannot be found by the old cuda cmake script in opencv2, requires a fix
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME opencv CONFIG_PATH "share/opencv")
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(READ "${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVModules.cmake" OPENCV_MODULES)
  string(REPLACE "set(CMAKE_IMPORT_FILE_VERSION 1)"
                 "set(CMAKE_IMPORT_FILE_VERSION 1)
find_package(CUDA QUIET)
find_package(Threads QUIET)
find_package(PNG QUIET)
find_package(OpenEXR QUIET)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
find_package(Qt5 COMPONENTS OpenGL Concurrent Test QUIET)
find_package(TIFF QUIET)" OPENCV_MODULES "${OPENCV_MODULES}")

  file(WRITE "${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVModules.cmake" "${OPENCV_MODULES}")

  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/LICENSE")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
