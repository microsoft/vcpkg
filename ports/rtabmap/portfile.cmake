vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO introlab/rtabmap
    # rtabmap stops releasing, check their CMakeLists.txt for version.
    # currently is 0.21.0
    REF 46edd15121b5efc607f3141e61e54171c48b791b
    SHA512 cfc83a9982fee261dbcf65a694b72a0f7ed2afdce1a0c16636822b047ab8a983464d40c5624a343fd361da95d5635a53ec8edc86eca3af5d44db2afba9599b61
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_TOOLS
        tools BUILD_APP
        gui WITH_QT
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_AS_BUNDLE=OFF
        -DBUILD_EXAMPLES=OFF
        -DWITH_ORB_OCTREE=ON
        -DWITH_TORCH=OFF
        -DWITH_PYTHON=OFF
        -DWITH_PYTHON_THREADING=OFF
        -DWITH_PDAL=OFF
        -DWITH_FREENECT=OFF
        -DWITH_FREENECT2=OFF
        -DWITH_K4W2=OFF
        -DWITH_K4A=OFF
        -DWITH_OPENNI2=OFF
        -DWITH_DC1394=OFF
        -DWITH_G2O=ON
        -DWITH_GTSAM=OFF
        -DWITH_CERES=ON
        -DWITH_VERTIGO=OFF
        -DWITH_CVSBA=OFF
        -DWITH_POINTMATCHER=OFF
        -DWITH_CCCORELIB=OFF
        -DWITH_LOAM=OFF
        -DWITH_FLYCAPTURE2=OFF
        -DWITH_ZED=OFF
        -DWITH_ZEDOC=OFF
        -DWITH_REALSENSE=OFF
        -DWITH_REALSENSE_SLAM=OFF
        -DWITH_REALSENSE2=OFF
        -DWITH_MYNTEYE=OFF
        -DWITH_DEPTHAI=OFF
        -DWITH_OCTOMAP=ON
        -DWITH_CPUTSDF=OFF
        -DWITH_OPENCHISEL=OFF
        -DWITH_ALICE_VISION=OFF
        -DWITH_FOVIS=OFF
        -DWITH_VISO2=OFF
        -DWITH_DVO=OFF
        -DWITH_OKVIS=OFF
        -DWITH_MSCKF_VIO=OFF
        -DWITH_VINS=OFF
        -DWITH_OPENVINS=OFF
        -DWITH_MADGWICK=OFF
        -DWITH_FASTCV=OFF
)

vcpkg_cmake_install()

file(GLOB CONFIG_FILES "${CURRENT_PACKAGES_DIR}/CMake/*.cmake")
file(COPY ${CONFIG_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_cmake_config_fixup(PACKAGE_NAME RTABMap)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/CMake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/CMake")

file(GLOB EXEFILES_RELEASE "${CURRENT_PACKAGES_DIR}/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
file(GLOB EXEFILES_DEBUG "${CURRENT_PACKAGES_DIR}/debug/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
file(COPY ${EXEFILES_RELEASE} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(REMOVE ${EXEFILES_RELEASE} ${EXEFILES_DEBUG})
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
