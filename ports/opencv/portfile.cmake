include(vcpkg_common_functions)

set(OPENCV_PORT_VERSION "3.4.1")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO opencv/opencv
    REF ${OPENCV_PORT_VERSION}
    SHA512 e1fc14285090c6fe9e26e721f2d67d7096650c523147e925567426ef76aa7f4c6f12035d6f6ce3ec7991a75a6828a810fd4f9b75f78ed5fcccecefbadd79944b
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
      "${CMAKE_CURRENT_LIST_DIR}/0001-winrt-fixes.patch"
      "${CMAKE_CURRENT_LIST_DIR}/0002-install-options.patch"
      "${CMAKE_CURRENT_LIST_DIR}/0003-disable-downloading.patch"
      "${CMAKE_CURRENT_LIST_DIR}/0004-use-find-package-required.patch"
      "${CMAKE_CURRENT_LIST_DIR}/0005-remove-protobuf-target.patch"
)

file(WRITE "${CURRENT_BUILDTREES_DIR}/src/opencv-${OPENCV_PORT_VERSION}/rework.stamp")

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" BUILD_WITH_STATIC_CRT)

set(CMAKE_MODULE_PATH)

set(BUILD_opencv_dnn OFF)
set(WITH_PROTOBUF OFF)
if("dnn" IN_LIST FEATURES)
  set(BUILD_opencv_dnn ON)
  set(WITH_PROTOBUF ON)
  set(PROTOBUF_UPDATE_FILES ON)
  set(UPDATE_PROTO_FILES ON)
  vcpkg_download_distfile(TINYDNN_ARCHIVE
    URLS "https://github.com/tiny-dnn/tiny-dnn/archive/v1.0.0a3.tar.gz"
    FILENAME "opencv-cache/tiny_dnn/adb1c512e09ca2c7a6faef36f9c53e59-v1.0.0a3.tar.gz"
    SHA512 5f2c1a161771efa67e85b1fea395953b7744e29f61187ac5a6c54c912fb195b3aef9a5827135c3668bd0eeea5ae04a33cc433e1f6683e2b7955010a2632d168b
  )
endif()

set(BUILD_opencv_flann OFF)
if("flann" IN_LIST FEATURES)
  set(BUILD_opencv_flann ON)
endif()

set(BUILD_opencv_ovis OFF)
if("ovis" IN_LIST FEATURES)
  set(BUILD_opencv_ovis ON)
endif()

set(BUILD_opencv_sfm OFF)
if("sfm" IN_LIST FEATURES)
  set(BUILD_opencv_sfm ON)
endif()

set(BUILD_opencv_contrib OFF)
if("contrib" IN_LIST FEATURES)
  set(BUILD_opencv_contrib ON)

  # Used for opencv's face module
  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/8afa57abc8229d611c4937165d20e2a2d9fc5a12/face_landmark_model.dat"
    FILENAME "opencv-cache/data/7505c44ca4eb54b4ab1e4777cb96ac05-face_landmark_model.dat"
    SHA512 c16e60a6c4bb4de3ab39b876ae3c3f320ea56f69c93e9303bd2dff8760841dcd71be4161fff8bc71e8fe4fe8747fa8465d49d6bd8f5ebcdaea161f4bc2da7c93
  )

  vcpkg_download_distfile(TINYDNN_ARCHIVE
    URLS "https://github.com/tiny-dnn/tiny-dnn/archive/v1.0.0a3.tar.gz"
    FILENAME "opencv-cache/tiny_dnn/adb1c512e09ca2c7a6faef36f9c53e59-v1.0.0a3.tar.gz"
    SHA512 5f2c1a161771efa67e85b1fea395953b7744e29f61187ac5a6c54c912fb195b3aef9a5827135c3668bd0eeea5ae04a33cc433e1f6683e2b7955010a2632d168b
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

set(WITH_CUDA OFF)
if("cuda" IN_LIST FEATURES)
  set(WITH_CUDA ON)
endif()

set(WITH_FFMPEG OFF)
if("ffmpeg" IN_LIST FEATURES)
  set(WITH_FFMPEG ON)
  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/0a0e88972a7ea97708378d0488a65f83e7cc5e69/ffmpeg/opencv_ffmpeg.dll"
    FILENAME "opencv-cache/ffmpeg/b8120c07962d591e2e9071a1bf566fd0-opencv_ffmpeg.dll"
    SHA512 53325e3bb04de19273270475d7b7d9190c950b0d12e1179feef63c69ba66c9f8593d8ed9b030109dee8c104ab5babea69f18c7cae7366a57d48272d67c00d871
  )
  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/0a0e88972a7ea97708378d0488a65f83e7cc5e69/ffmpeg/opencv_ffmpeg_64.dll"
    FILENAME "opencv-cache/ffmpeg/dc9c50e7b05482acc25d6ce0ac61bf1d-opencv_ffmpeg_64.dll"
    SHA512 7d90df6f5d141f842a45e5678cf1349657612321250ece4ad5c6b5fb28a50140735d91ced0ce1a6e81962ef87236cbd1669c0b4410308f70fccee341a7a5c28b
  )
  vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/0a0e88972a7ea97708378d0488a65f83e7cc5e69/ffmpeg/ffmpeg_version.cmake"
    FILENAME "opencv-cache/ffmpeg/3b90f67f4b429e77d3da36698cef700c-ffmpeg_version.cmake"
    SHA512 7d0142c30ac6f6260c1bcabc22753030fd25a708477fa28053e8df847c366967d3b93a8ac14af19a2b7b73d9f8241749a431458faf21a0c8efc7d6d99eecfdcf
  )
endif()

set(WITH_IPP OFF)
if("ipp" IN_LIST FEATURES)
  set(WITH_IPP ON)

  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    vcpkg_download_distfile(IPPICV_ARCHIVE
        URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/dfe3162c237af211e98b8960018b564bc209261d/ippicv/ippicv_2017u3_win_intel64_general_20170822.zip"
        FILENAME "opencv-cache/ippicv/0421e642bc7ad741a2236d3ec4190bdd-ippicv_2017u3_win_intel64_general_20170822.zip"
        SHA512 1b2b66ac60e5b6ba2fc95a3839d09b7fcfb42628dc6e01648727ee5394f6405702f69f741371627a9e1690294147c730196f1c9872339301c92a1424f159df6c
    )
  else()
    vcpkg_download_distfile(OCV_DOWNLOAD
        URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/dfe3162c237af211e98b8960018b564bc209261d/ippicv/ippicv_2017u3_win_ia32_general_20170822.zip"
        FILENAME "opencv-cache/ippicv/8a7680ae352c192de2e2e34936164bd0-ippicv_2017u3_win_ia32_general_20170822.zip"
        SHA512 6bbe08264b56117d4a00118088d72274396964bb904fb0719fc48beeb458ac31bea3d4d2fa2e0449f55af42471758f2c090c82061c91985c8b7994ed3b71df81
    )
  endif()
endif()

set(WITH_QT OFF)
if("qt" IN_LIST FEATURES)
  set(WITH_QT ON)
endif()

set(WITH_VTK OFF)
if("vtk" IN_LIST FEATURES)
  set(WITH_VTK ON)
endif()

set(WITH_WEBP OFF)
if("webp" IN_LIST FEATURES)
  set(WITH_WEBP ON)
  list(APPEND CMAKE_MODULE_PATH ${CURRENT_INSTALLED_DIR}/share/libwebp)
endif()

set(WITH_GDCM OFF)
if("gdcm" IN_LIST FEATURES)
  set(WITH_GDCM ON)
endif()

set(WITH_OPENGL OFF)
if("opengl" IN_LIST FEATURES)
  set(WITH_OPENGL ON)
endif()

set(WITH_OPENEXR OFF)
if("openexr" IN_LIST FEATURES)
  set(WITH_OPENEXR ON)
  list(APPEND CMAKE_MODULE_PATH ${CURRENT_INSTALLED_DIR}/share/openexr)
endif()

set(WITH_MSMF ON)
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  set(WITH_MSMF OFF)
endif()

set(WITH_TIFF OFF)
if("tiff" IN_LIST FEATURES)
  set(WITH_TIFF ON)
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

if(BUILD_opencv_contrib)
  vcpkg_from_github(
      OUT_SOURCE_PATH CONTRIB_SOURCE_PATH
      REPO opencv/opencv_contrib
      REF ${OPENCV_PORT_VERSION}
      SHA512 431dfba0f413071d7faa18bc6e6f5e4f015285e2cc730c5dd69b2a4d6aa4250b7e0bcb1814ac6f06f5c76f103aea1f93f72f32aee6bc0cd7ddacdaf1f40075c1
      HEAD_REF master
  )
  set(BUILD_WITH_CONTRIB_FLAG "-DOPENCV_EXTRA_MODULES_PATH=${CONTRIB_SOURCE_PATH}/modules")
endif()

set(WITH_ZLIB ON)
set(BUILD_opencv_line_descriptor ON)
set(BUILD_opencv_saliency ON)
set(BUILD_opencv_bgsegm ON)
if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
  set(BUILD_opencv_line_descriptor OFF)
  set(BUILD_opencv_saliency OFF)
  set(BUILD_opencv_bgsegm OFF)
endif()

string(REPLACE ";" "\\\\\;" CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}")

vcpkg_configure_cmake(
    PREFER_NINJA
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        # Ungrouped Entries
        -DOpenCV_DISABLE_ARCH_PATH=ON
        # Do not build docs/examples
        -DBUILD_DOCS=OFF
        -DBUILD_EXAMPLES=OFF
        # Do not build integrated libraries, use external ones whenever possible
        -DBUILD_JASPER=OFF
        -DBUILD_JPEG=OFF
        -DBUILD_OPENEXR=OFF
        -DBUILD_PACKAGE=OFF
        -DBUILD_PERF_TESTS=OFF
        -DBUILD_PNG=OFF
        -DBUILD_PROTOBUF=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_TIFF=OFF
        -DBUILD_WEBP=OFF
        -DBUILD_WITH_DEBUG_INFO=ON
        -DBUILD_WITH_STATIC_CRT=${BUILD_WITH_STATIC_CRT}
        -DBUILD_ZLIB=OFF
        # Select which OpenCV modules should be built
        -DBUILD_opencv_apps=OFF
        -DBUILD_opencv_bgsegm=${BUILD_opencv_bgsegm}
        -DBUILD_opencv_dnn=${BUILD_opencv_dnn}
        -DBUILD_opencv_flann=${BUILD_opencv_flann}
        -DBUILD_opencv_line_descriptor=${BUILD_opencv_line_descriptor}
        -DBUILD_opencv_ovis=${BUILD_opencv_ovis}
        -DBUILD_opencv_python2=OFF
        -DBUILD_opencv_python3=OFF
        -DBUILD_opencv_saliency=${BUILD_opencv_saliency}
        -DBUILD_opencv_sfm=${BUILD_opencv_sfm}
        # PROTOBUF
        -DPROTOBUF_UPDATE_FILES=${PROTOBUF_UPDATE_FILES}
        -DUPDATE_PROTO_FILES=${UPDATE_PROTO_FILES}
        # CMAKE
        -DCMAKE_DISABLE_FIND_PACKAGE_JNI=ON
        "-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}"
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
        -DWITH_EIGEN=${WITH_EIGEN}
        -DWITH_FFMPEG=${WITH_FFMPEG}
        -DWITH_GDCM=${WITH_GDCM}
        -DWITH_IPP=${WITH_IPP}
        -DWITH_JASPER=${WITH_JASPER}
        -DWITH_JPEG=${WITH_JPEG}
        -DWITH_LAPACK=OFF
        -DWITH_MSMF=${WITH_MSMF}
        -DWITH_OPENCLAMDBLAS=OFF
        -DWITH_OPENEXR=${WITH_OPENEXR}
        -DWITH_OPENGL=${WITH_OPENGL}
        -DWITH_PNG=${WITH_PNG}
        -DWITH_PROTOBUF=${WITH_PROTOBUF}
        -DWITH_QT=${WITH_QT}
        -DWITH_TIFF=${WITH_TIFF}
        -DWITH_VTK=${WITH_VTK}
        -DWITH_WEBP=${WITH_WEBP}
        -DWITH_ZLIB=${WITH_ZLIB}
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

set(VCPKG_LIBRARY_LINKAGE "dynamic")

set(VCPKG_POLICY_ALLOW_OBSOLETE_MSVCRT enabled)
