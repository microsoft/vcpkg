file(READ "${CMAKE_CURRENT_LIST_DIR}/vcpkg.json" _contents)
string(JSON OPENCV_VERSION GET "${_contents}" version)

set(USE_QT_VERSION "5")
set(ENABLE_CXX11 ON)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO opencv/opencv
    REF ${OPENCV_VERSION}
    SHA512 96bbeb9525325f17ba635a0b75126aae0a7b0daef211af45057a97abd5d31a57fc50f0e889a6dab614df9b7621a145e06c0d240f0a218f33df1217d9a19c510d
    HEAD_REF master
    PATCHES
      0001-disable-downloading.patch
      0002-install-options.patch
      0003-force-package-requirements.patch
      0004-fix-eigen.patch
      0005-fix-vtk9.patch
      0006-fix-uwp.patch
      0008-devendor-quirc.patch
      0009-fix-protobuf.patch
      0010-fix-uwp-tiff-imgcodecs.patch
      0011-remove-python2.patch
      0012-fix-zlib.patch
      0019-missing-include.patch
      fix-tbb-error.patch
      0020-fix-supportqnx.patch
)
# Disallow accidental build of vendored copies
file(REMOVE_RECURSE "${SOURCE_PATH}/3rdparty/openexr")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
  set(TARGET_IS_AARCH64 1)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
  set(TARGET_IS_ARM 1)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  set(TARGET_IS_X86_64 1)
else()
  set(TARGET_IS_X86 1)
endif()

file(REMOVE "${SOURCE_PATH}/cmake/FindCUDNN.cmake")

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" BUILD_WITH_STATIC_CRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
 FEATURES
 "contrib"   WITH_CONTRIB
 "cuda"      WITH_CUBLAS
 "cuda"      WITH_CUDA
 "dnn"       BUILD_opencv_dnn
 "eigen"     WITH_EIGEN
 "ffmpeg"    WITH_FFMPEG
 "flann"     BUILD_opencv_flann
 "freetype"  WITH_FREETYPE
 "gdcm"      WITH_GDCM
 "gstreamer" WITH_GSTREAMER
 "halide"    WITH_HALIDE
 "jasper"    WITH_JASPER
 "jpeg"      WITH_JPEG
 "lapack"    WITH_LAPACK
 "nonfree"   OPENCV_ENABLE_NONFREE
 "openexr"   WITH_OPENEXR
 "opengl"    WITH_OPENGL
 "png"       WITH_PNG
 "quirc"     WITH_QUIRC
 "sfm"       BUILD_opencv_sfm
 "tiff"      WITH_TIFF
 "vtk"       WITH_VTK
 "webp"      WITH_WEBP
 "world"     BUILD_opencv_world
 "dc1394"    WITH_1394
)

# Cannot use vcpkg_check_features() for "dnn", "gtk", ipp", "openmp", "ovis", "python", "qt", "tbb"
set(BUILD_opencv_dnn OFF)
if("dnn" IN_LIST FEATURES)
  if(NOT VCPKG_TARGET_IS_ANDROID)
    set(BUILD_opencv_dnn ON)
  else()
    message(WARNING "The dnn module cannot be enabled on Android")
  endif()
endif()

set(WITH_GTK OFF)
if("gtk" IN_LIST FEATURES)
  if(VCPKG_TARGET_IS_LINUX)
    set(WITH_GTK ON)
  else()
    message(WARNING "The gtk module cannot be enabled outside Linux")
  endif()
endif()

set(WITH_QT OFF)
if("qt" IN_LIST FEATURES)
  set(WITH_QT ${USE_QT_VERSION})
endif()

set(WITH_IPP OFF)
if("ipp" IN_LIST FEATURES)
  set(WITH_IPP ON)
endif()

set(WITH_OPENMP OFF)
if("openmp" IN_LIST FEATURES)
  if(NOT VCPKG_TARGET_IS_OSX)
    set(WITH_OPENMP ON)
  else()
    message(WARNING "The OpenMP feature is not supported on macOS")
  endif()
endif()

set(BUILD_opencv_ovis OFF)
if("ovis" IN_LIST FEATURES)
  set(BUILD_opencv_ovis ON)
endif()

set(WITH_TBB OFF)
if("tbb" IN_LIST FEATURES)
  set(WITH_TBB ON)
endif()

set(WITH_PYTHON OFF)
set(BUILD_opencv_python3 OFF)
if("python" IN_LIST FEATURES)
  if (VCPKG_LIBRARY_LINKAGE STREQUAL static AND VCPKG_TARGET_IS_WINDOWS)
    message(WARNING "The python module is currently unsupported on Windows when building static OpenCV libraries")
  else()
    x_vcpkg_get_python_packages(PYTHON_VERSION "3" PACKAGES numpy OUT_PYTHON_VAR "PYTHON3")
    set(ENV{PYTHON} "${PYTHON3}")
    set(BUILD_opencv_python3 ON)
    set(WITH_PYTHON ON)
  endif()
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
      SHA512 a051497e61ae55f86c224044487fc2247a3bba1aa27031c4997c981ddf8402edf82f1dd0d307f562c638bc021cfd8bd42a723973f00ab25131495f84d33c5383
    HEAD_REF master
    PATCHES
      0007-fix-hdf5.patch
      0013-fix-ceres.patch
      0016-fix-freetype-contrib.patch
      0018-fix-depend-tesseract.patch
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
      vcpkg_extract_source_archive(extracted_ocv ARCHIVE "${OCV_DOWNLOAD}")
      file(MAKE_DIRECTORY "${DOWNLOADS}/opencv-cache/${ID}")
      file(GLOB XFEATURES2D_I "${extracted_ocv}/*")
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
if(NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP OR VCPKG_TARGET_IS_MINGW)
  set(WITH_MSMF OFF)
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
  if (WITH_TBB)
    message(WARNING "TBB is currently unsupported in this build configuration, turning it off")
    set(WITH_TBB OFF)
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

if("halide" IN_LIST FEATURES)
  set(ENABLE_CXX11 OFF)
  list(APPEND ADDITIONAL_BUILD_FLAGS
    # Halide 13 requires C++17
    "-DCMAKE_CXX_STANDARD=17"
    "-DCMAKE_CXX_STANDARD_REQUIRED=ON"
    "-DCMAKE_DISABLE_FIND_PACKAGE_Halide=ON"
    "-DHALIDE_ROOT_DIR=${CURRENT_INSTALLED_DIR}"
  )
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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ###### opencv cpu recognition is broken, always using host and not target: here we bypass that
        -DOPENCV_SKIP_SYSTEM_PROCESSOR_DETECTION=TRUE
        -DAARCH64=${TARGET_IS_AARCH64}
        -DX86_64=${TARGET_IS_X86_64}
        -DX86=${TARGET_IS_X86}
        -DARM=${TARGET_IS_ARM}
        ###### ocv_options
        -DINSTALL_TO_MANGLED_PATHS=OFF
        -DOpenCV_INSTALL_BINARIES_PREFIX=
        -DOPENCV_BIN_INSTALL_PATH=bin
        -DOPENCV_INCLUDE_INSTALL_PATH=include/opencv3
        -DOPENCV_LIB_INSTALL_PATH=lib
        -DOPENCV_3P_LIB_INSTALL_PATH=lib/manual-link/opencv3_thirdparty
        -DOPENCV_CONFIG_INSTALL_PATH=share/opencv3
        -DOPENCV_FFMPEG_USE_FIND_PACKAGE=FFMPEG
        -DOPENCV_FFMPEG_SKIP_BUILD_CHECK=TRUE
        -DCMAKE_DEBUG_POSTFIX=d
        -DOPENCV_DLLVERSION=3
        -DOPENCV_DEBUG_POSTFIX=d
        -DOPENCV_GENERATE_SETUPVARS=OFF
        -DOPENCV_GENERATE_PKGCONFIG=ON
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
        -DBUILD_ITT=OFF
        ###### Disable build 3rd party components
        -DBUILD_PROTOBUF=OFF
        ###### OpenCV Build components
        -DBUILD_opencv_apps=OFF
        -DBUILD_opencv_java=OFF
        -DBUILD_opencv_js=OFF
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
        -DPROTOBUF_UPDATE_FILES=${BUILD_opencv_flann}
        -DUPDATE_PROTO_FILES=${BUILD_opencv_flann}
        ###### PYLINT/FLAKE8
        -DENABLE_PYLINT=OFF
        -DENABLE_FLAKE8=OFF
        # CMAKE
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_JNI=ON
        # ENABLE
        -DENABLE_CXX11=${ENABLE_CXX11}
        ###### OPENCV vars
        "-DOPENCV_DOWNLOAD_PATH=${DOWNLOADS}/opencv-cache"
        ${BUILD_WITH_CONTRIB_FLAG}
        -DOPENCV_OTHER_INSTALL_PATH=share/opencv
        ###### customized properties
        ## Options from vcpkg_check_features()
        ${FEATURE_OPTIONS}
        -DWITH_GTK=${WITH_GTK}
        -DWITH_QT=${WITH_QT}
        -DWITH_IPP=${WITH_IPP}
        -DWITH_MATLAB=OFF
        -DWITH_MSMF=${WITH_MSMF}
        -DWITH_OPENMP=${WITH_OPENMP}
        -DWITH_PROTOBUF=${BUILD_opencv_flann}
        -DWITH_PYTHON=${WITH_PYTHON}
        -DWITH_OPENCLAMDBLAS=OFF
        -DWITH_TBB=${WITH_TBB}
        -DWITH_OPENJPEG=OFF
        -DWITH_CPUFEATURES=OFF
        ###### BUILD_options (mainly modules which require additional libraries)
        -DBUILD_opencv_ovis=${BUILD_opencv_ovis}
        -DBUILD_opencv_dnn=${BUILD_opencv_dnn}
        -DBUILD_opencv_python3=${BUILD_opencv_python3}
        ###### The following modules are disabled for UWP
        -DBUILD_opencv_quality=${BUILD_opencv_quality}
        ###### Additional build flags
        ${ADDITIONAL_BUILD_FLAGS}
        -DBUILD_IPP_IW=${WITH_IPP}
        -DOPENCV_LAPACK_FIND_PACKAGE_ONLY=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

if (NOT VCPKG_BUILD_TYPE)
  # Update debug paths for libs in Android builds (e.g. sdk/native/staticlibs/armeabi-v7a)
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/opencv3/OpenCVModules-debug.cmake"
      "\${_IMPORT_PREFIX}/sdk"
      "\${_IMPORT_PREFIX}/debug/sdk"
      IGNORE_UNCHANGED
  )
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(READ "${CURRENT_PACKAGES_DIR}/share/opencv3/OpenCVModules.cmake" OPENCV_MODULES)
  set(DEPS_STRING "include(CMakeFindDependencyMacro)
if(${BUILD_opencv_flann} AND NOT TARGET libprotobuf) #Check if the CMake target libprotobuf is already defined
  find_dependency(Protobuf CONFIG REQUIRED)
  if(TARGET protobuf::libprotobuf)
    add_library (libprotobuf INTERFACE IMPORTED)
    set_target_properties(libprotobuf PROPERTIES
      INTERFACE_LINK_LIBRARIES protobuf::libprotobuf
    )
  else()
    add_library (libprotobuf UNKNOWN IMPORTED)
    set_target_properties(libprotobuf PROPERTIES
      IMPORTED_LOCATION \"${Protobuf_LIBRARY}\"
      INTERFACE_INCLUDE_DIRECTORIES \"${Protobuf_INCLUDE_DIR}\"
      INTERFACE_SYSTEM_INCLUDE_DIRECTORIES \"${Protobuf_INCLUDE_DIR}\"
    )
  endif()
endif()
find_dependency(Threads)")
  if("tiff" IN_LIST FEATURES)
    string(APPEND DEPS_STRING "\nfind_dependency(TIFF)")
  endif()
  if("cuda" IN_LIST FEATURES)
    string(APPEND DEPS_STRING "\nfind_dependency(CUDA)")
  endif()
  if(BUILD_opencv_quality)
    string(APPEND DEPS_STRING "
# C language is required for try_compile tests in FindHDF5
enable_language(C)
find_dependency(HDF5)
find_dependency(Tesseract)")
  endif()
  if(WITH_TBB)
    string(APPEND DEPS_STRING "\nfind_dependency(TBB)")
  endif()
  if("vtk" IN_LIST FEATURES)
    string(APPEND DEPS_STRING "\nfind_dependency(VTK)")
  endif()
  if("sfm" IN_LIST FEATURES)
    string(APPEND DEPS_STRING "\nfind_dependency(gflags CONFIG)\nfind_dependency(Ceres CONFIG)")
  endif()
  if("eigen" IN_LIST FEATURES)
    string(APPEND DEPS_STRING "\nfind_dependency(Eigen3 CONFIG)")
  endif()
  if("lapack" IN_LIST FEATURES)
    string(APPEND DEPS_STRING "\nfind_dependency(LAPACK)")
  endif()
  if("openexr" IN_LIST FEATURES)
    string(APPEND DEPS_STRING "\nfind_dependency(OpenEXR CONFIG)")
  endif()
  if(WITH_OPENMP)
    string(APPEND DEPS_STRING "\nfind_dependency(OpenMP)")
  endif()
  if(BUILD_opencv_ovis)
    string(APPEND DEPS_STRING "\nfind_dependency(Ogre)\nfind_dependency(freetype)")
  endif()
  if("quirc" IN_LIST FEATURES)
    string(APPEND DEPS_STRING "\nfind_dependency(quirc)")
  endif()
  if("qt" IN_LIST FEATURES)
    string(APPEND DEPS_STRING "
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
find_dependency(Qt${USE_QT_VERSION} COMPONENTS Core Gui Widgets Test Concurrent)")
    if("opengl" IN_LIST FEATURES)
      string(APPEND DEPS_STRING "
find_dependency(Qt${USE_QT_VERSION} COMPONENTS OpenGL)")
    endif()
  endif()
  if("ade" IN_LIST FEATURES)
    string(APPEND DEPS_STRING "\nfind_dependency(ade)")
  endif()
  if("gdcm" IN_LIST FEATURES)
    string(APPEND DEPS_STRING "\nfind_dependency(GDCM)")
  endif()

  string(REPLACE "set(CMAKE_IMPORT_FILE_VERSION 1)"
                 "set(CMAKE_IMPORT_FILE_VERSION 1)\n${DEPS_STRING}" OPENCV_MODULES "${OPENCV_MODULES}")

  if(WITH_OPENMP)
    string(REPLACE "set_target_properties(opencv_core PROPERTIES
  INTERFACE_LINK_LIBRARIES \""
                   "set_target_properties(opencv_core PROPERTIES
  INTERFACE_LINK_LIBRARIES \"\$<LINK_ONLY:OpenMP::OpenMP_CXX>;" OPENCV_MODULES "${OPENCV_MODULES}")
  endif()

  if(BUILD_opencv_ovis)
    string(REPLACE "OgreGLSupportStatic"
                   "OgreGLSupport" OPENCV_MODULES "${OPENCV_MODULES}")
  endif()

  file(WRITE "${CURRENT_PACKAGES_DIR}/share/opencv3/OpenCVModules.cmake" "${OPENCV_MODULES}")


  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/opencv/licenses")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/opencv")

if(VCPKG_TARGET_IS_ANDROID)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/README.android")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/README.android")
endif()

vcpkg_fixup_pkgconfig()
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/opencv.pc")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/opencv.pc" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/" "\${prefix}" IGNORE_UNCHANGED)
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/opencv.pc")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/opencv.pc" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/" "\${prefix}" IGNORE_UNCHANGED)
endif()

configure_file("${CURRENT_PORT_DIR}/usage.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
