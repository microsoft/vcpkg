vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO introlab/rtabmap
    REF 0.21.0
    SHA512 47fa00e760cd9089d42dc27cc0120f2dc2ad4b32b6a05e87fb5320fd6fe3971e68958984714895640989543be9252fd0fb96ccebf0d00d70afbad224022a7a53
    HEAD_REF master
    PATCHES
        fix_autouic.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gui WITH_QT
        octomap WITH_OCTOMAP
        realsense2 WITH_REALSENSE2
        k4w2 WITH_K4W2
        openni2 WITH_OPENNI2
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
        -DWITH_K4A=OFF
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
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/tmp")
    file(GLOB RTABMAP_REL_LIBS "${CURRENT_PACKAGES_DIR}/tmp/rtabmap*")
    file(COPY ${RTABMAP_REL_LIBS} DESTINATION  "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tmp")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/translations")
    #qt.conf
    file(COPY "${CURRENT_INSTALLED_DIR}/tools/Qt6/bin/qt.conf" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/qt.conf" "./../../../" "./../../")

    # Debug
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/debug/tmp")
    file(GLOB RTABMAP_DBG_LIBS "${CURRENT_PACKAGES_DIR}/debug/tmp/rtabmap*")
    file(COPY ${RTABMAP_DBG_LIBS} DESTINATION  "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/tmp")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/plugins")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/translations")
  endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
