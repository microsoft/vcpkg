if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/opencv-3.2.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/opencv/opencv/archive/3.2.0.zip"
    FILENAME "opencv-3.2.0.zip"
    SHA512 c6418d2a7654fe9d50611e756778df4c6736f2de76b85773efbf490bb475dd95ec1041fe57a87163ce11a7db44430cd378c8416af3319f979ced92532bf5ebb5
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
#SET(CONTRIB_SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/opencv_contrib-3.2.0)
#vcpkg_download_distfile(CONTRIB_ARCHIVE
#    URLS "https://github.com/opencv/opencv_contrib/archive/3.2.0.zip"
#    FILENAME "opencv_contrib-3.2.0.zip"
#    SHA512 da6cda7a7ae1d722967e18f9b8d60895b93bbc3664dfdb1645cb4d8b337a9c4207b9073fd546a596c48a489f92d15191aa34c7c607167b536fbe4937b8424b43
#)
#vcpkg_extract_source_archive(${CONTRIB_ARCHIVE})
#vcpkg_apply_patches(
#    SOURCE_PATH ${CONTRIB_SOURCE_PATH}
#    PATCHES "${CMAKE_CURRENT_LIST_DIR}/open_contrib-remove-waldboost.patch"
#)

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

        # uncomment the following 3 lines to build opencv_contrib modules
        #-DOPENCV_EXTRA_MODULES_PATH=${CONTRIB_SOURCE_PATH}/modules
        #-DBUILD_PROTOBUF=OFF
        #-DUPDATE_PROTO_FILES=ON
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
        -DINSTALL_OTHER=OFF
)

vcpkg_install_cmake()

file(READ ${CURRENT_PACKAGES_DIR}/debug/share/opencv/OpenCVModules-debug.cmake OPENCV_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" OPENCV_DEBUG_MODULE "${OPENCV_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVModules-debug.cmake "${OPENCV_DEBUG_MODULE}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/opencv)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/opencv/LICENSE ${CURRENT_PACKAGES_DIR}/share/opencv/copyright)

vcpkg_copy_pdbs()
