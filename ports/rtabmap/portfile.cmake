vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO introlab/rtabmap
    REF ${VERSION}
    SHA512 9bcd0f359e0ee8060cf7088761544a3f7d38aadb37df820958f0811aa7b8edbfaf00f00d9472a8bf46261d4e5d868f9c10785263aaabaf374b6e5aa5237d70b0
    HEAD_REF master
    PATCHES
        0001-cmakelists-fixes.patch
        0002-fix-link.patch
        0003-multi-definition.patch
        0004-remove-apple-sys-path.patch
)
# Will use vcpkg to find these packages
file(REMOVE_RECURSE
    "${SOURCE_PATH}/cmake_modules/FindEigen3.cmake"
    "${SOURCE_PATH}/cmake_modules/FindRealSense2.cmake"
    "${SOURCE_PATH}/src/sqlite3"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gui         WITH_QT
        gui         VCPKG_LOCK_FIND_PACKAGE_Qt6
        gui         VCPKG_LOCK_FIND_PACKAGE_VTK
        k4w2        WITH_K4W2
        k4w2        VCPKG_LOCK_FIND_PACKAGE_KinectSDK2
        octomap     WITH_OCTOMAP
        octomap     VCPKG_LOCK_FIND_PACKAGE_octomap
        openmp      WITH_OPENMP
        openmp      VCPKG_LOCK_FIND_PACKAGE_OpenMP
        openni2     WITH_OPENNI2
        openni2     VCPKG_LOCK_FIND_PACKAGE_OpenNI2
        realsense2  WITH_REALSENSE2
        realsense2  VCPKG_LOCK_FIND_PACKAGE_realsense2
        tools       BUILD_APP
        tools       BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS_DEBUG
        -DBUILD_TOOLS=OFF
        -DBUILD_APP=OFF
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DRTABMAP_RES_TOOL=${CURRENT_HOST_INSTALLED_DIR}/tools/rtabmap-res-tool/rtabmap-res_tool${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
        -DRTABMAP_QT_VERSION=6
        -DBUILD_AS_BUNDLE=OFF
        -DBUILD_EXAMPLES=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_SQLite3=ON
        ## always on feats
        -DWITH_G2O=ON  -DVCPKG_LOCK_FIND_PACKAGE_g2o=ON
        -DWITH_CERES=ON
        -DWITH_ORB_OCTREE=ON   # GPLv3
        ## always off feats
        -DWITH_ALICE_VISION=OFF
        -DWITH_ARCore=OFF
        -DWITH_ARENGINE=OFF
        -DWITH_CCCORELIB=OFF
        -DWITH_CPUTSDF=OFF
        -DWITH_CVSBA=OFF
        -DWITH_DC1394=OFF
        -DWITH_DEPTHAI=OFF
        -DWITH_DVO=OFF
        -DWITH_FASTCV=OFF
        -DWITH_FLOAM=OFF
        -DWITH_FLYCAPTURE2=OFF
        -DWITH_FOVIS=OFF
        -DWITH_FREENECT=OFF
        -DWITH_FREENECT2=OFF
        -DWITH_GRIDMAP=OFF
        -DWITH_GTSAM=OFF
        -DWITH_K4A=OFF
        -DWITH_LOAM=OFF
        -DWITH_MADGWICK=OFF
        -DWITH_MRPT=OFF
        -DWITH_MSCKF_VIO=OFF
        -DWITH_MYNTEYE=OFF
        -DWITH_OKVIS=OFF
        -DWITH_OPEN3D=OFF
        -DWITH_OPENCHISEL=OFF
        -DWITH_OPENGV=OFF
        -DWITH_OPENVINS=OFF
        -DWITH_ORB_SLAM=OFF
        -DWITH_PDAL=OFF
        -DWITH_POINTMATCHER=OFF
        -DWITH_PYTHON=OFF
        -DWITH_PYTHON_THREADING=OFF
        -DWITH_REALSENSE=OFF
        -DWITH_REALSENSE_SLAM=OFF
        -DWITH_TANGO=OFF
        -DWITH_TORCH=OFF
        -DWITH_VERTIGO=OFF
        -DWITH_VINS=OFF
        -DWITH_VISO2=OFF
        -DWITH_ZED=OFF
        -DWITH_ZEDOC=OFF
    MAYBE_UNUSED_VARIABLES
        VCPKG_LOCK_FIND_PACKAGE_Qt6
        VCPKG_LOCK_FIND_PACKAGE_VTK
        VCPKG_LOCK_FIND_PACKAGE_KinectSDK2
        VCPKG_LOCK_FIND_PACKAGE_octomap
        VCPKG_LOCK_FIND_PACKAGE_OpenMP
        VCPKG_LOCK_FIND_PACKAGE_OpenNI2
        VCPKG_LOCK_FIND_PACKAGE_realsense2
        VCPKG_LOCK_FIND_PACKAGE_RealSense2
        # Android
        WITH_ARCore
        WITH_ARENGINE
        WITH_TANGO
)

vcpkg_cmake_install()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH CMake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/rtabmap-0.23)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if("tools" IN_LIST FEATURES)
  vcpkg_copy_tools(
    TOOL_NAMES
        rtabmap-camera
        rtabmap-console
        rtabmap-detectMoreLoopClosures
        rtabmap-export
        rtabmap-extractObject
        rtabmap-info
        rtabmap-kitti_dataset
        rtabmap-recovery
        rtabmap-report
        rtabmap-reprocess
        rtabmap-rgbd_dataset
        rtabmap-euroc_dataset
        rtabmap-cleanupLocalGrids
        rtabmap-globalBundleAdjustment
    AUTO_CLEAN
  )
  if("gui" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES
            rtabmap
            rtabmap-calibration
            rtabmap-databaseViewer
            rtabmap-dataRecorder
            rtabmap-odometryViewer
            rtabmap-rgbd_camera
            rtabmap-lidar_viewer
        AUTO_CLEAN
    )
    file(COPY "${CURRENT_INSTALLED_DIR}/tools/Qt6/bin/qt.conf" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/qt.conf" "./../../../" "./../../")
  endif()
endif()

vcpkg_install_copyright(
    COMMENT [[
The RTAB-Map main license is BSD-3-Clause, but some parts of the
source code are under other licenses possibly including GPL-3.0-only.
]]
    FILE_LIST "${SOURCE_PATH}/LICENSE"
)
