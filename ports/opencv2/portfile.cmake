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
      fix-path-contains-++-error.patch
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

set(WITH_GTK OFF)
if("gtk" IN_LIST FEATURES)
  if(VCPKG_TARGET_IS_LINUX)
    set(WITH_GTK ON)
  else()
    message(WARNING "The gtk module cannot be enabled outside Linux")
  endif()
endif()

if("ffmpeg" IN_LIST FEATURES)
  if(VCPKG_TARGET_IS_UWP)
    set(VCPKG_C_FLAGS "/sdl- ${VCPKG_C_FLAGS}")
    set(VCPKG_CXX_FLAGS "/sdl- ${VCPKG_CXX_FLAGS}")
  endif()
endif()

set(WITH_PYTHON OFF)
if("python" IN_LIST FEATURES)
  set(WITH_PYTHON ON)
  vcpkg_find_acquire_program(PYTHON2)
  get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY)
  vcpkg_add_to_path("${PYTHON2_DIR}")
  vcpkg_add_to_path("${PYTHON2_DIR}/Scripts")
  set(ENV{PYTHON} "${PYTHON2}")

  function(vcpkg_get_python_package PYTHON_DIR )
      cmake_parse_arguments(PARSE_ARGV 0 _vgpp "" "PYTHON_EXECUTABLE" "PACKAGES")

      if(NOT _vgpp_PYTHON_EXECUTABLE)
          message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} requires parameter PYTHON_EXECUTABLE!")
      endif()
      if(NOT _vgpp_PACKAGES)
          message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} requires parameter PACKAGES!")
      endif()
      if(NOT _vgpp_PYTHON_DIR)
          get_filename_component(_vgpp_PYTHON_DIR "${_vgpp_PYTHON_EXECUTABLE}" DIRECTORY)
      endif()

      if (WIN32)
          set(PYTHON_OPTION "")
      else()
          set(PYTHON_OPTION "--user")
      endif()

      if(NOT EXISTS "${_vgpp_PYTHON_DIR}/easy_install${VCPKG_HOST_EXECUTABLE_SUFFIX}")
          if(NOT EXISTS "${_vgpp_PYTHON_DIR}/Scripts/pip${VCPKG_HOST_EXECUTABLE_SUFFIX}")
              vcpkg_from_github(
                  OUT_SOURCE_PATH PYFILE_PATH
                  REPO pypa/get-pip
                  REF 309a56c5fd94bd1134053a541cb4657a4e47e09d #2019-08-25
                  SHA512 bb4b0745998a3205cd0f0963c04fb45f4614ba3b6fcbe97efe8f8614192f244b7ae62705483a5305943d6c8fedeca53b2e9905aed918d2c6106f8a9680184c7a
                  HEAD_REF master
              )
              execute_process(COMMAND "${_vgpp_PYTHON_EXECUTABLE}" "${PYFILE_PATH}/get-pip.py" ${PYTHON_OPTION})
          endif()
          foreach(_package IN LISTS _vgpp_PACKAGES)
              execute_process(COMMAND "${_vgpp_PYTHON_DIR}/Scripts/pip${VCPKG_HOST_EXECUTABLE_SUFFIX}" install ${_package} ${PYTHON_OPTION})
          endforeach()
      else()
          foreach(_package IN LISTS _vgpp_PACKAGES)
              execute_process(COMMAND "${_vgpp_PYTHON_DIR}/easy_install${VCPKG_HOST_EXECUTABLE_SUFFIX}" ${_package})
          endforeach()
      endif()
  endfunction()
  vcpkg_get_python_package(PYTHON_EXECUTABLE "${PYTHON2}" PACKAGES numpy)
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
        -DWITH_PYTHON=${WITH_PYTHON}
        -DWITH_ZLIB=ON
        -WITH_GTK=${WITH_GTK}
        -DWITH_CUBLAS=OFF   # newer libcublas cannot be found by the old cuda cmake script in opencv2, requires a fix
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME opencv CONFIG_PATH "share/opencv")
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(READ "${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVModules.cmake" OPENCV_MODULES)

  set(DEPS_STRING "include(CMakeFindDependencyMacro)
find_dependency(Threads)")
  if("tiff" IN_LIST FEATURES)
    string(APPEND DEPS_STRING "\nfind_dependency(TIFF)")
  endif()
  if("cuda" IN_LIST FEATURES)
    string(APPEND DEPS_STRING "\nfind_dependency(CUDA)")
  endif()
  if("openexr" IN_LIST FEATURES)
    string(APPEND DEPS_STRING "\nfind_dependency(OpenEXR CONFIG)")
  endif()
  if("png" IN_LIST FEATURES)
    string(APPEND DEPS_STRING "\nfind_dependency(PNG)")
  endif()
  if("qt" IN_LIST FEATURES)
    string(APPEND DEPS_STRING "
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
find_dependency(Qt5 COMPONENTS Core Gui Widgets Test Concurrent)")
    if("opengl" IN_LIST FEATURES)
      string(APPEND DEPS_STRING "
find_dependency(Qt5 COMPONENTS OpenGL)")
    endif()
  endif()

  string(REPLACE "set(CMAKE_IMPORT_FILE_VERSION 1)"
                 "set(CMAKE_IMPORT_FILE_VERSION 1)\n${DEPS_STRING}" OPENCV_MODULES "${OPENCV_MODULES}")

  file(WRITE "${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVModules.cmake" "${OPENCV_MODULES}")

  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/LICENSE")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
