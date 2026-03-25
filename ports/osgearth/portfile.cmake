vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pelicanmapping/osgearth
    REF fe1ee6a793b25015495f6d917a7473d48b4d8a12
    SHA512 c14abda37adda58958ca30687d94716ef2aad9018eef32b1868e885bb2319236b9f0cf98479cbe7ded8744768bf2ed8b69234c57d4ed3434285764a353e4258c
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        controls OSGEARTH_BUILD_LEGACY_CONTROLS_API
        tools    OSGEARTH_BUILD_TOOLS
		cesium 	 OSGEARTH_BUILD_CESIUM_NODEKIT
		triton   OSGEARTH_BUILD_TRITON_NODEKIT
		silverlining OSGEARTH_BUILD_SILVERLINING_NODEKIT
		geocoder	OSGEARTH_ENABLE_GEOCODER
		procedural  OSGEARTH_BUILD_PROCEDURAL_NODEKIT
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DOSGEARTH_BUILD_SHARED_LIBS=${BUILD_SHARED}
        -DOSGEARTH_BUILD_EXAMPLES=OFF
        -DOSGEARTH_BUILD_TESTS=OFF
        -DOSGEARTH_BUILD_DOCS=OFF
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
        osgearth_clamp osgearth_tfs osgearth_server osgearth_conv osgearth_imgui osgearth_version osgearth_viewer
        AUTO_CLEAN
    )
    if(OSGEARTH_BUILD_LEGACY_CONTROLS_API)
        vcpkg_copy_tools(TOOL_NAMES osgearth_createtile AUTO_CLEAN)
    endif()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
