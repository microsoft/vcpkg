if (EXISTS "${CURRENT_INSTALLED_DIR}/share/opencv4")
  message(FATAL_ERROR "OpenCV 4 is installed, please uninstall and try again:\n    vcpkg remove opencv4")
endif()

include(vcpkg_common_functions)

set(OPENCV_PORT_VERSION "3.4.7")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO opencv/opencv
    REF ${OPENCV_PORT_VERSION}
    SHA512 d653a58eb5e3939b9fdb7438ac35f77cf4385cf72d5d22bfd21722a109e1b3283dbb9407985061b7548114f0d05c9395aac9bb62b4d2bc1f68da770a49987fef
    HEAD_REF master
    PATCHES
      0001-winrt-fixes.patch
      0002-install-options.patch
      0003-disable-downloading.patch
      0004-use-find-package-required.patch
      0005-remove-custom-protobuf-find-package.patch
      0006-fix-missing-openjp2.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" BUILD_WITH_STATIC_CRT)

vcpkg_check_features(
 "contrib"  WITH_CONTRIB
 "cuda"     WITH_CUDA
 "dnn"      BUILD_opencv_dnn
 "eigen"    WITH_EIGEN
 "ffmpeg"   WITH_FFMPEG
 "flann"    BUILD_opencv_flann
 "gdcm"     WITH_GDCM
 "halide"   WITH_HALIDE
 "ipp"      WITH_IPP
 "jasper"   WITH_JASPER
 "jpeg"     WITH_JPEG
 "nonfree"  OPENCV_ENABLE_NONFREE
 "openexr"  WITH_OPENEXR
 "opengl"   WITH_OPENGL
 "ovis"     BUILD_opencv_ovis
 "png"      WITH_PNG
 "qt"       WITH_QT
 "sfm"      BUILD_opencv_sfm
 "tbb"      WITH_TBB
 "tiff"     WITH_TIFF
 "vtk"      WITH_VTK
 "webp"     WITH_WEBP
 "world"    BUILD_opencv_world
)

if(BUILD_opencv_dnn)
  vcpkg_download_distfile(TINYDNN_ARCHIVE
    URLS "https://github.com/tiny-dnn/tiny-dnn/archive/v1.0.0a3.tar.gz"
    FILENAME "opencv-cache/tiny_dnn/adb1c512e09ca2c7a6faef36f9c53e59-v1.0.0a3.tar.gz"
    SHA512 5f2c1a161771efa67e85b1fea395953b7744e29f61187ac5a6c54c912fb195b3aef9a5827135c3668bd0eeea5ae04a33cc433e1f6683e2b7955010a2632d168b
  )
endif()

if(WITH_CONTRIB)
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



if(WITH_IPP)
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    vcpkg_download_distfile(OCV_DOWNLOAD
      URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/bdb7bb85f34a8cb0d35e40a81f58da431aa1557a/ippicv/ippicv_2017u3_win_intel64_general_20180518.zip"
      FILENAME "opencv-cache/ippicv/915ff92958089ede8ea532d3c4fe7187-ippicv_2017u3_win_intel64_general_20180518.zip"
      SHA512 8aa08292d542d521c042864446e47a7a6bdbf3896d86fc7b43255459c24a2e9f34a4e9b177023d178fed7a2e82a9db410f89d81375a542d049785d263f46c64d
    )
  else()
    vcpkg_download_distfile(OCV_DOWNLOAD
      URLS "https://raw.githubusercontent.com/opencv/opencv_3rdparty/bdb7bb85f34a8cb0d35e40a81f58da431aa1557a/ippicv/ippicv_2017u3_win_ia32_general_20180518.zip"
      FILENAME "opencv-cache/ippicv/928168c2d99ab284047dfcfb7a821d91-ippicv_2017u3_win_ia32_general_20180518.zip"
      SHA512 b89b0fb739152303cafc9fb064fa8b24fd94850697137ccbb5c1e344e0f5094115603a5e3be3a25f85d0faefc5c53429a7d65da0142d012ada41e8db2bcdd6b7
    )
  endif()
endif()

set(WITH_MSMF ON)
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  set(WITH_MSMF OFF)
endif()

if(BUILD_opencv_contrib)
  vcpkg_from_github(
      OUT_SOURCE_PATH CONTRIB_SOURCE_PATH
      REPO opencv/opencv_contrib
      REF ${OPENCV_PORT_VERSION}
      SHA512 456c6f878fb3bd5459f6430405cf05c609431f8d7db743aa699fc75c305d019682ee3a804bf0cf5107597dd1dbbb69b08be3535a0e6c717e4773ed7c05d08e59
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
if (VCPKG_TARGET_IS_UWP)
  set(BUILD_opencv_quality OFF)
endif()

vcpkg_configure_cmake(
    PREFER_NINJA
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ###### ocv_options
        -DOpenCV_INSTALL_BINARIES_PREFIX=
        -DOPENCV_LIB_INSTALL_PATH=lib
        -DOPENCV_3P_LIB_INSTALL_PATH=lib
        -DOPENCV_CONFIG_INSTALL_PATH=share/opencv
        -DOPENCV_FFMPEG_USE_FIND_PACKAGE=FFMPEG
        -DCMAKE_DEBUG_POSTFIX=d
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
        -DBUILD_opencv_world=${BUILD_opencv_world}
        # PROTOBUF
        -DPROTOBUF_UPDATE_FILES=ON
        -DUPDATE_PROTO_FILES=ON
        -DWITH_PROTOBUF=ON
        # CMAKE
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_JNI=ON
        # ENABLE
        -DENABLE_CXX11=ON
        -DENABLE_PYLINT=OFF
        -DOPENCV_ENABLE_NONFREE=${OPENCV_ENABLE_NONFREE}
        # INSTALL
        -DINSTALL_FORCE_UNIX_PATHS=ON
        -DINSTALL_LICENSE=OFF
        # OPENCV
        -DOPENCV_CONFIG_INSTALL_PATH=share/opencv
        -DOPENCV_OTHER_INSTALL_PATH=share/opencv
        "-DOPENCV_DOWNLOAD_PATH=${DOWNLOADS}/opencv-cache"
        ${BUILD_WITH_CONTRIB_FLAG}
        -DOPENCV_OTHER_INSTALL_PATH=share/opencv
        # WITH
        -DWITH_CUBLAS=${WITH_CUDA}
        -DWITH_CUDA=${WITH_CUDA}
        -DWITH_EIGEN=${WITH_EIGEN}
        -DWITH_FFMPEG=${WITH_FFMPEG}
        -DWITH_GDCM=${WITH_GDCM}
        -DWITH_HALIDE=${WITH_HALIDE}
        -DWITH_IPP=${WITH_IPP}
        -DWITH_JASPER=${WITH_JASPER}
        -DWITH_JPEG=${WITH_JPEG}
        -DWITH_LAPACK=OFF
        -DWITH_MATLAB=OFF
        -DWITH_MSMF=${WITH_MSMF}
        -DWITH_OPENCLAMDBLAS=OFF
        -DWITH_OPENEXR=${WITH_OPENEXR}
        -DWITH_OPENGL=${WITH_OPENGL}
        -DWITH_PNG=${WITH_PNG}
        -DWITH_QT=${WITH_QT}
        -DWITH_TBB=${WITH_TBB}
        -DWITH_TIFF=${WITH_TIFF}
        -DWITH_VTK=${WITH_VTK}
        -DWITH_WEBP=${WITH_WEBP}
        -DWITH_ZLIB=${WITH_ZLIB}
        -DCURRENT_INSTALLED_DIR=${CURRENT_INSTALLED_DIR}
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
        -DINSTALL_OTHER=OFF
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
find_package(TIFF QUIET)
find_package(HDF5 QUIET)
find_package(Freetype QUIET)
find_package(Ogre QUIET)
find_package(gflags QUIET)
find_package(Ceres QUIET)
find_package(ade QUIET)
find_package(VTK QUIET)
find_package(OpenMP QUIET)
find_package(GDCM QUIET)" OPENCV_MODULES "${OPENCV_MODULES}")

  file(WRITE ${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVModules.cmake "${OPENCV_MODULES}")

  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE ${CURRENT_PACKAGES_DIR}/setup_vars_opencv3.cmd)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/setup_vars_opencv3.cmd)
file(REMOVE ${CURRENT_PACKAGES_DIR}/LICENSE)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/LICENSE)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/opencv3 RENAME copyright)
