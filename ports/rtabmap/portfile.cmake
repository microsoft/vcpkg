vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO introlab/rtabmap
    # rtabmap stops releasing, check their CMakeLists.txt for version.
    # currently is 0.21.0
    REF ab99719a78de5ffe6dd9f22576eed3f56a3aa731
    SHA512 bdc09f6b9d0b869fe55797a7e85b660b1ad44eae44f747f384448f6416dfb0263149203285f32e7918bd22282a369416790544a64173ce5fb79aeda79d928eaa
    HEAD_REF master
    PATCHES
        qtdeploy.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gui WITH_QT
        octomap WITH_OCTOMAP
)

vcpkg_check_features(OUT_FEATURE_OPTIONS REL_FEATURE_OPTIONS
    FEATURES
        tools BUILD_TOOLS
        tools BUILD_APP
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS_DEBUG
        -DBUILD_TOOLS=OFF
        -DBUILD_APP=OFF
    OPTIONS_RELEASE
        ${REL_FEATURE_OPTIONS}
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

vcpkg_cmake_config_fixup(PACKAGE_NAME RTABMap CONFIG_PATH CMake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

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
    
    # Remove duplicate files that were added by qtdeploy 
    # that would be already deployed by vcpkg_copy_tools
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/tmp)
    file(GLOB RTABMAP_REL_LIBS ${CURRENT_PACKAGES_DIR}/tmp/rtabmap*)
    file(COPY ${RTABMAP_REL_LIBS} DESTINATION  ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tmp")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/translations")
    file(RENAME ${CURRENT_PACKAGES_DIR}/plugins ${CURRENT_PACKAGES_DIR}/tools/${PORT}/plugins)
    #qt.conf
    file(WRITE ${CURRENT_PACKAGES_DIR}/tools/${PORT}/qt.conf "[Paths]
    Prefix = .")

    # Debug
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/debug/tmp)
    file(GLOB RTABMAP_DBG_LIBS ${CURRENT_PACKAGES_DIR}/debug/tmp/rtabmap*)
    file(COPY ${RTABMAP_DBG_LIBS} DESTINATION  ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/tmp")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/plugins")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/translations")
    
  endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
