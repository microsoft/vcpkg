include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/opencv/opencv/archive/92387b1ef8fad15196dd5f7fb4931444a68bc93a.zip"
    FILENAME "opencv-92387b1ef8fad15196dd5f7fb4931444a68bc93a.zip"
    SHA512 b95fa1a5bce0ea9e9bd43173b904e5d779a2f640f4f8dbb36a12df462e8e4cdce3ff94b2fbd85cb96ddf338019f9888e9e7410c468c81b1de98d9c1da945a7eb
)
vcpkg_extract_source_archive(${ARCHIVE})

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/opencv-92387b1ef8fad15196dd5f7fb4931444a68bc93a)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/opencv-installation-options.patch"
)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_ZLIB=OFF
        -DINSTALL_CREATE_DISTRIB=ON
        -DBUILD_opencv_python2=OFF
        -DBUILD_opencv_python3=OFF
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
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
        -DINSTALL_OTHER=OFF
)

# vcpkg_build_cmake()
vcpkg_install_cmake()

file(READ ${CURRENT_PACKAGES_DIR}/debug/share/opencv/OpenCVModules-debug.cmake OPENCV_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" OPENCV_DEBUG_MODULE "${OPENCV_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVModules-debug.cmake "${OPENCV_DEBUG_MODULE}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/opencv)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/opencv/LICENSE ${CURRENT_PACKAGES_DIR}/share/opencv/copyright)
vcpkg_copy_pdbs()
