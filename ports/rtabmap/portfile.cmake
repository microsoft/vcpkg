vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO introlab/rtabmap
    # rtabmap stops releasing, check their CMakeLists.txt for version.
    # currently is 0.21.0
    REF e66ea7b42b8a18d89411aa125a0cefbf33302f0a
    SHA512 ec6dc68789630988a0f78851af03c3259a11bc8d515a97e1fb4956c878109be648adfdd916c8f9a40b7c6f6cac60f5257e8f80a254d01354c9e1c84e5df63247
    HEAD_REF master
    PATCHES
        qtdeploy.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_TOOLS
        tools BUILD_APP
        gui WITH_QT
        octomap WITH_OCTOMAP
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
    file(GLOB RTABMAP_LIBS ${CURRENT_PACKAGES_DIR}/tmp/rtabmap*)
    file(COPY ${RTABMAP_LIBS} DESTINATION  ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tmp")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/translations")
    file(RENAME ${CURRENT_PACKAGES_DIR}/plugins ${CURRENT_PACKAGES_DIR}/tools/${PORT}/plugins)
    #qt.conf
    file(WRITE ${CURRENT_PACKAGES_DIR}/tools/${PORT}/qt.conf "[Paths]
    Prefix = .")
    
  endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
