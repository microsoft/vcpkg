set(USE_QT_VERSION "5")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO opencv/opencv
    REF "${VERSION}"
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
      0014-fix-pkgconf-name.patch
      0015-fix-supportqnx.patch
      0017-missing-include.patch
      0019-fix-tbb.patch
)
# Disallow accidental build of vendored copies
file(REMOVE_RECURSE "${SOURCE_PATH}/3rdparty/openexr")
file(REMOVE "${SOURCE_PATH}/cmake/FindCUDNN.cmake")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
  set(TARGET_IS_AARCH64 1)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
  set(TARGET_IS_ARM 1)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  set(TARGET_IS_X86_64 1)
else()
  set(TARGET_IS_X86 1)
endif()

if (USE_QT_VERSION STREQUAL "6")
  set(QT_CORE5COMPAT "Core5Compat")
  set(QT_OPENGLWIDGETS "OpenGLWidgets")
endif()

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" BUILD_WITH_STATIC_CRT)

# Cannot use vcpkg_check_features() for "qt" because it requires the QT version number passed, not just a boolean
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
 FEATURES
 "bgsegm"          BUILD_opencv_bgsegm
 "contrib"         WITH_CONTRIB
 "dc1394"          WITH_1394
 "dnn"             BUILD_opencv_dnn
 "eigen"           WITH_EIGEN
 "flann"           BUILD_opencv_flann
 "flann"           PROTOBUF_UPDATE_FILES
 "flann"           UPDATE_PROTO_FILES
 "flann"           WITH_PROTOBUF
 "freetype"        WITH_FREETYPE
 "gdcm"            WITH_GDCM
 "gstreamer"       WITH_GSTREAMER
 "gtk"             WITH_GTK
 "halide"          WITH_HALIDE
 "ipp"             WITH_IPP
 "ipp"             BUILD_IPP_IW
 "jasper"          WITH_JASPER
 "jpeg"            WITH_JPEG
 "lapack"          WITH_LAPACK
 "line-descriptor" BUILD_opencv_line_descriptor
 "msmf"            WITH_MSMF
 "nonfree"         OPENCV_ENABLE_NONFREE
 "openexr"         WITH_OPENEXR
 "opengl"          WITH_OPENGL
 "openmp"          WITH_OPENMP
 "ovis"            BUILD_opencv_ovis
 "png"             WITH_PNG
 "python"          BUILD_opencv_python3
 "python"          WITH_PYTHON
 "quality"         BUILD_opencv_quality
 "quirc"           WITH_QUIRC
 "saliency"        BUILD_opencv_saliency
 "sfm"             BUILD_opencv_sfm
 "tbb"             WITH_TBB
 "tiff"            WITH_TIFF
 "vtk"             WITH_VTK
 "webp"            WITH_WEBP
 "world"           BUILD_opencv_world
)

# Cannot use vcpkg_check_features() for "python", "qt"
set(WITH_QT OFF)
if("qt" IN_LIST FEATURES)
  set(WITH_QT ${USE_QT_VERSION})
endif()

if("python" IN_LIST FEATURES)
  x_vcpkg_get_python_packages(PYTHON_VERSION "3" PACKAGES numpy OUT_PYTHON_VAR "PYTHON3")
  set(ENV{PYTHON} "${PYTHON3}")
  file(GLOB _py3_include_path "${CURRENT_INSTALLED_DIR}/include/python3*")
  string(REGEX MATCH "python3\\.([0-9]+)" _python_version_tmp ${_py3_include_path})
  set(PYTHON_VERSION_MINOR "${CMAKE_MATCH_1}")
  set(python_ver "3.${PYTHON_VERSION_MINOR}")
  list(APPEND PYTHON_EXTRA_DEFINES_RELEASE
    "-D__INSTALL_PATH_PYTHON3=${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}/cv2"
    "-DOPENCV_PYTHON_INSTALL_PATH=${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}"
  )
  list(APPEND PYTHON_EXTRA_DEFINES_DEBUG
    "-D__INSTALL_PATH_PYTHON3=${CURRENT_PACKAGES_DIR}/debug/${PYTHON3_SITE}/cv2"
    "-DOPENCV_PYTHON_INSTALL_PATH=${CURRENT_PACKAGES_DIR}/debug/${PYTHON3_SITE}"
  )
  if(EXISTS "${CURRENT_INSTALLED_DIR}/${PYTHON3_SITE}/cv2")
    message(FATAL_ERROR "You cannot install opencv3[python] if opencv4[python] is already present.")
  endif()
endif()

if("dnn" IN_LIST FEATURES)
  vcpkg_download_distfile(TINYDNN_ARCHIVE
    URLS "https://github.com/tiny-dnn/tiny-dnn/archive/v1.0.0a3.tar.gz"
    FILENAME "opencv-cache/tiny_dnn/adb1c512e09ca2c7a6faef36f9c53e59-v1.0.0a3.tar.gz"
    SHA512 5f2c1a161771efa67e85b1fea395953b7744e29f61187ac5a6c54c912fb195b3aef9a5827135c3668bd0eeea5ae04a33cc433e1f6683e2b7955010a2632d168b
  )
endif()

if("contrib" IN_LIST FEATURES)
  vcpkg_from_github(
    OUT_SOURCE_PATH CONTRIB_SOURCE_PATH
    REPO opencv/opencv_contrib
    REF "${VERSION}"
    SHA512 a051497e61ae55f86c224044487fc2247a3bba1aa27031c4997c981ddf8402edf82f1dd0d307f562c638bc021cfd8bd42a723973f00ab25131495f84d33c5383
    HEAD_REF master
    PATCHES
      0007-contrib-fix-hdf5.patch
      0013-contrib-fix-ceres.patch
      0016-contrib-fix-freetype.patch
      0018-contrib-fix-tesseract.patch
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

if("ipp" IN_LIST FEATURES)
  if(VCPKG_TARGET_IS_OSX)
    vcpkg_download_distfile(OCV_DOWNLOAD
      URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/a56b6ac6f030c312b2dce17430eef13aed9af274/ippicv/ippicv_2020_mac_intel64_20191018_general.tgz"
      FILENAME "opencv-cache/ippicv/1c3d675c2a2395d094d523024896e01b-ippicv_2020_mac_intel64_20191018_general.tgz"
      SHA512 454dfaaa245e3a3b2f1ffb1aa8e27e280b03685009d66e147482b14e5796fdf2d332cac0f9b0822caedd5760fda4ee0ce2961889597456bbc18202f10bf727cd
    )
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
    endif()
  endif()
endif()

if("halide" IN_LIST FEATURES)
  list(APPEND ADDITIONAL_BUILD_FLAGS
    # Halide 13 requires C++17
    "-DCMAKE_CXX_STANDARD_REQUIRED=ON"
    "-DCMAKE_DISABLE_FIND_PACKAGE_Halide=ON"
    "-DHALIDE_ROOT_DIR=${CURRENT_INSTALLED_DIR}"
  )
endif()

if("qt" IN_LIST FEATURES)
  list(APPEND ADDITIONAL_BUILD_FLAGS "-DCMAKE_AUTOMOC=ON")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ###### Verify that required components and only those are enabled
        -DENABLE_CONFIG_VERIFICATION=ON
        ###### opencv cpu recognition is broken, always using host and not target: here we bypass that
        -DOPENCV_SKIP_SYSTEM_PROCESSOR_DETECTION=TRUE
        -DAARCH64=${TARGET_IS_AARCH64}
        -DX86_64=${TARGET_IS_X86_64}
        -DX86=${TARGET_IS_X86}
        -DARM=${TARGET_IS_ARM}
        ###### use c++17 to enable features that fail with c++11 (halide, protobuf, etc.)
        -DCMAKE_CXX_STANDARD=17
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
        -DBUILD_PERF_TESTS=OFF
        -DBUILD_TESTS=OFF
        ###### Disable build 3rd party libs
        -DBUILD_IPP_IW=OFF
        -DBUILD_ITT=OFF
        -DBUILD_JASPER=OFF
        -DBUILD_JPEG=OFF
        -DBUILD_OPENEXR=OFF
        -DBUILD_OPENJPEG=OFF
        -DBUILD_PNG=OFF
        -DBUILD_PROTOBUF=OFF
        -DBUILD_TBB=OFF
        -DBUILD_TIFF=OFF
        -DBUILD_WEBP=OFF
        -DBUILD_ZLIB=OFF
        -DOPENCV_LAPACK_FIND_PACKAGE_ONLY=ON
        ###### OpenCV Build components
        -DBUILD_opencv_apps=OFF
        -DBUILD_opencv_java=OFF
        -DBUILD_opencv_js=OFF
        -DBUILD_JAVA=OFF
        -DBUILD_ANDROID_PROJECT=OFF
        -DBUILD_ANDROID_EXAMPLES=OFF
        -DBUILD_PACKAGE=OFF
        -DBUILD_WITH_DEBUG_INFO=ON
        -DBUILD_WITH_STATIC_CRT=${BUILD_WITH_STATIC_CRT}
        -DCURRENT_INSTALLED_DIR=${CURRENT_INSTALLED_DIR}
        ###### PROTOBUF
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
        -DOPENCV_OTHER_INSTALL_PATH=share/opencv3
        ###### customized properties
        ## Options from vcpkg_check_features()
        ${FEATURE_OPTIONS}
        -DWITH_QT=${WITH_QT}
        -DWITH_MATLAB=OFF
        -DWITH_OPENJPEG=OFF
        -DWITH_CPUFEATURES=OFF
        -DWITH_SPNG=OFF
        -DWITH_OPENCLAMDFFT=OFF
        -DWITH_OPENCLAMDBLAS=OFF
        -DWITH_OPENCL_D3D11_NV=OFF
        -DWITH_ITT=OFF
        -DWITH_NVCUVID=OFF
        -DWITH_NVCUVENC=OFF
        -DWITH_AVIF=OFF
        -DWITH_VA=OFF
        -DWITH_VA_INTEL=OFF
        -DWITH_FFMPEG=OFF
        -DWITH_CUDA=OFF
        -DWITH_CUBLAS=OFF
        ###### Additional build flags
        ${ADDITIONAL_BUILD_FLAGS}
    OPTIONS_RELEASE
        ###### Python install path
        ${PYTHON_EXTRA_DEFINES_RELEASE}
    OPTIONS_DEBUG
        ###### Python install path
        ${PYTHON_EXTRA_DEFINES_DEBUG}
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
if("ffmpeg" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(FFMPEG)")
endif()
if("contrib" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_UWP AND NOT VCPKG_TARGET_IS_IOS AND NOT (VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE MATCHES "^arm"))
  string(APPEND DEPS_STRING "
# C language is required for try_compile tests in FindHDF5
enable_language(C)
find_dependency(HDF5)
find_dependency(Tesseract)")
endif()
if("freetype" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(harfbuzz)")
endif()
if("tbb" IN_LIST FEATURES)
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
if("openvino" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(OpenVINO CONFIG)")
endif()
if("openexr" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(OpenEXR CONFIG)")
endif()
if("openjpeg" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(OpenJPEG)")
endif()
if("omp" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(OpenMP)")
endif()
if("ovis" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(OGRE)")
endif()
if("quirc" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(quirc)")
endif()
if("qt" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)")
  if("opengl" IN_LIST FEATURES)
    string(APPEND DEPS_STRING "
find_dependency(Qt${USE_QT_VERSION} COMPONENTS Core Gui Widgets Test Concurrent ${QT_CORE5COMPAT} OpenGL ${QT_OPENGLWIDGETS})")
  else()
    string(APPEND DEPS_STRING "
find_dependency(Qt${USE_QT_VERSION} COMPONENTS Core Gui Widgets Test Concurrent ${QT_CORE5COMPAT})")
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

if("openmp" IN_LIST FEATURES)
  string(REPLACE "set_target_properties(opencv_core PROPERTIES
INTERFACE_LINK_LIBRARIES \""
                 "set_target_properties(opencv_core PROPERTIES
INTERFACE_LINK_LIBRARIES \"\$<LINK_ONLY:OpenMP::OpenMP_CXX>;" OPENCV_MODULES "${OPENCV_MODULES}")
endif()

if("ovis" IN_LIST FEATURES)
  string(REPLACE "OgreGLSupportStatic"
                 "OgreGLSupport" OPENCV_MODULES "${OPENCV_MODULES}")
endif()

file(WRITE "${CURRENT_PACKAGES_DIR}/share/opencv3/OpenCVModules.cmake" "${OPENCV_MODULES}")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

if(VCPKG_TARGET_IS_ANDROID)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/README.android")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/README.android")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}/cv2/typing")
file(GLOB PYTHON3_SITE_FILES "${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}/cv2/*.py")
foreach(PYTHON3_SITE_FILE ${PYTHON3_SITE_FILES})
  vcpkg_replace_string("${PYTHON3_SITE_FILE}"
    "os.path.join('${CURRENT_PACKAGES_DIR}'"
    "os.path.join('.'"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${PYTHON3_SITE_FILE}"
    "os.path.join('${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}/cv2'"
    "os.path.join('.'"
    IGNORE_UNCHANGED
  )
endforeach()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/${PYTHON3_SITE}/cv2/typing")
file(GLOB PYTHON3_SITE_FILES_DEBUG "${CURRENT_PACKAGES_DIR}/debug/${PYTHON3_SITE}/cv2/*.py")
foreach(PYTHON3_SITE_FILE_DEBUG ${PYTHON3_SITE_FILES_DEBUG})
  vcpkg_replace_string("${PYTHON3_SITE_FILE_DEBUG}"
    "os.path.join('${CURRENT_PACKAGES_DIR}/debug'"
    "os.path.join('.'"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${PYTHON3_SITE_FILE_DEBUG}"
    "os.path.join('${CURRENT_PACKAGES_DIR}/debug/${PYTHON3_SITE}/cv2'"
    "os.path.join('.'"
    IGNORE_UNCHANGED
  )
endforeach()

if (EXISTS "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/opencv3.pc")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/opencv3.pc"
    "-lQt6::Core5Compat"
    "-lQt6Core5Compat"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/opencv3.pc"
    "-lhdf5::hdf5-static"
    "-lhdf5"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/opencv3.pc"
    "-lglog::glog"
    "-lglog"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/opencv3.pc"
    "-lgflags::gflags_static"
    "-lgflags"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/opencv3.pc"
    "-lTesseract::libtesseract"
    "-ltesseract"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/opencv3.pc"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/"
    "\${prefix}"
    IGNORE_UNCHANGED
  )
endif()

if (EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/opencv3.pc")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/opencv3.pc"
    "-lQt6::Core5Compat"
    "-lQt6Core5Compat"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/opencv3.pc"
    "-lhdf5::hdf5-static"
    "-lhdf5"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/opencv3.pc"
    "-lglog::glog"
    "-lglog"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/opencv3.pc"
    "-lgflags::gflags_static"
    "-lgflags"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/opencv3.pc"
    "-lTesseract::libtesseract"
    "-ltesseract"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/opencv3.pc"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/"
    "\${prefix}"
    IGNORE_UNCHANGED
  )
endif()

vcpkg_fixup_pkgconfig()

configure_file("${CURRENT_PORT_DIR}/usage.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)

file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/LICENSE")
file(GLOB_RECURSE extra1_license_files "${CURRENT_PACKAGES_DIR}/share/licenses/*")
file(GLOB_RECURSE extra2_license_files "${CURRENT_PACKAGES_DIR}/share/opencv3/licenses/*")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" ${extra1_license_files} ${extra2_license_files})
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/opencv3/licenses")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/licenses")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/opencv")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
