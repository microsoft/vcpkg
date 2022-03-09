
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stevenlovegrove/Pangolin
    REF dd801d244db3a8e27b7fe8020cd751404aa818fd #v0.6
    SHA512 8004ab6f146f319df41e4b8d4bdb6677b8faf6db725e34fea76fcbf065522fa286d334c2426dcb39faf0cfb3332946104f78393d2b2b2418fe02d91450916e78
    HEAD_REF master
    PATCHES
        fix-includepath-error.patch # include path has one more ../
        fix-cmake-version.patch
        fix-build-error-in-vs2019.patch
        fix-dependencies.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        test        BUILD_TESTS
        tools       BUILD_TOOLS
        examples    BUILD_EXAMPLES
        gui         BUILD_PANGOLIN_GUI
        vars        BUILD_PANGOLIN_VARS
        video       BUILD_PANGOLIN_VIDEO
        pybind11    BUILD_PANGOLIN_PYTHON
        eigen       BUILD_PANGOLIN_EIGEN
        ffmpeg      BUILD_PANGOLIN_FFMPEG
        realsense   BUILD_PANGOLIN_LIBREALSENSE2
        openni2     BUILD_PANGOLIN_OPENNI2
        uvc         BUILD_PANGOLIN_LIBUVC
        png         BUILD_PANGOLIN_LIBPNG
        jpeg        BUILD_PANGOLIN_LIBJPEG
        tiff        BUILD_PANGOLIN_LIBTIFF
        openexr     BUILD_PANGOLIN_LIBOPENEXR
        zstd        BUILD_PANGOLIN_ZSTD
        lz4         BUILD_PANGOLIN_LZ4
        module      BUILD_PYPANGOLIN_MODULE
)

file(REMOVE "${SOURCE_PATH}/CMakeModules/FindGLEW.cmake")
file(REMOVE "${SOURCE_PATH}/CMakeModules/FindFFMPEG.cmake")

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" MSVC_USE_STATIC_CRT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DBUILD_EXTERN_GLEW=OFF
        -DBUILD_EXTERN_LIBPNG=OFF
        -DBUILD_EXTERN_LIBJPEG=OFF
        -DBUILD_PANGOLIN_PLEORA=OFF
        -DBUILD_PANGOLIN_TELICAM=OFF
        -DBUILD_PANGOLIN_DEPTHSENSE=OFF
        -DBUILD_PANGOLIN_OPENNI=OFF
        -DBUILD_PANGOLIN_UVC_MEDIAFOUNDATION=OFF
        -DBUILD_PANGOLIN_LIBREALSENSE=OFF
        -DBUILD_PANGOLIN_V4L=OFF
        -DBUILD_PANGOLIN_LIBDC1394=OFF
        -DBUILD_PANGOLIN_TOON=OFF
        -DDISPLAY_WAYLAND=OFF
        -DDISPLAY_X11=OFF
        -DBUILD_FOR_GLES_2=OFF
        -DMSVC_USE_STATIC_CRT=${MSVC_USE_STATIC_CRT}
    MAYBE_UNUSED_VARIABLES
        MSVC_USE_STATIC_CRT
        BUILD_FOR_GLES_2
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Pangolin)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/pangolin/PangolinConfig.cmake" "SET( Pangolin_CMAKEMODULES ${SOURCE_PATH}/src/../CMakeModules )" "")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES Plotter VideoConvert VideoJsonPrint VideoJsonTransform VideoViewer AUTO_CLEAN)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    # Copy missing header file
    file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src/include/pangolin/pangolin_export.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/pangolin")
endif()

# Put the license file where vcpkg expects it
file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENCE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)