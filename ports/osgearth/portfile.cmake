vcpkg_download_distfile(
    gdal_3_11_diff
    URLS "https://github.com/gwaldron/osgearth/commit/f17898acd34656144936ea7d00e980a89a2c5215.diff?full_index=1"
    FILENAME "gwaldron-osgearth-3.7.2-gdal-3.11-f17898acd34656144936ea7d00e980a89a2c5215.diff"
    SHA512 9c316a951cb2ba506221d3c07a7a31d2f95e7ceef20a94c555ce0f399882cabe547e99eb404d43187328085b57de48f737694da808cad71ccc5f7274f89df8a8
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gwaldron/osgearth
    REF "osgearth-${VERSION}"
    SHA512 4a2b80c907ebf2b56966598f9e134ad910d3271757496fb1d906cc413eb2ad09da366a96635f0195696efe16ef1a649e13b6ec1d901a39ced0465be797f14221
    HEAD_REF master
    PATCHES
        "${gdal_3_11_diff}"
        namespace-gdal.diff
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        controls    OSGEARTH_BUILD_LEGACY_CONTROLS_API
        tools       OSGEARTH_BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DOSGEARTH_BUILD_SHARED_LIBS=${BUILD_SHARED}
        -DOSGEARTH_BUILD_EXAMPLES=OFF
        -DOSGEARTH_BUILD_TESTS=OFF
        -DOSGEARTH_BUILD_DOCS=OFF
        -DOSGEARTH_BUILD_PROCEDURAL_NODEKIT=OFF
        -DOSGEARTH_BUILD_TRITON_NODEKIT=OFF
        -DOSGEARTH_BUILD_SILVERLINING_NODEKIT=OFF
        -DOSGEARTH_BUILD_ZIP_PLUGIN=OFF
        -DBUILDING_VCPKG_PORT=ON
        -DCMAKE_JOB_POOL_LINK=console # Serialize linking to avoid OOM
    OPTIONS_DEBUG
        -DOSGEARTH_BUILD_TOOLS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/osgEarth/Export" "defined( OSGEARTH_LIBRARY_STATIC )" "1")
endif()

set(osg_plugin_pattern "${VCPKG_TARGET_SHARED_LIBRARY_PREFIX}osgdb*${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}")
if("tools" IN_LIST FEATURES)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        file(GLOB osg_plugins "${CURRENT_PACKAGES_DIR}/plugins/${osg_plugins_subdir}/${osg_plugin_pattern}")
        file(INSTALL ${osg_plugins} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${osg_plugins_subdir}")
        if(NOT VCPKG_BUILD_TYPE)
            file(GLOB osg_plugins "${CURRENT_PACKAGES_DIR}/debug/plugins/${osg_plugins_subdir}/${osg_plugin_pattern}")
            file(INSTALL ${osg_plugins} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/${osg_plugins_subdir}")
        endif()
    endif()
    vcpkg_copy_tools(TOOL_NAMES osgearth_3pv osgearth_atlas osgearth_bakefeaturetiles osgearth_boundarygen
        osgearth_clamp osgearth_conv osgearth_imgui osgearth_tfs osgearth_version osgearth_viewer
        AUTO_CLEAN
    )
    if(OSGEARTH_BUILD_LEGACY_CONTROLS_API)
        vcpkg_copy_tools(TOOL_NAMES osgearth_createtile AUTO_CLEAN)
    endif()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
