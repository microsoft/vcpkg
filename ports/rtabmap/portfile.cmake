vcpkg_download_distfile(CERES_21_PATCH_1
    URLS https://patch-diff.githubusercontent.com/raw/introlab/rtabmap/pull/1405.patch
    SHA512 c586885683807b3a3853fd09f46942f1599c8d3c3869388338cab97f0c09f51bf55726aad62ee883fbe3ce1734ab3c4c2e23a8ea7f2e5c01e0a7df8f9dc1e94b
    FILENAME rtabmap-1405.patch
)

vcpkg_download_distfile(CERES_21_PATCH_2
    URLS https://patch-diff.githubusercontent.com/raw/introlab/rtabmap/pull/1437.patch
    SHA512 d5400fdfd35594912af0d463e360a2b79739d18d4eb487f81486af67bc80e4c2d26c3bf3b94dbb51dfa159bb02a70196c6d42c9aca4b789b0026c009b1645296
    FILENAME rtabmap-1437.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO introlab/rtabmap
    REF ${VERSION}
    SHA512 2b424f5b6458cf0f976e711985708f104b56d11921c9c43c6a837f9d3dc9e9e802308f1aa2b6d0e7e6ddf13623ff1ad2922b5f54254d16ee5811e786d27b9f98
    HEAD_REF master
    PATCHES
        ${CERES_21_PATCH_1}
        ${CERES_21_PATCH_2}
        0001-cmakelists-fixes.patch
        0002-fix-link.patch
        0003-multi-definition.patch
        0004-fix-manfold-typo.patch
        0005-fix-opencv3-aruco.patch
        0006-remove-apple-sys-path.patch
        0007-fix-g2o.patch
        0008-fix-pcl-include.patch
)
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
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/rtabmap-0.21)
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
