include(vcpkg_common_functions)

if (EXISTS "${CURRENT_INSTALLED_DIR}/share/opencv4")
  message(FATAL_ERROR "OpenCV 4 is installed, please uninstall and try again:\n    vcpkg remove opencv4")
endif()

if (EXISTS "${CURRENT_INSTALLED_DIR}/share/opencv3")
  message(FATAL_ERROR "OpenCV 3 is installed, please uninstall and try again:\n    vcpkg remove opencv3")
endif()

set(OPENCV_PORT_VERSION "2.4.13.7")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO opencv/opencv
    REF ${OPENCV_PORT_VERSION}
    SHA512 de7d24ac7ed78ac14673011cbecc477cae688b74222a972e553c95a557b5cb8e5913f97db525421d6a72af30998ca300112fa0b285daed65f65832eb2cf7241a
    HEAD_REF master
    PATCHES
      0002-install-options.patch
      0003-force-package-requirements.patch
      0004-add-ffmpeg-missing-defines.patch
      0005-fix-cuda.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
 "cuda"     WITH_CUDA
 "cuda"     WITH_CUBLAS
 "eigen"    WITH_EIGEN
 "ffmpeg"   WITH_FFMPEG
 "jasper"   WITH_JASPER
 "jpeg"     WITH_JPEG
 "openexr"  WITH_OPENEXR
 "opengl"   WITH_OPENGL
 "png"      WITH_PNG
 "qt"       WITH_QT
 "tiff"     WITH_TIFF
 "vtk"      WITH_VTK
 "world"    BUILD_opencv_world
)

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
        ###### OpenCV options
        -DBUILD_DOCS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_PERF_TESTS=OFF
        -DBUILD_PACKAGE=OFF
        -DBUILD_WITH_DEBUG_INFO=ON
        -DCMAKE_DEBUG_POSTFIX=d
        ###### CMake options
        -DCMAKE_DISABLE_FIND_PACKAGE_JNI=ON
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
        -DBUILD_opencv_world=${BUILD_opencv_world}
        # WITH
        ${FEATURE_OPTIONS}
        -DWITH_1394=OFF
        -DWITH_IPP=OFF
        -DWITH_LAPACK=OFF
        -DWITH_MSMF=${WITH_MSMF}
        -DWITH_OPENCLAMDBLAS=OFF
        -DWITH_OPENMP=OFF
        -DWITH_PROTOBUF=ON
        -DWITH_ZLIB=ON
)

vcpkg_install_cmake(DISABLE_PARALLEL)
vcpkg_fixup_cmake_targets(CONFIG_PATH "share/opencv" TARGET_PATH "share/opencv")
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(READ ${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVModules.cmake OPENCV_MODULES)
  string(REPLACE "set(CMAKE_IMPORT_FILE_VERSION 1)"
                 "set(CMAKE_IMPORT_FILE_VERSION 1)
find_package(TIFF REQUIRED)
find_package(Protobuf REQUIRED)
if(Protobuf_FOUND)
  if(TARGET protobuf::libprotobuf)
    add_library(libprotobuf INTERFACE IMPORTED)
    set_target_properties(libprotobuf PROPERTIES
      INTERFACE_LINK_LIBRARIES protobuf::libprotobuf
    )
  else()
    add_library(libprotobuf UNKNOWN IMPORTED)
    set_target_properties(libprotobuf PROPERTIES
      IMPORTED_LOCATION \"${Protobuf_LIBRARY}\"
      INTERFACE_INCLUDE_DIRECTORIES \"${Protobuf_INCLUDE_DIR}\"
      INTERFACE_SYSTEM_INCLUDE_DIRECTORIES \"${Protobuf_INCLUDE_DIR}\"
    )
  endif()
endif()
find_package(HDF5 QUIET)
find_package(Freetype QUIET)
find_package(Ogre QUIET)
find_package(gflags QUIET)
find_package(Ceres QUIET)
find_package(VTK QUIET)
find_package(GDCM QUIET)" OPENCV_MODULES "${OPENCV_MODULES}")

  file(WRITE ${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVModules.cmake "${OPENCV_MODULES}")

  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE ${CURRENT_PACKAGES_DIR}/LICENSE)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/LICENSE)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
