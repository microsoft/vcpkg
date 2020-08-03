if (EXISTS "${CURRENT_INSTALLED_DIR}/share/opencv2")
  message(FATAL_ERROR "OpenCV 2 is installed, please uninstall and try again:\n    vcpkg remove opencv2")
endif()

if (EXISTS "${CURRENT_INSTALLED_DIR}/share/opencv4")
  message(FATAL_ERROR "OpenCV 4 is installed, please uninstall and try again:\n    vcpkg remove opencv4")
endif()

set(OPENCV_VERSION "3.4.10")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO opencv/opencv
    REF ${OPENCV_VERSION}
    SHA512 7ccdc7fef26436b2f643cce2a13c9f9f77e56d3fd0340117419df3c1665ca12416277b626cce3c056fdc14899805bbe9ece391f11d28c6adea716d47ce8894bc
    HEAD_REF master
    PATCHES
      0001-disable-downloading.patch
      0002-install-options.patch
      0003-force-package-requirements.patch
      0009-fix-uwp.patch
)

file(REMOVE "${SOURCE_PATH}/cmake/FindCUDNN.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindCUDA.cmake")
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake/FindCUDA")
file(COPY ${CMAKE_CURRENT_LIST_DIR}/FindCUDA.cmake DESTINATION ${SOURCE_PATH}/cmake/)    # backported from CMake 3.18, remove when released

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" BUILD_WITH_STATIC_CRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
 "contrib"  WITH_CONTRIB
 "cuda"     WITH_CUDA
 "cuda"     WITH_CUBLAS
 "dnn"      BUILD_opencv_dnn
 "eigen"    WITH_EIGEN
 "ffmpeg"   WITH_FFMPEG
 "flann"    BUILD_opencv_flann
 "gdcm"     WITH_GDCM
 "halide"   WITH_HALIDE
 "jasper"   WITH_JASPER
 "jpeg"     WITH_JPEG
 "nonfree"  OPENCV_ENABLE_NONFREE
 "openexr"  WITH_OPENEXR
 "opengl"   WITH_OPENGL
 "png"      WITH_PNG
 "qt"       WITH_QT
 "sfm"      BUILD_opencv_sfm
 "tiff"     WITH_TIFF
 "webp"     WITH_WEBP
 "world"    BUILD_opencv_world
)

# Cannot use vcpkg_check_features() for "dnn", "ipp", ovis", "tbb", and "vtk".
# As the respective value of their variables can be unset conditionally.
set(BUILD_opencv_dnn OFF)
if("dnn" IN_LIST FEATURES)
  if(NOT VCPKG_TARGET_IS_ANDROID)
    set(BUILD_opencv_dnn ON)
  else()
    message(WARNING "The dnn module cannot be enabled on Android")
  endif()
endif()

set(WITH_IPP OFF)
if("ipp" IN_LIST FEATURES)
  set(WITH_IPP ON)
endif()

set(BUILD_opencv_ovis OFF)
if("ovis" IN_LIST FEATURES)
  set(BUILD_opencv_ovis ON)
endif()

set(WITH_TBB OFF)
if("tbb" IN_LIST FEATURES)
  set(WITH_TBB ON)
endif()

set(WITH_VTK OFF)
if("vtk" IN_LIST FEATURES)
  set(WITH_VTK ON)
endif()

if("dnn" IN_LIST FEATURES)
  vcpkg_download_distfile(TINYDNN_ARCHIVE
    URLS "https://github.com/tiny-dnn/tiny-dnn/archive/v1.0.0a3.tar.gz"
    FILENAME "opencv-cache/tiny_dnn/adb1c512e09ca2c7a6faef36f9c53e59-v1.0.0a3.tar.gz"
    SHA512 5f2c1a161771efa67e85b1fea395953b7744e29f61187ac5a6c54c912fb195b3aef9a5827135c3668bd0eeea5ae04a33cc433e1f6683e2b7955010a2632d168b
  )
endif()

# Build image quality module when building with 'contrib' feature and not UWP.
set(BUILD_opencv_quality OFF)
if("contrib" IN_LIST FEATURES)
  if (VCPKG_TARGET_IS_UWP)
    set(BUILD_opencv_quality OFF)
    message(WARNING "The image quality module (quality) does not build for UWP, the module has been disabled.")
    # The hdf module is silently disabled by OpenCVs buildsystem if HDF5 is not detected.
    message(WARNING "The hierarchical data format module (hdf) depends on HDF5 which doesn't support UWP, the module has been disabled.")
  else()
    set(BUILD_opencv_quality CMAKE_DEPENDS_IN_PROJECT_ONLY)
  endif()

  vcpkg_from_github(
      OUT_SOURCE_PATH CONTRIB_SOURCE_PATH
      REPO opencv/opencv_contrib
      REF ${OPENCV_VERSION}
      SHA512 70b4ecfaf9881390ad826a2aba24cced8514a680965ec7151df9926082fff53364bbe6be36458bb9ff466fda6f6f6ca2174eeac94c10a6bada989f07ed1c4da1
      HEAD_REF master
      PATCHES
        0004-add-missing-stdexcept-include.patch
  )
  set(BUILD_WITH_CONTRIB_FLAG "-DOPENCV_EXTRA_MODULES_PATH=${CONTRIB_SOURCE_PATH}/modules")

  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/8afa57abc8229d611c4937165d20e2a2d9fc5a12/face_landmark_model.dat"
    FILENAME "opencv-cache/data/7505c44ca4eb54b4ab1e4777cb96ac05-face_landmark_model.dat"
    SHA512 c16e60a6c4bb4de3ab39b876ae3c3f320ea56f69c93e9303bd2dff8760841dcd71be4161fff8bc71e8fe4fe8747fa8465d49d6bd8f5ebcdaea161f4bc2da7c93
  )

  function(download_opencv_3rdparty ID COMMIT HASH)
    if(NOT EXISTS "${DOWNLOADS}/opencv-cache/${ID}/${COMMIT}.stamp")
      vcpkg_download_distfile(OCV_DOWNLOAD
          URLS "https://github.com/opencv/opencv_3rdparty/archive/${COMMIT}.zip"
          FILENAME "opencv_3rdparty-${COMMIT}.zip"
          SHA512 ${HASH}
      )
      vcpkg_extract_source_archive(${OCV_DOWNLOAD})
      file(MAKE_DIRECTORY "${DOWNLOADS}/opencv-cache/${ID}")
      file(GLOB XFEATURES2D_I ${CURRENT_BUILDTREES_DIR}/src/opencv_3rdparty-${COMMIT}/*)
      foreach(FILE ${XFEATURES2D_I})
        file(COPY ${FILE} DESTINATION "${DOWNLOADS}/opencv-cache/${ID}")
        get_filename_component(XFEATURES2D_I_NAME "${FILE}" NAME)
        file(MD5 "${FILE}" FILE_HASH)
        file(RENAME "${DOWNLOADS}/opencv-cache/${ID}/${XFEATURES2D_I_NAME}" "${DOWNLOADS}/opencv-cache/${ID}/${FILE_HASH}-${XFEATURES2D_I_NAME}")
      endforeach()
      file(WRITE "${DOWNLOADS}/opencv-cache/${ID}/${COMMIT}.stamp")
    endif()
  endfunction()

  # Used for opencv's xfeature2d module
  download_opencv_3rdparty(
    xfeatures2d/boostdesc
    34e4206aef44d50e6bbcd0ab06354b52e7466d26
    2ccdc8fb59da55eabc73309a80a4d3b1e73e2341027cdcdd2d714e0f519e60f243f38f79b13ed3de32f595aa23e4f86418eed42e741f32a81b1e6e0879190601
  )

  # Used for opencv's xfeature2d module
  download_opencv_3rdparty(
    xfeatures2d/vgg
    fccf7cd6a4b12079f73bbfb21745f9babcd4eb1d
    7051f5d6ccb938d296b919dd6d5dcddc5afb527aed456639c9984276a8f64565c084d96a72499a7756f127f8d2b1ce9ab70e4cbb3f89c4e16f82296c2a15daed
  )
endif()

if(WITH_IPP)
  if(VCPKG_TARGET_IS_OSX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
      vcpkg_download_distfile(OCV_DOWNLOAD
        URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/a56b6ac6f030c312b2dce17430eef13aed9af274/ippicv/ippicv_2020_mac_intel64_20191018_general.tgz"
        FILENAME "opencv-cache/ippicv/1c3d675c2a2395d094d523024896e01b-ippicv_2020_mac_intel64_20191018_general.tgz"
        SHA512 454dfaaa245e3a3b2f1ffb1aa8e27e280b03685009d66e147482b14e5796fdf2d332cac0f9b0822caedd5760fda4ee0ce2961889597456bbc18202f10bf727cd
    )
    else()
      message(WARNING "This target architecture is not supported IPPICV")
      set(WITH_IPP OFF)
    endif()
  elseif(VCPKG_TARGET_IS_LINUX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
      vcpkg_download_distfile(OCV_DOWNLOAD
        URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/a56b6ac6f030c312b2dce17430eef13aed9af274/ippicv/ippicv_2020_lnx_intel64_20191018_general.tgz"
        FILENAME "opencv-cache/ippicv/7421de0095c7a39162ae13a6098782f9-ippicv_2020_lnx_intel64_20191018_general.tgz"
        SHA512 de6d80695cd6deef359376476edc4ff85fdddcf94972b936e0017f8a48aaa5d18f55c4253ae37deb83bff2f71410f68408063c88b5f3bf4df3c416aa93ceca87
      )
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
      vcpkg_download_distfile(OCV_DOWNLOAD
        URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/a56b6ac6f030c312b2dce17430eef13aed9af274/ippicv/ippicv_2020_lnx_ia32_20191018_general.tgz"
        FILENAME "opencv-cache/ippicv/ad189a940fb60eb71f291321322fe3e8-ippicv_2020_lnx_ia32_20191018_general.tgz"
        SHA512 5ca9dafc3a634e2a5f83f6a498611c990ef16d54358e9b44574b01694e9d64b118d46d6e2011506e40d37e5a9865f576f790e37ff96b7c8b503507633631a296
      )
    else()
      message(WARNING "This target architecture is not supported IPPICV")
      set(WITH_IPP OFF)
    endif()
  elseif(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
      vcpkg_download_distfile(OCV_DOWNLOAD
        URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/a56b6ac6f030c312b2dce17430eef13aed9af274/ippicv/ippicv_2020_win_intel64_20191018_general.zip"
        FILENAME "opencv-cache/ippicv/879741a7946b814455eee6c6ffde2984-ippicv_2020_win_intel64_20191018_general.zip"
        SHA512 50c4af4b7fe2161d652264230389dad2330e8c95b734d04fb7565bffdab855c06d43085e480da554c56b04f8538087d49503538d5943221ee2a772ee7be4c93c
      )
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
      vcpkg_download_distfile(OCV_DOWNLOAD
        URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/a56b6ac6f030c312b2dce17430eef13aed9af274/ippicv/ippicv_2020_win_ia32_20191018_general.zip"
        FILENAME "opencv-cache/ippicv/cd39bdf0c2e1cac9a61101dad7a2413e-ippicv_2020_win_ia32_20191018_general.zip"
        SHA512 058d00775d9f16955c7a557d554b8c2976ab9dbad4ba3fdb9823c0f768809edbd835e4397f01dc090a9bc80d81de834375e7006614d2a898f42e8004de0e04bf
      )
    else()
      message(WARNING "This target architecture is not supported IPPICV")
      set(WITH_IPP OFF)
    endif()
  else()
    message(WARNING "This target architecture is not supported IPPICV")
    set(WITH_IPP OFF)
  endif()
endif()

set(WITH_MSMF ON)
if(NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP)
  set(WITH_MSMF OFF)
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
  if (WITH_TBB)
    message(WARNING "TBB is currently unsupported in this build configuration, turning it off")
    set(WITH_TBB OFF)
  endif()

  if (WITH_VTK)
    message(WARNING "VTK is currently unsupported in this build configuration, turning it off")
    set(WITH_VTK OFF)
  endif()

  if (VCPKG_TARGET_IS_WINDOWS AND BUILD_opencv_ovis)
    message(WARNING "OVIS is currently unsupported in this build configuration, turning it off")
    set(BUILD_opencv_ovis OFF)
  endif()
endif()

if("ffmpeg" IN_LIST FEATURES)
  if(VCPKG_TARGET_IS_UWP)
    set(VCPKG_C_FLAGS "/sdl- ${VCPKG_C_FLAGS}")
    set(VCPKG_CXX_FLAGS "/sdl- ${VCPKG_CXX_FLAGS}")
  endif()
endif()

if("qt" IN_LIST FEATURES)
  list(APPEND ADDITIONAL_BUILD_FLAGS "-DCMAKE_AUTOMOC=ON")
endif()

set(BUILD_opencv_line_descriptor ON)
set(BUILD_opencv_saliency ON)
set(BUILD_opencv_bgsegm ON)
if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
  set(BUILD_opencv_line_descriptor OFF)
  set(BUILD_opencv_saliency OFF)
  set(BUILD_opencv_bgsegm OFF)
endif()

vcpkg_configure_cmake(
    PREFER_NINJA
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DOPENCV_CUDA_FORCE_BUILTIN_CMAKE_MODULE=ON  #to use custom module with fixes for CUDA 11 compat, waiting for CMake support
        ###### ocv_options
        -DOpenCV_INSTALL_BINARIES_PREFIX=
        -DOPENCV_BIN_INSTALL_PATH=bin
        -DOPENCV_INCLUDE_INSTALL_PATH=include
        -DOPENCV_LIB_INSTALL_PATH=lib
        -DOPENCV_3P_LIB_INSTALL_PATH=lib
        -DOPENCV_CONFIG_INSTALL_PATH=share/opencv
        -DINSTALL_TO_MANGLED_PATHS=OFF
        -DOPENCV_FFMPEG_USE_FIND_PACKAGE=FFMPEG
        -DCMAKE_DEBUG_POSTFIX=d
        -DOPENCV_DLLVERSION=
        -DOPENCV_DEBUG_POSTFIX=d
        -DOPENCV_GENERATE_SETUPVARS=OFF
        # Do not build docs/examples
        -DBUILD_DOCS=OFF
        -DBUILD_EXAMPLES=OFF
        ###### Disable build 3rd party libs
        -DBUILD_JASPER=OFF
        -DBUILD_JPEG=OFF
        -DBUILD_OPENEXR=OFF
        -DBUILD_PNG=OFF
        -DBUILD_TIFF=OFF
        -DBUILD_WEBP=OFF
        -DBUILD_ZLIB=OFF
        -DBUILD_TBB=OFF
        -DBUILD_IPP_IW=OFF
        -DBUILD_ITT=OFF
        ###### Disable build 3rd party components
        -DBUILD_PROTOBUF=OFF
        ###### OpenCV Build components
        -DBUILD_opencv_apps=OFF
        -DBUILD_opencv_bgsegm=${BUILD_opencv_bgsegm}
        -DBUILD_opencv_line_descriptor=${BUILD_opencv_line_descriptor}
        -DBUILD_opencv_saliency=${BUILD_opencv_saliency}
        -DBUILD_ANDROID_PROJECT=OFF
        -DBUILD_ANDROID_EXAMPLES=OFF
        -DBUILD_PACKAGE=OFF
        -DBUILD_PERF_TESTS=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_WITH_DEBUG_INFO=ON
        -DBUILD_WITH_STATIC_CRT=${BUILD_WITH_STATIC_CRT}
        -DBUILD_JAVA=OFF
        -DCURRENT_INSTALLED_DIR=${CURRENT_INSTALLED_DIR}
        ###### PROTOBUF
        -DPROTOBUF_UPDATE_FILES=ON
        -DUPDATE_PROTO_FILES=ON
        ###### PYLINT/FLAKE8
        -DENABLE_PYLINT=OFF
        -DENABLE_FLAKE8=OFF
        # CMAKE
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_JNI=ON
        # ENABLE
        -DENABLE_CXX11=ON
        ###### OPENCV vars
        "-DOPENCV_DOWNLOAD_PATH=${DOWNLOADS}/opencv-cache"
        ${BUILD_WITH_CONTRIB_FLAG}
        -DOPENCV_OTHER_INSTALL_PATH=share/opencv
        ###### customized properties
        ## Options from vcpkg_check_features()
        ${FEATURE_OPTIONS}
        -DCMAKE_DISABLE_FIND_PACKAGE_Halide=ON
        -DHALIDE_ROOT_DIR=${CURRENT_INSTALLED_DIR}
        -DWITH_GTK=OFF
        -DWITH_IPP=${WITH_IPP}
        -DWITH_MATLAB=OFF
        -DWITH_MSMF=${WITH_MSMF}
        -DWITH_OPENMP=OFF
        -DWITH_PROTOBUF=ON
        -DWITH_OPENCLAMDBLAS=OFF
        -DWITH_TBB=${WITH_TBB}
        -DWITH_VTK=${WITH_VTK}
        -DWITH_OPENJPEG=OFF
        ###### WITH PROPERTIES explicitly disabled, they have problems with libraries if already installed by user and that are "involuntarily" found during install
        -DWITH_LAPACK=OFF
        ###### BUILD_options (mainly modules which require additional libraries)
        -DBUILD_opencv_ovis=${BUILD_opencv_ovis}
        -DBUILD_opencv_dnn=${BUILD_opencv_dnn}
        ###### The following modules are disabled for UWP
        -DBUILD_opencv_quality=${BUILD_opencv_quality}
        ###### Additional build flags
        ${ADDITIONAL_BUILD_FLAGS}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "share/opencv" TARGET_PATH "share/opencv")
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(READ ${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVModules.cmake OPENCV_MODULES)
  string(REPLACE "set(CMAKE_IMPORT_FILE_VERSION 1)"
                 "set(CMAKE_IMPORT_FILE_VERSION 1)
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
find_package(CUDA QUIET)
find_package(Threads QUIET)
find_package(TIFF QUIET)
find_package(HDF5 QUIET)
find_package(Freetype QUIET)
find_package(Ogre QUIET)
find_package(gflags QUIET)
find_package(Ceres QUIET)
find_package(ade QUIET)
find_package(VTK QUIET)
find_package(OpenMP QUIET)
find_package(Tesseract QUIET)
find_package(OpenEXR QUIET)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt5 COMPONENTS OpenGL Concurrent Test QUIET)
find_package(GDCM QUIET)" OPENCV_MODULES "${OPENCV_MODULES}")

  if(BUILD_opencv_ovis)
    string(REPLACE "OgreGLSupportStatic"
                   "OgreGLSupport" OPENCV_MODULES "${OPENCV_MODULES}")
  endif()

  file(WRITE ${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVModules.cmake "${OPENCV_MODULES}")

  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE ${CURRENT_PACKAGES_DIR}/LICENSE)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/LICENSE)

if(VCPKG_TARGET_IS_ANDROID)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/README.android)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/README.android)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
