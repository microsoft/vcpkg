vcpkg_buildpath_length_warning(37)

#the port produces some empty dlls when building shared libraries, since some components do not export anything, breaking the internal build itself
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("software" IN_LIST FEATURES AND VCPKG_CRT_LINKAGE STREQUAL static)
    message(FATAL_ERROR "OpenMVG software currently cannot be built with static CRT linking. Please open an issue if you require this feature.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openMVG/openMVG
    REF 01193a245ee3c36458e650b1cf4402caad8983ef  # v2.1
    SHA512 ee98ca26426e7129917c920cd59817cb5d4faf1f5aa12f4085f9ac431875e9ec23ffee7792d65286bad4b922c474c56d5c2f2008b38fddf1ede096644f13ad47
    PATCHES
        build_fixes.patch
        0001-eigen_3.4.0.patch
        no-absolute-paths.patch
)

set(OpenMVG_USE_OPENMP OFF)
if("openmp" IN_LIST FEATURES)
    set(OpenMVG_USE_OPENMP ON)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        opencv OpenMVG_USE_OPENCV
        opencv OpenMVG_USE_OCVSIFT
        software OpenMVG_BUILD_SOFTWARES
        software OpenMVG_BUILD_GUI_SOFTWARES
)

# remove some deps to prevent conflict
file(REMOVE_RECURSE ${SOURCE_PATH}/src/third_party/ceres-solver
                    ${SOURCE_PATH}/src/third_party/cxsparse
                    ${SOURCE_PATH}/src/third_party/eigen
                    ${SOURCE_PATH}/src/third_party/flann
                    ${SOURCE_PATH}/src/third_party/jpeg
                    ${SOURCE_PATH}/src/third_party/lemon
                    ${SOURCE_PATH}/src/third_party/png
                    ${SOURCE_PATH}/src/third_party/tiff
                    ${SOURCE_PATH}/src/third_party/zlib)

# remove some cmake modules to force using our configs
file(REMOVE_RECURSE ${SOURCE_PATH}/src/cmakeFindModules/FindEigen.cmake
                    ${SOURCE_PATH}/src/cmakeFindModules/FindLemon.cmake
                    ${SOURCE_PATH}/src/cmakeFindModules/FindFlann.cmake
                    #${SOURCE_PATH}/src/cmakeFindModules/FindCoinUtils.cmake
                    #${SOURCE_PATH}/src/cmakeFindModules/FindClp.cmake
                    #${SOURCE_PATH}/src/cmakeFindModules/FindOsi.cmake
                    )

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src"
    OPTIONS ${FEATURE_OPTIONS}
        -DOpenMVG_USE_OPENMP=${OpenMVG_USE_OPENMP}
        -DOpenMVG_BUILD_SHARED=OFF
        -DOpenMVG_BUILD_TESTS=OFF
        -DOpenMVG_BUILD_DOC=OFF
        -DOpenMVG_BUILD_EXAMPLES=OFF
        -DOpenMVG_BUILD_OPENGL_EXAMPLES=OFF
        -DOpenMVG_BUILD_COVERAGE=OFF
        -DOpenMVG_USE_INTERNAL_CLP=OFF
        -DOpenMVG_USE_INTERNAL_COINUTILS=OFF
        -DOpenMVG_USE_INTERNAL_OSI=OFF
        -DOpenMVG_USE_INTERNAL_EIGEN=OFF
        -DOpenMVG_USE_INTERNAL_CEREAL=OFF
        -DOpenMVG_USE_INTERNAL_CERES=OFF
        -DOpenMVG_USE_INTERNAL_FLANN=OFF
        -DOpenMVG_USE_INTERNAL_LEMON=OFF
        "-DCOINUTILS_INCLUDE_DIR_HINTS=${CURRENT_INSTALLED_DIR}/include/coin-or"
        "-DCLP_INCLUDE_DIR_HINTS=${CURRENT_INSTALLED_DIR}/include/coin-or"
        "-DOSI_INCLUDE_DIR_HINTS=${CURRENT_INSTALLED_DIR}/include/coin-or"
)

vcpkg_cmake_install()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/openMVG/")
file(RENAME "${CURRENT_PACKAGES_DIR}/lib/openMVG/cmake" "${CURRENT_PACKAGES_DIR}/share/openMVG/cmake")
if(NOT VCPKG_BUILD_TYPE)
  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/share/openMVG/")
  file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/openMVG/cmake" "${CURRENT_PACKAGES_DIR}/debug/share/openMVG/cmake")
endif()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE
     "${CURRENT_PACKAGES_DIR}/debug/include"
     "${CURRENT_PACKAGES_DIR}/include/openMVG_dependencies/cereal" 
     "${CURRENT_PACKAGES_DIR}/include/openMVG_dependencies/glfw"
     "${CURRENT_PACKAGES_DIR}/include/openMVG_dependencies/osi_clp"
     "${CURRENT_PACKAGES_DIR}/include/openMVG/image/image_test"
     "${CURRENT_PACKAGES_DIR}/include/openMVG/exif/image_data"
     "${CURRENT_PACKAGES_DIR}/include/openMVG_dependencies/nonFree/sift/vl")

if(OpenMVG_BUILD_SHARED)
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        # release
        file(GLOB DLL_FILES  "${CURRENT_PACKAGES_DIR}/lib/*.dll")
        file(COPY "${DLL_FILES}" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(REMOVE_RECURSE "${DLL_FILES}")
    endif()
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        # debug
        file(GLOB DLL_FILES  "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll")
        file(COPY "${DLL_FILES}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(REMOVE_RECURSE "${DLL_FILES}")
    endif()
endif()
vcpkg_copy_pdbs()

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

    file(COPY "${SOURCE_PATH}/src/openMVG/exif/sensor_width_database/sensor_width_camera_database.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    set(OPENMVG_SOFTWARE_SFM_BUILD_DIR "${CURRENT_INSTALLED_DIR}/tools/${PORT}")
    set(OPENMVG_CAMERA_SENSOR_WIDTH_DIRECTORY "${CURRENT_INSTALLED_DIR}/tools/${PORT}")
    configure_file("${SOURCE_PATH}/src/software/SfM/tutorial_demo.py.in" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/tutorial_demo.py" @ONLY)
    configure_file("${SOURCE_PATH}/src/software/SfM/SfM_GlobalPipeline.py.in" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/SfM_GlobalPipeline.py" @ONLY)
    configure_file("${SOURCE_PATH}/src/software/SfM/SfM_SequentialPipeline.py.in" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/SfM_SequentialPipeline.py" @ONLY)
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
