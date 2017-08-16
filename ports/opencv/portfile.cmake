if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/opencv-3.3.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/opencv/opencv/archive/3.3.0.zip"
    FILENAME "opencv-3.3.0.zip"
    SHA512 14430c6225926e5118daccb57c7276d9f9160c90a034b2c73a09b73ac90ba7ebd3ae78cccffb4a10b58bb0e5e16ebd03bf617030fa74cc67d9d18366bf6b4951
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/opencv-installation-options.patch"
            "${CMAKE_CURRENT_LIST_DIR}/001-fix-uwp.patch"
            "${CMAKE_CURRENT_LIST_DIR}/002-fix-uwp.patch"
)
file(REMOVE_RECURSE ${SOURCE_PATH}/3rdparty/libjpeg ${SOURCE_PATH}/3rdparty/libpng ${SOURCE_PATH}/3rdparty/zlib ${SOURCE_PATH}/3rdparty/libtiff)

# Uncomment the following lines and the lines under OPTIONS to build opencv_contrib
# Important: after uncommenting you've add protobuf dependency within CONTROL file
SET(CONTRIB_SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/opencv_contrib-3.3.0)
vcpkg_download_distfile(CONTRIB_ARCHIVE
   URLS "https://github.com/opencv/opencv_contrib/archive/3.3.0.zip"
   FILENAME "opencv_contrib-3.3.0.zip"
   SHA512 1c76d49689459708117acfbd0893cbfb915fbd0defff95702fb388a29d12b50fb53fbf246e64e68aa3adb347aa45ff478df5e2e8c6d9cfa57a628744bbb1bd04
)
vcpkg_extract_source_archive(${CONTRIB_ARCHIVE})
vcpkg_apply_patches(
   SOURCE_PATH ${CONTRIB_SOURCE_PATH}
   PATCHES "${CMAKE_CURRENT_LIST_DIR}/open_contrib-remove-waldboost.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_ZLIB=OFF
        -DBUILD_TIFF=OFF
        -DBUILD_JPEG=OFF
        -DBUILD_PNG=OFF
        -DBUILD_opencv_python2=OFF
        -DBUILD_opencv_python3=OFF
        -DBUILD_opencv_flann=ON
        -DBUILD_opencv_apps=OFF
        -DBUILD_DOCS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_PACKAGE=OFF
        -DBUILD_PERF_TESTS=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_WITH_DEBUG_INFO=ON
        -DOpenCV_DISABLE_ARCH_PATH=ON
        -DWITH_FFMPEG=OFF
        -DINSTALL_FORCE_UNIX_PATHS=ON
        -DOPENCV_CONFIG_INSTALL_PATH=share/opencv
        -DOPENCV_OTHER_INSTALL_PATH=share/opencv
        -DINSTALL_LICENSE=OFF
        -DWITH_CUDA=OFF
        -DWITH_CUBLAS=OFF
        -DWITH_OPENCLAMDBLAS=OFF
        -DWITH_LAPACK=OFF
        -DBUILD_opencv_dnn=OFF

        # uncomment the following 3 lines to build opencv_contrib modules
        -DOPENCV_EXTRA_MODULES_PATH=${CONTRIB_SOURCE_PATH}/modules
        -DBUILD_PROTOBUF=OFF
        -DUPDATE_PROTO_FILES=ON
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
        -DINSTALL_OTHER=OFF
)

vcpkg_install_cmake()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/opencv)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/opencv/LICENSE ${CURRENT_PACKAGES_DIR}/share/opencv/copyright)
file(REMOVE ${CURRENT_PACKAGES_DIR}/LICENSE)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/LICENSE)

if(${VCPKG_PLATFORM_TOOLSET} STREQUAL "v150")
  set(OpenCV_RUNTIME vc15)
else()
  set(OpenCV_RUNTIME vc14)
endif()
if(${VCPKG_TARGET_ARCHITECTURE} STREQUAL "x64")
  set(OpenCV_ARCH x64)
else()
  set(OpenCV_ARCH x86)
endif()

file(GLOB BIN_AND_LIB ${CURRENT_PACKAGES_DIR}/${OpenCV_ARCH}/${OpenCV_RUNTIME}/*)
file(COPY ${BIN_AND_LIB} DESTINATION ${CURRENT_PACKAGES_DIR})
file(GLOB DEBUG_BIN_AND_LIB ${CURRENT_PACKAGES_DIR}/debug/${OpenCV_ARCH}/${OpenCV_RUNTIME}/*)
file(COPY ${DEBUG_BIN_AND_LIB} DESTINATION ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/${OpenCV_ARCH})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/${OpenCV_ARCH})

file(GLOB SHARE_LIB ${CURRENT_PACKAGES_DIR}/share/opencv/${OpenCV_ARCH}/${OpenCV_RUNTIME}/*)
file(COPY ${SHARE_LIB} DESTINATION ${CURRENT_PACKAGES_DIR}/share/opencv)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/opencv/${OpenCV_ARCH})

file(READ ${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVConfig.cmake OPENCV_CONFIG)
string(REPLACE "\${OpenCV_ARCH}/\${OpenCV_RUNTIME}/"
               "" OPENCV_CONFIG "${OPENCV_CONFIG}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVConfig.cmake "${OPENCV_CONFIG}")

file(READ ${CURRENT_PACKAGES_DIR}/share/opencv/lib/OpenCVConfig.cmake OPENCV_CONFIG_LIB)
string(REPLACE "get_filename_component(OpenCV_INSTALL_PATH \"\${OpenCV_CONFIG_PATH}/../../../../../"
               "get_filename_component(OpenCV_INSTALL_PATH \"\${OpenCV_CONFIG_PATH}/../../../" OPENCV_CONFIG_LIB "${OPENCV_CONFIG_LIB}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/opencv/lib/OpenCVConfig.cmake "${OPENCV_CONFIG_LIB}")

file(READ ${CURRENT_PACKAGES_DIR}/share/opencv/lib/OpenCVModules.cmake OPENCV_MODULES)
string(REPLACE "get_filename_component(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\n"
               "get_filename_component(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)\n" OPENCV_MODULES "${OPENCV_MODULES}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/opencv/lib/OpenCVModules.cmake "${OPENCV_MODULES}")

file(READ ${CURRENT_PACKAGES_DIR}/share/opencv/lib/OpenCVModules-release.cmake OPENCV_MODULES_RELEASE)
string(REPLACE "${OpenCV_ARCH}/${OpenCV_RUNTIME}/"
               "" OPENCV_MODULES_RELEASE "${OPENCV_MODULES_RELEASE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/opencv/lib/OpenCVModules-release.cmake "${OPENCV_MODULES_RELEASE}")

file(READ ${CURRENT_PACKAGES_DIR}/debug/share/opencv/${OpenCV_ARCH}/${OpenCV_RUNTIME}/lib/OpenCVModules-debug.cmake OPENCV_MODULES_DEBUG)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" OPENCV_MODULES_DEBUG "${OPENCV_MODULES_DEBUG}")
string(REPLACE "${OpenCV_ARCH}/${OpenCV_RUNTIME}/"
               "" OPENCV_MODULES_DEBUG "${OPENCV_MODULES_DEBUG}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/opencv/lib/OpenCVModules-debug.cmake "${OPENCV_MODULES_DEBUG}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()
