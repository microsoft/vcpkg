
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stevenlovegrove/Pangolin
    REF "v${VERSION}"
    SHA512 ef2461770def3b0752d23df0c9a0090b733943249404528d0b2ba985d08c9083aabe685e3fd00be08318ea7b90dc38e9735ab004124643619e6cf369d64f6321
    HEAD_REF master
    PATCHES
        devendor-palsigslot.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        test        BUILD_TESTS
        tools       BUILD_TOOLS
        examples    BUILD_EXAMPLES
        pybind11    BUILD_PANGOLIN_PYTHON
        ffmpeg      BUILD_PANGOLIN_FFMPEG
        realsense   BUILD_PANGOLIN_REALSENSE2
        openni2     BUILD_PANGOLIN_OPENNI2
        uvc         BUILD_PANGOLIN_LIBUVC
        png         BUILD_PANGOLIN_LIBPNG
        jpeg        BUILD_PANGOLIN_LIBJPEG
        tiff        BUILD_PANGOLIN_LIBTIFF
        openexr     BUILD_PANGOLIN_LIBOPENEXR
        zstd        BUILD_PANGOLIN_ZSTD
        lz4         BUILD_PANGOLIN_LZ4
)

file(REMOVE "${SOURCE_PATH}/CMakeModules/FindGLEW.cmake")
file(REMOVE "${SOURCE_PATH}/CMakeModules/FindFFMPEG.cmake")
file(REMOVE_RECURSE "${SOURCE_PATH}/components/pango_core/include/sigslot")

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" MSVC_USE_STATIC_CRT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DBUILD_PANGOLIN_PLEORA=OFF
        -DBUILD_PANGOLIN_TELICAM=OFF
        -DBUILD_PANGOLIN_DEPTHSENSE=OFF
        -DBUILD_PANGOLIN_OPENNI=OFF
        -DBUILD_PANGOLIN_UVC_MEDIAFOUNDATION=OFF
        -DBUILD_PANGOLIN_REALSENSE=OFF
        -DBUILD_PANGOLIN_V4L=OFF
        -DBUILD_PANGOLIN_LIBDC1394=OFF
        -DBUILD_FOR_GLES_2=OFF
        -DBUILD_PANGOLIN_LIBRAW=OFF
        -DMSVC_USE_STATIC_CRT=${MSVC_USE_STATIC_CRT}
    MAYBE_UNUSED_VARIABLES
        MSVC_USE_STATIC_CRT
        BUILD_FOR_GLES_2
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Pangolin)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/pangolin/PangolinConfig.cmake" "Pangolin_CMAKEMODULES ${SOURCE_PATH}/" "Pangolin_CMAKEMODULES \${CMAKE_CURRENT_LIST_DIR}/")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES Plotter VideoConvert VideoJsonPrint VideoJsonTransform VideoViewer AUTO_CLEAN)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Put the license file where vcpkg expects it
file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENCE")