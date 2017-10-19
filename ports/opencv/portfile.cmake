include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO opencv/opencv
    REF 3.3.0
    SHA512 13dee5c1c5fec1dccdbb05879d299b93ef8ddeb87f561a6c4178e33a4cf5ae919765119068d0387a3efea0e09a625ca993cffac60a772159690fcbee4e8d70fb
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/opencv-installation-options.patch"
            "${CMAKE_CURRENT_LIST_DIR}/001-fix-uwp.patch"
            "${CMAKE_CURRENT_LIST_DIR}/002-fix-uwp.patch"
)
file(REMOVE_RECURSE ${SOURCE_PATH}/3rdparty/libjpeg ${SOURCE_PATH}/3rdparty/libpng ${SOURCE_PATH}/3rdparty/zlib ${SOURCE_PATH}/3rdparty/libtiff)

vcpkg_from_github(
    OUT_SOURCE_PATH CONTRIB_SOURCE_PATH
    REPO opencv/opencv_contrib
    REF 3.3.0
    SHA512 ebe3dbe6c754c6fbaabbf6b0d2a4209964e625fd68e593f30ce043792740c8c1d4440d7870949b5b33f488fd7e2e05f3752287b7f50dd24c29202e268776520e
    HEAD_REF master
)

vcpkg_apply_patches(
   SOURCE_PATH ${CONTRIB_SOURCE_PATH}
   PATCHES "${CMAKE_CURRENT_LIST_DIR}/open_contrib-remove-waldboost.patch"
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" BUILD_WITH_STATIC_CRT)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        "-DOPENCV_DOWNLOAD_PATH=${DOWNLOADS}/opencv-cache"
        -DBUILD_WITH_STATIC_CRT=${BUILD_WITH_STATIC_CRT}
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
        -DWITH_FFMPEG=ON
        -DINSTALL_FORCE_UNIX_PATHS=ON
        -DOPENCV_CONFIG_INSTALL_PATH=share/opencv
        -DOPENCV_OTHER_INSTALL_PATH=share/opencv
        -DINSTALL_LICENSE=OFF
        # Optional: change to ON to build with CUDA
        -DWITH_CUDA=OFF
        -DWITH_CUBLAS=OFF
        -DWITH_OPENCLAMDBLAS=OFF
        -DWITH_LAPACK=OFF
        -DBUILD_opencv_dnn=ON
        -DOPENCV_EXTRA_MODULES_PATH=${CONTRIB_SOURCE_PATH}/modules
        -DBUILD_PROTOBUF=OFF
        -DUPDATE_PROTO_FILES=ON
        -DPROTOBUF_UPDATE_FILES=ON
        # Optional: change to ON to build with VTK
        -DWITH_VTK=OFF
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
string(REPLACE " vc15"
               " ${OpenCV_RUNTIME}" OPENCV_CONFIG "${OPENCV_CONFIG}")
string(REPLACE " vc14"
               " ${OpenCV_RUNTIME}" OPENCV_CONFIG "${OPENCV_CONFIG}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVConfig.cmake "${OPENCV_CONFIG}")

if(EXISTS "${CURRENT_PACKAGES_DIR}/share/opencv/${OpenCV_ARCH}/${OpenCV_RUNTIME}/staticlib")
  file(RENAME ${CURRENT_PACKAGES_DIR}/share/opencv/${OpenCV_ARCH}/${OpenCV_RUNTIME}/staticlib ${CURRENT_PACKAGES_DIR}/share/opencv/${OpenCV_ARCH}/${OpenCV_RUNTIME}/lib)
endif()
file(READ ${CURRENT_PACKAGES_DIR}/share/opencv/${OpenCV_ARCH}/${OpenCV_RUNTIME}/lib/OpenCVModules-release.cmake OPENCV_CONFIG_LIB)
string(REPLACE "/staticlib/"
               "/lib/" OPENCV_CONFIG_LIB "${OPENCV_CONFIG_LIB}")
string(REPLACE "/${OpenCV_ARCH}/${OpenCV_RUNTIME}/"
               "/" OPENCV_CONFIG_LIB "${OPENCV_CONFIG_LIB}")
string(REPLACE "${CURRENT_INSTALLED_DIR}"
               "\${_IMPORT_PREFIX}" OPENCV_CONFIG_LIB "${OPENCV_CONFIG_LIB}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/opencv/${OpenCV_ARCH}/${OpenCV_RUNTIME}/lib/OpenCVModules-release.cmake "${OPENCV_CONFIG_LIB}")

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/share/opencv/${OpenCV_ARCH}/${OpenCV_RUNTIME}/staticlib")
  file(RENAME ${CURRENT_PACKAGES_DIR}/debug/share/opencv/${OpenCV_ARCH}/${OpenCV_RUNTIME}/staticlib ${CURRENT_PACKAGES_DIR}/debug/share/opencv/${OpenCV_ARCH}/${OpenCV_RUNTIME}/lib)
endif()
file(READ ${CURRENT_PACKAGES_DIR}/debug/share/opencv/${OpenCV_ARCH}/${OpenCV_RUNTIME}/lib/OpenCVModules-debug.cmake OPENCV_CONFIG_LIB)
string(REPLACE "/staticlib/"
               "/lib/" OPENCV_CONFIG_LIB "${OPENCV_CONFIG_LIB}")
string(REPLACE "/${OpenCV_ARCH}/${OpenCV_RUNTIME}/"
               "/" OPENCV_CONFIG_LIB "${OPENCV_CONFIG_LIB}")
string(REPLACE "PREFIX}/lib"
               "PREFIX}/debug/lib" OPENCV_CONFIG_LIB "${OPENCV_CONFIG_LIB}")
string(REPLACE "PREFIX}/bin"
               "PREFIX}/debug/bin" OPENCV_CONFIG_LIB "${OPENCV_CONFIG_LIB}")
string(REPLACE "${CURRENT_INSTALLED_DIR}"
               "\${_IMPORT_PREFIX}" OPENCV_CONFIG_LIB "${OPENCV_CONFIG_LIB}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/opencv/${OpenCV_ARCH}/${OpenCV_RUNTIME}/lib/OpenCVModules-debug.cmake "${OPENCV_CONFIG_LIB}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

set(VCPKG_LIBRARY_LINKAGE "dynamic")