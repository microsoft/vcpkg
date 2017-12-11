include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO opencv/opencv
    REF 3.3.1
    SHA512 ee228953b621be022c203e3d60b06be524bd134ba6188c447216ee89e14dfddeac7d6aaf85c5a0b0008b010254e2aa711813bfdb691a77b0bdba33682c6ca68c
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/opencv-installation-options.patch"
            "${CMAKE_CURRENT_LIST_DIR}/001-fix-uwp.patch"
            "${CMAKE_CURRENT_LIST_DIR}/002-fix-uwp.patch"
            "${CMAKE_CURRENT_LIST_DIR}/no-double-expand-enable-pylint.patch"
            "${CMAKE_CURRENT_LIST_DIR}/msvs-fix-2017-u5.patch"
)
file(REMOVE_RECURSE ${SOURCE_PATH}/3rdparty/libjpeg ${SOURCE_PATH}/3rdparty/libpng ${SOURCE_PATH}/3rdparty/zlib ${SOURCE_PATH}/3rdparty/libtiff)

vcpkg_from_github(
    OUT_SOURCE_PATH CONTRIB_SOURCE_PATH
    REPO opencv/opencv_contrib
    REF 3.3.1
    SHA512 b5f35f68faab811a440b6af6b33c766dcdf4cc8547c0a4ed3a6a3da80ca8ae77618039d94bee6d249e96899765bdbb34c997bd7ee53d864c43427eff92f7ea34
    HEAD_REF master
)

vcpkg_apply_patches(
   SOURCE_PATH ${CONTRIB_SOURCE_PATH}
   PATCHES "${CMAKE_CURRENT_LIST_DIR}/open_contrib-remove-waldboost.patch"
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" BUILD_WITH_STATIC_CRT)

set(BUILD_opencv_sfm OFF)
if("sfm" IN_LIST FEATURES)
  set(BUILD_opencv_sfm ON)
endif()

set(WITH_CUDA OFF)
if("cuda" IN_LIST FEATURES)
  set(WITH_CUDA ON)
endif()

set(WITH_FFMPEG OFF)
if("ffmpeg" IN_LIST FEATURES)
  set(WITH_FFMPEG ON)
endif()

set(WITH_QT OFF)
if("qt" IN_LIST FEATURES)
  set(WITH_QT ON)
endif()

set(WITH_VTK OFF)
if("vtk" IN_LIST FEATURES)
  set(WITH_VTK ON)
endif()

set(WITH_GDCM OFF)
if("gdcm" IN_LIST FEATURES)
  set(WITH_GDCM ON)
endif()

set(WITH_MSMF ON)
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  set(WITH_MSMF OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        # Ungrouped Entries
        -DOpenCV_DISABLE_ARCH_PATH=ON
        -DPROTOBUF_UPDATE_FILES=ON
        -DUPDATE_PROTO_FILES=ON
        # BUILD
        -DBUILD_DOCS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_JPEG=OFF
        -DBUILD_PACKAGE=OFF
        -DBUILD_PERF_TESTS=OFF
        -DBUILD_PNG=OFF
        -DBUILD_PROTOBUF=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_TIFF=OFF
        -DBUILD_WITH_DEBUG_INFO=ON
        -DBUILD_WITH_STATIC_CRT=${BUILD_WITH_STATIC_CRT}
        -DBUILD_ZLIB=OFF
        -DBUILD_opencv_apps=OFF
        -DBUILD_opencv_dnn=ON
        -DBUILD_opencv_flann=ON
        -DBUILD_opencv_python2=OFF
        -DBUILD_opencv_python3=OFF
        -DBUILD_opencv_sfm=${BUILD_opencv_sfm}
        # CMAKE
        -DCMAKE_DISABLE_FIND_PACKAGE_JNI=ON
        # ENABLE
        -DENABLE_CXX11=ON
        -DENABLE_PYLINT=OFF
        # INSTALL
        -DINSTALL_FORCE_UNIX_PATHS=ON
        -DINSTALL_LICENSE=OFF
        # OPENCV
        -DOPENCV_CONFIG_INSTALL_PATH=share/opencv
        "-DOPENCV_DOWNLOAD_PATH=${DOWNLOADS}/opencv-cache"
        -DOPENCV_EXTRA_MODULES_PATH=${CONTRIB_SOURCE_PATH}/modules
        -DOPENCV_OTHER_INSTALL_PATH=share/opencv
        # WITH
        -DWITH_CUBLAS=OFF
        -DWITH_CUDA=${WITH_CUDA}
        -DWITH_FFMPEG=${WITH_FFMPEG}
        -DWITH_LAPACK=OFF
        -DWITH_MSMF=${WITH_MSMF}
        -DWITH_OPENCLAMDBLAS=OFF
        -DWITH_OPENGL=ON
        -DWITH_QT=${WITH_QT}
        -DWITH_VTK=${WITH_VTK}
        -DWITH_GDCM=${WITH_GDCM}
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

set(VCPKG_POLICY_ALLOW_OBSOLETE_MSVCRT enabled)
