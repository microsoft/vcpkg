vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gwaldron/osgearth
    REF "osgearth-${VERSION}"
    SHA512 2f764eb1fff21cff57a04eceb73643b372c8b70899114c88cdf9928d525517214959745cb70b99ad3d1def946bfb3f58f16b4969ee4117b7563398f2410ee3e2
    HEAD_REF master
    PATCHES
        remove-lerc-gltf.patch
        install-plugins.patch
)

if("tools" IN_LIST FEATURES)
	message(STATUS "Downloading submodules")
	# Download submodules from github manually since vpckg doesn't support submodules natively.
	# IMGUI
	#osgEarth is currently using imgui docking branch for osgearth_imgui example
	vcpkg_from_github(
		OUT_SOURCE_PATH IMGUI_SOURCE_PATH
		REPO ocornut/imgui
		REF cab7edd135fb8a02b3552e9abe4c312d595e8777 #docking branch
		SHA512 26dfe94793bcc7b041c723cfbf2033c32e5050d87b99856746f9f3e7f562db15b9432bf92747db7823acbc6e366dbcb023653692bb5336ce65a98483c4d8232a
		HEAD_REF master
	)

	# Remove exisiting folder in case it was not cleaned
	file(REMOVE_RECURSE "${SOURCE_PATH}/src/third_party/imgui")
	# Copy the submodules to the right place
	file(COPY "${IMGUI_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/src/third_party/imgui")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools       OSGEARTH_BUILD_TOOLS
        blend2d     WITH_BLEND2D
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIB_POSTFIX=
        -DOSGEARTH_BUILD_SHARED_LIBS=${BUILD_SHARED}
        -DOSGEARTH_BUILD_EXAMPLES=OFF
        -DOSGEARTH_BUILD_TESTS=OFF
        -DOSGEARTH_BUILD_DOCS=OFF
        -DOSGEARTH_BUILD_PROCEDURAL_NODEKIT=OFF
        -DOSGEARTH_BUILD_TRITON_NODEKIT=OFF
        -DOSGEARTH_BUILD_SILVERLINING_NODEKIT=OFF
        -DOSGEARTH_BUILD_ZIP_PLUGIN=OFF		
        -DWITH_EXTERNAL_TINYXML=ON
        -DCMAKE_JOB_POOL_LINK=console # Serialize linking to avoid OOM
    OPTIONS_DEBUG
        -DOSGEARTH_BUILD_TOOLS=OFF
    MAYBE_UNUSED_VARIABLES
        LIB_POSTFIX
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
	file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
