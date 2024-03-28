vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gwaldron/osgearth
    REF "osgearth-${VERSION}"
    SHA512 f65c31922bebcbf722474a047dc29c8c1ceec9c037b0704811af2627fc2d0a124b6e95888e7d3b9b0e5acc146a88ebf8669e3f864a75a91751c3a4571d05a630
    HEAD_REF master
    PATCHES
        link-libraries.patch
        find-package.patch
        remove-tool-debug-suffix.patch
		remove-lerc-gltf.patch
		export-plugins.patch
        protobuf.patch
)

if("tools" IN_LIST FEATURES)
	message(STATUS "Downloading submodules")
	# Download submodules from github manually since vpckg doesn't support submodules natively.
	# IMGUI
	#osgEarth is currently using imgui docking branch for osgearth_imgui example
	vcpkg_from_github(
		OUT_SOURCE_PATH IMGUI_SOURCE_PATH
		REPO ocornut/imgui
		REF 9e8e5ac36310607012e551bb04633039c2125c87 #docking branch
		SHA512 1f1f743833c9a67b648922f56a638a11683b02765d86f14a36bc6c242cc524c4c5c5c0b7356b8053eb923fafefc53f4c116b21fb3fade7664554a1ad3b25e5ff
		HEAD_REF master
	)

	# Remove exisiting folder in case it was not cleaned
	file(REMOVE_RECURSE "${SOURCE_PATH}/src/third_party/imgui")
	# Copy the submodules to the right place
	file(COPY "${IMGUI_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/src/third_party/imgui")
endif()

file(REMOVE
    "${SOURCE_PATH}/CMakeModules/FindBlend2D.cmake"
    "${SOURCE_PATH}/CMakeModules/FindGEOS.cmake"
    "${SOURCE_PATH}/CMakeModules/FindLibZip.cmake"
    "${SOURCE_PATH}/CMakeModules/FindOSG.cmake"
    "${SOURCE_PATH}/CMakeModules/FindSqlite3.cmake"
    "${SOURCE_PATH}/CMakeModules/FindWEBP.cmake"
    "${SOURCE_PATH}/src/osgEarth/tinyxml.h" # https://github.com/gwaldron/osgearth/issues/1002
)

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
        -DWITH_EXTERNAL_TINYXML=ON
        -DCMAKE_JOB_POOL_LINK=console # Serialize linking to avoid OOM
    OPTIONS_DEBUG
        -DOSGEARTH_BUILD_TOOLS=OFF
    MAYBE_UNUSED_VARIABLES
        LIB_POSTFIX
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH cmake/)

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
        osgearth_clamp osgearth_conv osgearth_imgui osgearth_tfs osgearth_toc osgearth_version osgearth_viewer
		osgearth_createtile osgearth_mvtindex
        AUTO_CLEAN
    )
	file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
