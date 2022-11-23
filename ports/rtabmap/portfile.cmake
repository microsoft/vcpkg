vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO introlab/rtabmap
    REF a921d615c5cb4eb55a8dfc608dae6efde13e9126
    SHA512 7787d5f927f53554cec3044221011cbc78b654c504d96af29947266e25058194923c5463aefde73b93dcfb3930eedf731f6af4d0c311d8f2f0d7be2114393e05
    HEAD_REF master
    PATCHES
        0001-add-bigobj-for-msvc.patch
        0002-fix-opencv46.patch
        0003-fix-qt.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_APP=OFF
        -DBUILD_EXAMPLES=OFF
        -DWITH_QT=OFF
        -DWITH_ORB_OCTREE=OFF
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
        -DWITH_G2O=OFF
        -DWITH_GTSAM=OFF
        -DWITH_CERES=OFF
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
        -DWITH_OCTOMAP=OFF
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
vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

vcpkg_copy_tools(TOOL_NAMES rtabmap-res_tool AUTO_CLEAN)

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
    AUTO_CLEAN
  )
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
