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

# Comment out the following 11 lines if you don't want to build with opencv_contrib
# Important: remember to also update the CONTROL file
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

        # comment the following 3 lines if you don't want to build opencv_contrib modules
        -DOPENCV_EXTRA_MODULES_PATH=${CONTRIB_SOURCE_PATH}/modules
        -DBUILD_PROTOBUF=OFF
        -DUPDATE_PROTO_FILES=ON
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
        -DINSTALL_OTHER=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/opencv)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/opencv/LICENSE ${CURRENT_PACKAGES_DIR}/share/opencv/copyright)
file(REMOVE ${CURRENT_PACKAGES_DIR}/LICENSE)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/LICENSE)

vcpkg_copy_pdbs()
