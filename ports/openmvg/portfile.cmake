vcpkg_buildpath_length_warning(37)

#the port produces some empty dlls when building shared libraries, since some components do not export anything, breaking the internal build itself
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openMVG/openMVG
    REF 01193a245ee3c36458e650b1cf4402caad8983ef  # v2.1
    SHA512 ee98ca26426e7129917c920cd59817cb5d4faf1f5aa12f4085f9ac431875e9ec23ffee7792d65286bad4b922c474c56d5c2f2008b38fddf1ede096644f13ad47
    PATCHES
        0001-fix-build.patch
        0002-fast-c-language.patch
        0003-no-absolute-paths.patch
)
file(REMOVE_RECURSE 
    "${SOURCE_PATH}/src/cmakeFindModules/FindEigen.cmake"
    "${SOURCE_PATH}/src/cmakeFindModules/FindFlann.cmake"
    "${SOURCE_PATH}/src/cmakeFindModules/FindLemon.cmake"
    "${SOURCE_PATH}/src/cmakeFindModules/FindClp.cmake"
    "${SOURCE_PATH}/src/cmakeFindModules/FindCoinUtils.cmake"
    "${SOURCE_PATH}/src/cmakeFindModules/FindOsi.cmake"
    "${SOURCE_PATH}/src/nonFree/sift/vl"
    "${SOURCE_PATH}/src/third_party/CppUnitLite"
    "${SOURCE_PATH}/src/third_party/ceres-solver"
    "${SOURCE_PATH}/src/third_party/cxsparse"
    "${SOURCE_PATH}/src/third_party/eigen"
    "${SOURCE_PATH}/src/third_party/flann"
    "${SOURCE_PATH}/src/third_party/jpeg"
    "${SOURCE_PATH}/src/third_party/lemon"
    "${SOURCE_PATH}/src/third_party/png"
    "${SOURCE_PATH}/src/third_party/tiff"
    "${SOURCE_PATH}/src/third_party/zlib"
)
file(MAKE_DIRECTORY "${SOURCE_PATH}/src/dependencies/cereal/include/_placeholder")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        opencv      OpenMVG_USE_OPENCV
        opencv      OpenMVG_USE_OCVSIFT
        opencv      VCPKG_LOCK_FIND_PACKAGE_OpenCV
        openmp      OpenMVG_USE_OPENMP
        software    OpenMVG_BUILD_SOFTWARES
        software    OpenMVG_BUILD_GUI_SOFTWARES
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" OpenMVG_BUILD_SHARED)

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DOpenMVG_BUILD_SHARED=${OpenMVG_BUILD_SHARED}
        -DOpenMVG_BUILD_COVERAGE=OFF
        -DOpenMVG_BUILD_DOC=OFF
        -DOpenMVG_BUILD_EXAMPLES=OFF
        -DOpenMVG_BUILD_OPENGL_EXAMPLES=OFF
        -DOpenMVG_BUILD_TESTS=OFF
        -DOpenMVG_USE_LIGT=OFF
        "-DFLANN_INCLUDE_DIR_HINTS=${CURRENT_INSTALLED_DIR}/include"
        "-DLEMON_INCLUDE_DIR_HINTS=${CURRENT_INSTALLED_DIR}/include"
        -DVCPKG_LOCK_FIND_PACKAGE_cereal=ON
        -DVCPKG_LOCK_FIND_PACKAGE_Ceres=ON
        -DVCPKG_LOCK_FIND_PACKAGE_Eigen3=ON
        -DVCPKG_LOCK_FIND_PACKAGE_Flann=ON
        -DVCPKG_LOCK_FIND_PACKAGE_JPEG=ON
        -DVCPKG_LOCK_FIND_PACKAGE_PNG=ON
        -DVCPKG_LOCK_FIND_PACKAGE_TIFF=ON
    OPTIONS_DEBUG
        -DOpenMVG_USE_OPENCV=OFF
        -DOpenMVG_BUILD_SOFTWARES=OFF
        -DOpenMVG_BUILD_GUI_SOFTWARES=OFF
    MAYBE_UNUSED_VARIABLES
        FLANN_INCLUDE_DIR_HINTS # Must be "defined"
        LEMON_INCLUDE_DIR_HINTS # Must be "defined"
        VCPKG_LOCK_FIND_PACKAGE_OpenCV
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/openMVG")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/include/openMVG_dependencies/cereal" 
    "${CURRENT_PACKAGES_DIR}/include/openMVG_dependencies/glfw"
    "${CURRENT_PACKAGES_DIR}/include/openMVG_dependencies/osi_clp"
    "${CURRENT_PACKAGES_DIR}/include/openMVG/image/image_test"
    "${CURRENT_PACKAGES_DIR}/include/openMVG/exif/image_data"
)

if("software" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_OSX)
        vcpkg_copy_tools(TOOL_NAMES
            openMVG_main_AlternativeVO.app
            ui_openMVG_MatchesViewer.app
        )
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/openMVG_main_AlternativeVO.app")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/ui_openMVG_MatchesViewer.app")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/openMVG_main_AlternativeVO.app")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/ui_openMVG_MatchesViewer.app")
    else()
        vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES
            openMVG_main_AlternativeVO
            ui_openMVG_MatchesViewer
        )
    endif()
    vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES
        openMVG_main_ChangeLocalOrigin
        openMVG_main_ColHarmonize
        openMVG_main_ComputeClusters
        openMVG_main_ComputeFeatures
        openMVG_main_ComputeMatches
        openMVG_main_ComputeSfM_DataColor
        openMVG_main_ComputeStructureFromKnownPoses
        openMVG_main_ComputeVLAD
        openMVG_main_ConvertList
        openMVG_main_ConvertSfM_DataFormat
        openMVG_main_evalQuality
        openMVG_main_ExportCameraFrustums
        openMVG_main_exportKeypoints
        openMVG_main_exportMatches
        openMVG_main_exportTracks
        openMVG_main_ExportUndistortedImages
        openMVG_main_FrustumFiltering
        openMVG_main_geodesy_registration_to_gps_position
        openMVG_main_ListMatchingPairs
        openMVG_main_MatchesToTracks
        openMVG_main_openMVG2Agisoft
        openMVG_main_openMVG2CMPMVS
        openMVG_main_openMVG2Colmap
        openMVG_main_openMVG2MESHLAB
        openMVG_main_openMVG2MVE2
        openMVG_main_openMVG2MVSTEXTURING
        openMVG_main_openMVG2NVM
        openMVG_main_openMVG2openMVS
        openMVG_main_openMVG2PMVS
        openMVG_main_openMVG2WebGL
        openMVG_main_openMVGSpherical2Cubic
        openMVG_main_PointsFiltering
        openMVG_main_SfMInit_ImageListing
        openMVG_main_SfMInit_ImageListingFromKnownPoses
        openMVG_main_SfM_Localization
        openMVG_main_SplitMatchFileIntoMatchFiles
        ui_openMVG_control_points_registration
        openMVG_main_GeometricFilter
        openMVG_main_PairGenerator
        openMVG_main_SfM
    )
    if("opencv" IN_LIST FEATURES)
        vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES
            openMVG_main_ComputeFeatures_OpenCV)
    endif()

    file(COPY "${CURRENT_PACKAGES_DIR}/share/${PORT}/sensor_width_camera_database.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(COPY_FILE "${SOURCE_PATH}/src/software/SfM/tutorial_demo.py.in" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/tutorial_demo.py")
    file(COPY_FILE "${SOURCE_PATH}/src/software/SfM/SfM_GlobalPipeline.py.in" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/SfM_GlobalPipeline.py")
    file(COPY_FILE "${SOURCE_PATH}/src/software/SfM/SfM_SequentialPipeline.py.in" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/SfM_SequentialPipeline.py")
    file(COPY_FILE "${SOURCE_PATH}/src/software/SfM/import/SfM_StructurePipeline.py.in" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/SfM_StructurePipeline.py")
endif()

set(third_party_notices "")
file(GLOB files "${SOURCE_PATH}/src/third_party/*/README.openMVG")
foreach(file IN LISTS files)
    cmake_path(GET file PARENT_PATH parent_path)
    cmake_path(GET parent_path FILENAME component)
    set(extra_file "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${component}")
    file(COPY_FILE "${file}" "${extra_file}")
    list(APPEND third_party_notices "${extra_file}")
endforeach()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" ${third_party_notices})
