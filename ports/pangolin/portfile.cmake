vcpkg_fail_port_install(ON_TARGET "UWP")

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
        fix-dependency-python.patch
        add-definition.patch
        fix-cmake-version.patch
        fix-build-error-in-vs2019.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        test     BUILD_TESTS
        tools    BUILD_TOOLS
        examples BUILD_EXAMPLES
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
        -DCMAKE_DISABLE_FIND_PACKAGE_TooN=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_DC1394=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_LibRealSense=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenNI=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenNI2=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_uvc=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_DepthSense=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_TeliCam=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Pleora=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_TIFF=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenEXR=ON
        -DMSVC_USE_STATIC_CRT=${MSVC_USE_STATIC_CRT}
    MAYBE_UNUSED_VARIABLES
        MSVC_USE_STATIC_CRT
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Pangolin)

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