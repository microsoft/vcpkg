if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO introlab/rtabmap
    REF ${VERSION}
    SHA512 2b424f5b6458cf0f976e711985708f104b56d11921c9c43c6a837f9d3dc9e9e802308f1aa2b6d0e7e6ddf13623ff1ad2922b5f54254d16ee5811e786d27b9f98
    HEAD_REF master
    PATCHES
        apple.patch
        fix_link.patch
        link-keywords.patch
        multi-definition.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS OPTIONS
    FEATURES
        gui         WITH_QT
        k4w2        WITH_K4W2
        octomap     WITH_OCTOMAP
        openni2     WITH_OPENNI2
        realsense2  WITH_REALSENSE2
        tools       BUILD_APP
        tools       BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_AS_BUNDLE=OFF
        -DBUILD_EXAMPLES=OFF
        -DWITH_ALICE_VISION=OFF
        -DWITH_CCCORELIB=OFF
        -DWITH_CERES=ON
        -DWITH_CPUTSDF=OFF
        -DWITH_CVSBA=OFF
        -DWITH_DC1394=OFF
        -DWITH_DEPTHAI=OFF
        -DWITH_DVO=OFF
        -DWITH_FASTCV=OFF
        -DWITH_FLYCAPTURE2=OFF
        -DWITH_FOVIS=OFF
        -DWITH_FREENECT=OFF
        -DWITH_FREENECT2=OFF
        -DWITH_G2O=ON
        -DWITH_GTSAM=OFF
        -DWITH_K4A=OFF
        -DWITH_LOAM=OFF
        -DWITH_MADGWICK=OFF
        -DWITH_MSCKF_VIO=OFF
        -DWITH_MYNTEYE=OFF
        -DWITH_OKVIS=OFF
        -DWITH_OPENCHISEL=OFF
        -DWITH_OPENVINS=OFF
        -DWITH_ORB_OCTREE=ON   # GPLv3
        -DWITH_PDAL=OFF
        -DWITH_POINTMATCHER=OFF
        -DWITH_PYTHON_THREADING=OFF
        -DWITH_PYTHON=OFF
        -DWITH_REALSENSE_SLAM=OFF
        -DWITH_REALSENSE=OFF
        -DWITH_TORCH=OFF
        -DWITH_VERTIGO=OFF
        -DWITH_VINS=OFF
        -DWITH_VISO2=OFF
        -DWITH_ZED=OFF
        -DWITH_ZEDOC=OFF
        ${OPTIONS}
    OPTIONS_DEBUG
        -DBUILD_APP=OFF
        -DBUILD_TOOLS=OFF
)

vcpkg_cmake_install()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH CMake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/rtabmap-0.21)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(NOT VCPKG_TARGET_IS_WINDOWS)
  vcpkg_copy_tools(TOOL_NAMES rtabmap-res_tool-0.3.0)  
endif()
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

    if(NOT VCPKG_BUILD_TYPE)
      file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/debug/tmp")
      file(GLOB RTABMAP_DBG_LIBS "${CURRENT_PACKAGES_DIR}/debug/tmp/rtabmap*")
      file(COPY ${RTABMAP_DBG_LIBS} DESTINATION  "${CURRENT_PACKAGES_DIR}/debug/bin")
      file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/tmp")
      file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/plugins")
      file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/translations")
    endif()
  endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
