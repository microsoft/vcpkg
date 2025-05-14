set(USE_QT_VERSION "6")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO opencv/opencv
    REF "${VERSION}"
    SHA512 3b6e0da8169449944715de9e66380977791069a1d8288534ec768eaa2fb68533821fd8e06eac925a26656baf42185258b13aa80579e1e9be3ebc18fcea66f24d
    HEAD_REF master
    PATCHES
      0001-disable-downloading.patch
      0002-install-options.patch
      0003-force-package-requirements.patch
      0004-fix-eigen.patch
      0005-fix-policy-CMP0057.patch
      0006-fix-uwp.patch
      0008-devendor-quirc.patch
      0009-fix-protobuf.patch
      0010-fix-uwp-tiff-imgcodecs.patch
      0011-remove-python2.patch
      0012-miss-openexr.patch
      0014-fix-cmake-in-list.patch
      0015-fix-freetype.patch
      0017-fix-flatbuffers.patch
      0019-opencl-kernel.patch
)

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")
vcpkg_host_path_list(APPEND ENV{PKG_CONFIG_PATH} "${CURRENT_INSTALLED_DIR}/lib/pkgconfig")

# Disallow accidental build of vendored copies
file(REMOVE_RECURSE "${SOURCE_PATH}/3rdparty/openexr")
file(REMOVE_RECURSE "${SOURCE_PATH}/3rdparty/flatbuffers")
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

set(ADE_DIR ${CURRENT_INSTALLED_DIR}/share/ade CACHE PATH "Path to existing ADE CMake Config file")

# Cannot use vcpkg_check_features() for "qt" because it requires the QT version number passed, not just a boolean
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
 FEATURES
 "ade"        WITH_ADE
 "aravis"     WITH_ARAVIS
 "calib3d"    BUILD_opencv_calib3d
 "carotene"   WITH_CAROTENE
 "contrib"    WITH_CONTRIB
 "cuda"       WITH_CUBLAS
 "cuda"       WITH_CUDA
 "cuda"       ENABLE_CUDA_FIRST_CLASS_LANGUAGE
 "cudnn"      WITH_CUDNN
 "dc1394"     WITH_1394
 "directml"   WITH_DIRECTML
 "dnn"        BUILD_opencv_dnn
 "dnn"        PROTOBUF_UPDATE_FILES
 "dnn"        UPDATE_PROTO_FILES
 "dnn"        WITH_PROTOBUF
 "dnn-cuda"   OPENCV_DNN_CUDA
 "dshow"      WITH_DSHOW
 "eigen"      WITH_EIGEN
 "ffmpeg"     WITH_FFMPEG
 "freetype"   WITH_FREETYPE
 "gapi"       BUILD_opencv_gapi
 "gdcm"       WITH_GDCM
 "gstreamer"  WITH_GSTREAMER
 "gtk"        WITH_GTK
 "halide"     WITH_HALIDE
 "ipp"        WITH_IPP
 "ipp"        BUILD_IPP_IW
 "highgui"    BUILD_opencv_highgui
 "intrinsics" CV_ENABLE_INTRINSICS
 "openjpeg"   WITH_OPENJPEG
 "openmp"     WITH_OPENMP
 "jpeg"       WITH_JPEG
 "jpegxl"     WITH_JPEGXL
 "msmf"       WITH_MSMF
 "nonfree"    OPENCV_ENABLE_NONFREE
 "thread"     OPENCV_ENABLE_THREAD_SUPPORT
 "opencl"     WITH_OPENCL
 "openvino"   WITH_OPENVINO
 "openexr"    WITH_OPENEXR
 "opengl"     WITH_OPENGL
 "ovis"       CMAKE_REQUIRE_FIND_PACKAGE_OGRE
 "ovis"       BUILD_opencv_ovis
 "png"        WITH_PNG
 "python"     BUILD_opencv_python3
 "python"     WITH_PYTHON
 "quality"    BUILD_opencv_quality
 "quirc"      WITH_QUIRC
 "rgbd"       BUILD_opencv_rgbd
 "sfm"        BUILD_opencv_sfm
 "tbb"        WITH_TBB
 "tiff"       WITH_TIFF
 "vtk"        WITH_VTK
 "vulkan"     WITH_VULKAN
 "webp"       WITH_WEBP
 "win32ui"    WITH_WIN32UI
 "world"      BUILD_opencv_world
 INVERTED_FEATURES
 "fs"         OPENCV_DISABLE_FILESYSTEM_SUPPORT
)

if("dnn" IN_LIST FEATURES)
  set(FLATC "${CURRENT_HOST_INSTALLED_DIR}/tools/flatbuffers/flatc${VCPKG_HOST_EXECUTABLE_SUFFIX}")
  vcpkg_execute_required_process(
    COMMAND "${FLATC}" --cpp -o "${SOURCE_PATH}/modules/dnn/misc/tflite" "${SOURCE_PATH}/modules/dnn/src/tflite/schema.fbs"
    WORKING_DIRECTORY "${SOURCE_PATH}/modules/dnn/misc/tflite"
    LOGNAME flatc-${TARGET_TRIPLET}
  )
endif()

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
    message(FATAL_ERROR "You cannot install opencv4[python] if opencv3[python] is already present.")
  endif()
endif()

if("dnn" IN_LIST FEATURES)
  vcpkg_download_distfile(TINYDNN_ARCHIVE
    URLS "https://github.com/tiny-dnn/tiny-dnn/archive/v1.0.0a3.tar.gz"
    FILENAME "opencv-cache/tiny_dnn/adb1c512e09ca2c7a6faef36f9c53e59-v1.0.0a3.tar.gz"
    SHA512 5f2c1a161771efa67e85b1fea395953b7744e29f61187ac5a6c54c912fb195b3aef9a5827135c3668bd0eeea5ae04a33cc433e1f6683e2b7955010a2632d168b
  )
endif()

if("cuda" IN_LIST FEATURES)
  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://github.com/NVIDIA/NVIDIAOpticalFlowSDK/archive/edb50da3cf849840d680249aa6dbef248ebce2ca.zip"
    FILENAME "opencv-cache/nvidia_optical_flow/a73cd48b18dcc0cc8933b30796074191-edb50da3cf849840d680249aa6dbef248ebce2ca.zip"
    SHA512 12d655ac9fcfc6df0186daa62f7185dadd489f0eeea25567d78c2b47a9840dcce2bd03a3e9b3b42f125dbaf3150f52590ea7597dc1dc8acee852dc0aed56651e
  )
endif()

if(VCPKG_TARGET_IS_ANDROID AND (VCPKG_TARGET_ARCHITECTURE MATCHES "^arm"))
  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://gitlab.arm.com/kleidi/kleidicv/-/archive/0.3.0/kleidicv-0.3.0.tar.gz"
    FILENAME "opencv-cache/kleidicv/51a77b0185c2bac2a968a2163869b1ed-kleidicv-0.3.0.tar.gz"
    SHA512 9d4bf9db3134c1904656e781fdd58bbfe75cf1f23e551fad93b6df47bd1b00b0d62f05ee49c002e331b39ccbb911075c5fae5c291119d141025058dcb4bd5955
  )
endif()

if("contrib" IN_LIST FEATURES)
  vcpkg_from_github(
    OUT_SOURCE_PATH CONTRIB_SOURCE_PATH
    REPO opencv/opencv_contrib
    REF "${VERSION}"
    SHA512 a5ebb6810a3b5e40858b7fd533f9eb7b3d475dfda843a489bc5168e72c5eaad0a7a23629aace1f43e1b62d9c24e5e1923d841059c297728fac464e00759886c2
    HEAD_REF master
    PATCHES
      0007-contrib-fix-hdf5.patch
      0013-contrib-fix-ogre.patch
      0016-contrib-fix-freetype.patch
      0018-contrib-fix-tesseract.patch
  )

  set(BUILD_WITH_CONTRIB_FLAG "-DOPENCV_EXTRA_MODULES_PATH=${CONTRIB_SOURCE_PATH}/modules")

  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://raw.githubusercontent.com/WeChatCV/opencv_3rdparty/a8b69ccc738421293254aec5ddb38bd523503252/detect.caffemodel"
    FILENAME "opencv-cache/wechat_qrcode/238e2b2d6f3c18d6c3a30de0c31e23cf-detect.caffemodel"
    SHA512 58d62faf8679d3f568a26a1d9f7c2e88060426a440315ca8bce7b3b5a8efa34be670afd0abfd0dd5d89f89a042a2408ea602f937080abc6910c2e497b7f5a4b8
  )
  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://raw.githubusercontent.com/WeChatCV/opencv_3rdparty/a8b69ccc738421293254aec5ddb38bd523503252/sr.caffemodel"
    FILENAME "opencv-cache/wechat_qrcode/cbfcd60361a73beb8c583eea7e8e6664-sr.caffemodel"
    SHA512 917c6f6b84a898b8c8c85c79359e48a779c8a600de563dac2e1c5d013401e9ac9dbcd435013a4ed7a69fc936839fb189aaa3038c127d04ceb6fd3b8fd9dd67bd
  )
  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://raw.githubusercontent.com/WeChatCV/opencv_3rdparty/a8b69ccc738421293254aec5ddb38bd523503252/detect.prototxt"
    FILENAME "opencv-cache/wechat_qrcode/6fb4976b32695f9f5c6305c19f12537d-detect.prototxt"
    SHA512 2239d31a597049f358f09dbb4c0a7af0b384d9b67cfa3224f8c7e44329647cf19ee7929ac06199cca23bbbf431de0481b74ab51eace6aa20bb2e2fd19b536e49
  )
  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://raw.githubusercontent.com/WeChatCV/opencv_3rdparty/a8b69ccc738421293254aec5ddb38bd523503252/sr.prototxt"
    FILENAME "opencv-cache/wechat_qrcode/69db99927a70df953b471daaba03fbef-sr.prototxt"
    SHA512 6b715ec45c3fd081e7e113e351edcef0f3d32a75f8b5a9ca2273cb5da9a1116a1b78cba45582a9acf67a7ab76dc4fcdf123f7b3a0d3de2f5c39b26ef450058b7
  )
  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/34e4206aef44d50e6bbcd0ab06354b52e7466d26/boostdesc_bgm.i"
    FILENAME "opencv-cache/xfeatures2d/boostdesc/0ea90e7a8f3f7876d450e4149c97c74f-boostdesc_bgm.i"
    SHA512 5c8702a60314fac4ebb6dafb62a603948ec034058d1a582fcb89a063b51511802c02e192eadfc0b233b1f711f4c74cabab6d9ebe8a50c3554ea0ccdbef87dc5c
  )
  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/34e4206aef44d50e6bbcd0ab06354b52e7466d26/boostdesc_bgm_bi.i"
    FILENAME "opencv-cache/xfeatures2d/boostdesc/232c966b13651bd0e46a1497b0852191-boostdesc_bgm_bi.i"
    SHA512 b28ba2b615e0755ff0f6733b567682800fb9e7d522250aa498075cc1b8927f4177cacdcb0cfdf712539a29c4773232dc714931b6d292292b091b5cf170b203a6
  )
  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/34e4206aef44d50e6bbcd0ab06354b52e7466d26/boostdesc_bgm_hd.i"
    FILENAME "opencv-cache/xfeatures2d/boostdesc/324426a24fa56ad9c5b8e3e0b3e5303e-boostdesc_bgm_hd.i"
    SHA512 c214045c3730a1d9dfc594f70895edf82d2fd3058a3928908627014371e02460d052cbaedf41bb96cf76460c0a8b4b01b7b0ac7d269ec5d3f17f2a46c9f0091b
  )
  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/34e4206aef44d50e6bbcd0ab06354b52e7466d26/boostdesc_binboost_064.i"
    FILENAME "opencv-cache/xfeatures2d/boostdesc/202e1b3e9fec871b04da31f7f016679f-boostdesc_binboost_064.i"
    SHA512 f32240a7b975233d2bbad02fdb74c6e29ed71ed6f0c08172ca33eb1e69a7a7f6d6964adf41422213a0452121a9c4bb2effe3d7b9d6743c9bf58d4bc8c9b1db36
  )
  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/34e4206aef44d50e6bbcd0ab06354b52e7466d26/boostdesc_binboost_128.i"
    FILENAME "opencv-cache/xfeatures2d/boostdesc/98ea99d399965c03d555cef3ea502a0b-boostdesc_binboost_128.i"
    SHA512 f58e2bebfaa690d324691a6c2067d9a1e5267037ea0f2b397966289253b9efd27d8238aff6206e95262086e1fcddf01ae1a1c49f066a8bbac3aa7908214b9a8f
  )
  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/34e4206aef44d50e6bbcd0ab06354b52e7466d26/boostdesc_binboost_256.i"
    FILENAME "opencv-cache/xfeatures2d/boostdesc/e6dcfa9f647779eb1ce446a8d759b6ea-boostdesc_binboost_256.i"
    SHA512 351ee07b9714a379c311f293d96e99f001c894393c911a421b4c536345d43c02ba2d867e9f657eac104841563045ab8c8edab878e5ffeb1e1a7494375ef58987
  )
  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/34e4206aef44d50e6bbcd0ab06354b52e7466d26/boostdesc_lbgm.i"
    FILENAME "opencv-cache/xfeatures2d/boostdesc/0ae0675534aa318d9668f2a179c2a052-boostdesc_lbgm.i"
    SHA512 7fa12e2207ff154acf2433bbb4f3f47aa71d1fa8789493b688d635d20586b7ead30ee8dcd3b3753992ebbe98062cbde44d02683db1c563d52e35aefd7912a4f2
  )
  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/fccf7cd6a4b12079f73bbfb21745f9babcd4eb1d/vgg_generated_48.i"
    FILENAME "opencv-cache/xfeatures2d/vgg/e8d0dcd54d1bcfdc29203d011a797179-vgg_generated_48.i"
    SHA512 2403e9119738261a05a3116ca7e5c9e11da452c422f8670cd96ad2cb5bf970f76172e23b9913a3172adf06f2b31bee956f605b66dbccf3d706c4334aff713774
  )
  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/fccf7cd6a4b12079f73bbfb21745f9babcd4eb1d/vgg_generated_64.i"
    FILENAME "opencv-cache/xfeatures2d/vgg/7126a5d9a8884ebca5aea5d63d677225-vgg_generated_64.i"
    SHA512 2c954223677905f489b01988389ac80a8caa33bdb57adb3cb9409075012b5e2f472f14966d8be75d75c90c9330f66d59c69539dc6b5a5e265a4d98ff5041f0ea
  )
  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/fccf7cd6a4b12079f73bbfb21745f9babcd4eb1d/vgg_generated_80.i"
    FILENAME "opencv-cache/xfeatures2d/vgg/7cd47228edec52b6d82f46511af325c5-vgg_generated_80.i"
    SHA512 9931ad1d1bd6d11951ca5357ab0a524f6ff9b33f936ceeafebc0dafb379ec7e2105e467443e9f424f60a0f2f445bdff821ed9e42330abed883227183ebad4a9e
  )
  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/fccf7cd6a4b12079f73bbfb21745f9babcd4eb1d/vgg_generated_120.i"
    FILENAME "opencv-cache/xfeatures2d/vgg/151805e03568c9f490a5e3a872777b75-vgg_generated_120.i"
    SHA512 ad7c1d2b159ab5790c898815663bb90549f1cf7ade3c82d939d381608b26d26c5b2af01eb1ba21f4d114ced74586ab3fc83f14e2d8cfe4e6faac538aa0e7e255
  )
  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/8afa57abc8229d611c4937165d20e2a2d9fc5a12/face_landmark_model.dat"
    FILENAME "opencv-cache/data/7505c44ca4eb54b4ab1e4777cb96ac05-face_landmark_model.dat"
    SHA512 c16e60a6c4bb4de3ab39b876ae3c3f320ea56f69c93e9303bd2dff8760841dcd71be4161fff8bc71e8fe4fe8747fa8465d49d6bd8f5ebcdaea161f4bc2da7c93
  )
endif()

if("ipp" IN_LIST FEATURES)
  if(VCPKG_TARGET_IS_OSX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
      vcpkg_download_distfile(OCV_DOWNLOAD
          URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/0cc4aa06bf2bef4b05d237c69a5a96b9cd0cb85a/ippicv/ippicv_2021.9.1_mac_intel64_20230919_general.tgz"
          FILENAME "opencv-cache/ippicv/14f01c5a4780bfae9dde9b0aaf5e56fc-ippicv_2021.9.1_mac_intel64_20230919_general.tgz"
          SHA512 e53aa1bf4336a94554bf40c29a74c85f595c0aec8d9102a158db7ae075db048c1ff7f50ed81eda3ac8e07b1460862970abc820073a53c0f237e584708c5295da
      )
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
      message(FATAL_ERROR "IPP is not supported on arm64 macOS")
    endif()
  elseif(VCPKG_TARGET_IS_LINUX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
      vcpkg_download_distfile(OCV_DOWNLOAD
          URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/7f55c0c26be418d494615afca15218566775c725/ippicv/ippicv_2021.12.0_lnx_intel64_20240425_general.tgz"
          FILENAME "opencv-cache/ippicv/d06e6d44ece88f7f17a6cd9216761186-ippicv_2021.12.0_lnx_intel64_20240425_general.tgz"
          SHA512 b5cffc23be195990d07709057e01d4205083652a1cdf52d076a700d7086244fe91846d2afae126a197603c58b7099872c3e908dfc22b74b21dd2b97219a8bfdd
      )
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
      vcpkg_download_distfile(OCV_DOWNLOAD
          URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/7f55c0c26be418d494615afca15218566775c725/ippicv/ippicv_2021.12.0_lnx_ia32_20240425_general.tgz"
          FILENAME "opencv-cache/ippicv/85ffa2b9ed7802b93c23fa27b0097d36-ippicv_2021.12.0_lnx_ia32_20240425_general.tgz"
          SHA512 e3391ca0e8ed2235e32816cee55293ddd7c312a8c8ba42b1301cbb8752c6b7d47139ab3fe2aa8dd3e1670221e911cc96614bbc066e2bf9a653607413126b5ff1
      )
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
      message(FATAL_ERROR "IPP is not supported on arm64 linux")
    endif()
  elseif(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
      vcpkg_download_distfile(OCV_DOWNLOAD
          URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/7f55c0c26be418d494615afca15218566775c725/ippicv/ippicv_2021.12.0_win_intel64_20240425_general.zip"
          FILENAME "opencv-cache/ippicv/402ff8c6b4986738fed71c44e1ce665d-ippicv_2021.12.0_win_intel64_20240425_general.zip"
          SHA512 455e2983a4048db68ad2c4274ee009a7e9d30270c07a7bd9d06d3ae5904326d1a98155e9bb3ea8c47f8ea840671db2e0b3d5f7603fa82a926b23a1ec4f77d2fa
      )
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
      vcpkg_download_distfile(OCV_DOWNLOAD
          URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/7f55c0c26be418d494615afca15218566775c725/ippicv/ippicv_2021.12.0_win_ia32_20240425_general.zip"
          FILENAME "opencv-cache/ippicv/8b1d2a23957d57624d0de8f2a5cae5f1-ippicv_2021.12.0_win_ia32_20240425_general.zip"
          SHA512 494f66af4eec3030fe6d2b58b89267d566fcb31f445d15cc69818d423c41fd950dc55d10694bdf91e3204ae6b13b68cc2375a2ad396b2008596c53aa0d39f4dd
      )
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
      message(FATAL_ERROR "IPP is not supported on arm64 windows")
    endif()
  endif()
endif()

if("ffmpeg" IN_LIST FEATURES)
  if(VCPKG_TARGET_IS_UWP)
    set(VCPKG_C_FLAGS "/sdl- ${VCPKG_C_FLAGS}")
    set(VCPKG_CXX_FLAGS "/sdl- ${VCPKG_CXX_FLAGS}")
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

if("contrib" IN_LIST FEATURES)
  if(VCPKG_TARGET_IS_UWP)
    list(APPEND ADDITIONAL_BUILD_FLAGS "-DWITH_TESSERACT=OFF")
  endif()
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
        -DOPENCV_INCLUDE_INSTALL_PATH=include/opencv4
        -DOPENCV_LIB_INSTALL_PATH=lib
        -DOPENCV_3P_LIB_INSTALL_PATH=lib/manual-link/opencv4_thirdparty
        -DOPENCV_CONFIG_INSTALL_PATH=share/opencv4
        -DOPENCV_FFMPEG_USE_FIND_PACKAGE=FFMPEG
        -DOPENCV_FFMPEG_SKIP_BUILD_CHECK=TRUE
        -DCMAKE_DEBUG_POSTFIX=d
        -DOPENCV_DLLVERSION=4
        -DOPENCV_DEBUG_POSTFIX=d
        -DOPENCV_GENERATE_SETUPVARS=OFF
        -DOPENCV_GENERATE_PKGCONFIG=ON
        # Do not build docs/examples
        -DBUILD_DOCS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_PERF_TESTS=OFF
        -DBUILD_TESTS=OFF
        -Dade_DIR=${ADE_DIR}
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
        ###### PYLINT/FLAKE8
        -DENABLE_PYLINT=OFF
        -DENABLE_FLAKE8=OFF
        # CMAKE
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_JNI=ON
        ###### OPENCV vars
        "-DOPENCV_DOWNLOAD_PATH=${DOWNLOADS}/opencv-cache"
        ${BUILD_WITH_CONTRIB_FLAG}
        -DOPENCV_OTHER_INSTALL_PATH=share/opencv4
        ###### customized properties
        ${FEATURE_OPTIONS}
        -DWITH_QT=${WITH_QT}
        -DWITH_AVIF=OFF
        -DWITH_CPUFEATURES=OFF
        -DWITH_ITT=OFF
        -DWITH_JASPER=OFF #Jasper is deprecated and will be removed in a future release, and is mutually exclusive with openjpeg that is preferred
        -DWITH_LAPACK=OFF
        -DWITH_MATLAB=OFF
        -DWITH_NVCUVID=OFF
        -DWITH_NVCUVENC=OFF
        -DWITH_OBSENSOR=OFF
        -DWITH_OPENCL_D3D11_NV=OFF
        -DWITH_OPENCLAMDFFT=OFF
        -DWITH_OPENCLAMDBLAS=OFF
        -DWITH_SPNG=OFF #spng is mutually exclusive with png, which has been chosen since it's more widely used
        -DWITH_VA=OFF
        -DWITH_VA_INTEL=OFF
        -DWITH_ZLIB_NG=OFF
        ###### Additional build flags
        ${ADDITIONAL_BUILD_FLAGS}
    OPTIONS_RELEASE
        ${PYTHON_EXTRA_DEFINES_RELEASE}
    OPTIONS_DEBUG
        ${PYTHON_EXTRA_DEFINES_DEBUG}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

if (NOT VCPKG_BUILD_TYPE)
  # Update debug paths for libs in Android builds (e.g. sdk/native/staticlibs/armeabi-v7a)
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/opencv4/OpenCVModules-debug.cmake"
      "\${_IMPORT_PREFIX}/sdk"
      "\${_IMPORT_PREFIX}/debug/sdk"
      IGNORE_UNCHANGED
  )
endif()

file(READ "${CURRENT_PACKAGES_DIR}/share/opencv4/OpenCVModules.cmake" OPENCV_MODULES)
set(DEPS_STRING "include(CMakeFindDependencyMacro)
if(${BUILD_opencv_dnn} AND NOT TARGET libprotobuf)  #Check if the CMake target libprotobuf is already defined
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

if("ade" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(ade)")
endif()
if("contrib" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_UWP AND NOT VCPKG_TARGET_IS_IOS AND NOT (VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE MATCHES "^arm"))
  string(APPEND DEPS_STRING "
# C language is required for try_compile tests in FindHDF5
enable_language(C)
find_dependency(HDF5)
find_dependency(Tesseract)")
endif()
if("eigen" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(Eigen3 CONFIG)")
endif()
if("ffmpeg" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(FFMPEG)")
endif()
if("freetype" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(harfbuzz)")
endif()
if("gdcm" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(GDCM)")
endif()
if("omp" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(OpenMP)")
endif()
if("openexr" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(OpenEXR CONFIG)")
endif()
if("openjpeg" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(OpenJPEG)")
endif()
if("openvino" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(OpenVINO CONFIG)")
endif()
if("ovis" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(OGRE)")
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
if("quirc" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(quirc)")
endif()
if("sfm" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(gflags CONFIG)\nfind_dependency(Ceres CONFIG)")
endif()
if("tbb" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(TBB)")
endif()
if("tiff" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(TIFF)")
endif()
if("vtk" IN_LIST FEATURES)
  string(APPEND DEPS_STRING "\nfind_dependency(VTK)")
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

file(WRITE "${CURRENT_PACKAGES_DIR}/share/opencv4/OpenCVModules.cmake" "${OPENCV_MODULES}")

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

if (EXISTS "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/opencv4.pc")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/opencv4.pc"
    "-lQt6::Core5Compat"
    "-lQt6Core5Compat"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/opencv4.pc"
    "-lhdf5::hdf5-static"
    "-lhdf5"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/opencv4.pc"
    "-lglog::glog"
    "-lglog"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/opencv4.pc"
    "-lgflags::gflags_static"
    "-lgflags"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/opencv4.pc"
    "-lTesseract::libtesseract"
    "-ltesseract"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/opencv4.pc"
    "-lharfbuzz::harfbuzz"
    "-lharfbuzz"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/opencv4.pc"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/"
    "\${prefix}"
    IGNORE_UNCHANGED
  )
endif()

if (EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/opencv4.pc")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/opencv4.pc"
    "-lQt6::Core5Compat"
    "-lQt6Core5Compat"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/opencv4.pc"
    "-lhdf5::hdf5-static"
    "-lhdf5"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/opencv4.pc"
    "-lglog::glog"
    "-lglog"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/opencv4.pc"
    "-lgflags::gflags_static"
    "-lgflags"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/opencv4.pc"
    "-lTesseract::libtesseract"
    "-ltesseract"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/opencv4.pc"
    "-lharfbuzz::harfbuzz"
    "-lharfbuzz"
    IGNORE_UNCHANGED
  )
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/opencv4.pc"
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
file(GLOB_RECURSE extra2_license_files "${CURRENT_PACKAGES_DIR}/share/opencv4/licenses/*")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" ${extra1_license_files} ${extra2_license_files})
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/opencv4/licenses")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/licenses")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/opencv")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
