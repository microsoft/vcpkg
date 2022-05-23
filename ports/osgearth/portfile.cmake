# Only dynamic build need dlls
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(GLOB OSG_PLUGINS_SUBDIR "${CURRENT_INSTALLED_DIR}/tools/osg/osgPlugins-*")
    list(LENGTH OSG_PLUGINS_SUBDIR OSG_PLUGINS_SUBDIR_LENGTH)
    if(NOT OSG_PLUGINS_SUBDIR_LENGTH EQUAL 1)
        message(FATAL_ERROR "Could not determine osg version")
    endif()
    string(REPLACE "${CURRENT_INSTALLED_DIR}/tools/osg/" "" OSG_PLUGINS_SUBDIR "${OSG_PLUGINS_SUBDIR}")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gwaldron/osgearth
    REF 6b5fb806a9190f7425c32db65d3ea905a55a9c16 #version 3.3
    SHA512 fe79ce6c73341f83d4aee8cb4da5341dead56a92f998212f7898079b79725f46b2209d64e68fe3b4d99d3c5c25775a8efd1bf3c3b3a049d4f609d3e30172d3bf
    HEAD_REF master
    PATCHES
        StaticOSG.patch # Fix port compilation in static-md module
        make-all-find-packages-required.patch
        fix-dependency-osg.patch
        remove-tool-debug-suffix.patch
)

message(STATUS "Downloading submodules")
# Download all of the submodules from github manually since vpckg doesn't support submodules natively.
# IMGUI
vcpkg_from_github(
    OUT_SOURCE_PATH IMGUI_SOURCE_PATH
    REPO ocornut/imgui
    REF 9e8e5ac36310607012e551bb04633039c2125c87 #master
    SHA512 1f1f743833c9a67b648922f56a638a11683b02765d86f14a36bc6c242cc524c4c5c5c0b7356b8053eb923fafefc53f4c116b21fb3fade7664554a1ad3b25e5ff
    HEAD_REF master
)

# LERC
vcpkg_from_github(
    OUT_SOURCE_PATH LERC_SOURCE_PATH
    REPO Esri/lerc
    REF 19542a00b9a8b5c1089f74239e5859e02e403212 #v2.2.1
    SHA512 3a4d3049da08c2303c74ce8767a3e588e8eb024f63a04c7f93ccdbbcc0fbcc85870f1c339591e0900a2cd5fe607afcd07c21ad5e4a03c8c61620fe7e2c131501
    HEAD_REF v2.2.1
)

# RAPIDJSON
vcpkg_from_github(
    OUT_SOURCE_PATH RAPIDJSON_SOURCE_PATH
    REPO Tencent/rapidjson
    REF f54b0e47a08782a6131cc3d60f94d038fa6e0a51 #v1.1.0
    SHA512 f30796721c0bfc789d91622b3af6db8d4fb4947a6da3fcdd33e8f37449a28e91dbfb23a98749272a478ca991aaf1696ab159c53b50f48ef69a6f6a51a7076d01
    HEAD_REF v1.1.0
)

# Copy the submodules to the right place
file(COPY ${IMGUI_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/src/third_party/imgui)
file(COPY ${LERC_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/src/third_party/lerc)
file(COPY ${RAPIDJSON_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/src/third_party/rapidjson)



# Upstream bug, see https://github.com/gwaldron/osgearth/issues/1002
file(REMOVE "${SOURCE_PATH}/src/osgEarth/tinyxml.h")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tools OSGEARTH_BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DOSGEARTH_BUILD_SHARED_LIBS=${BUILD_SHARED}
        -DNRL_STATIC_LIBRARIES=${BUILD_STATIC}
        -DOSG_IS_STATIC=${BUILD_STATIC}
        -DGEOS_IS_STATIC=${BUILD_STATIC}
        -DCURL_IS_STATIC=${BUILD_STATIC}
        -DOSGEARTH_BUILD_EXAMPLES=OFF
        -DOSGEARTH_BUILD_TESTS=OFF
        -DOSGEARTH_BUILD_DOCS=OFF
        -DOSGEARTH_BUILD_PROCEDURAL_NODEKIT=OFF
        -DOSGEARTH_BUILD_TRITON_NODEKIT=OFF
        -DOSGEARTH_BUILD_SILVERLINING_NODEKIT=OFF
        -DWITH_EXTERNAL_TINYXML=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH cmake/)


if (WIN32 AND (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic"))
    #Release
    set(OSGEARTH_TOOL_PATH "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    set(OSGEARTH_TOOL_PLUGIN_PATH "${OSGEARTH_TOOL_PATH}/${OSG_PLUGINS_SUBDIR}")

    file(MAKE_DIRECTORY "${OSGEARTH_TOOL_PLUGIN_PATH}")
    file(GLOB OSGDB_PLUGINS "${CURRENT_PACKAGES_DIR}/bin/${OSG_PLUGINS_SUBDIR}/osgdb*.dll")

    file(COPY ${OSGDB_PLUGINS} DESTINATION "${OSGEARTH_TOOL_PLUGIN_PATH}")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/${OSG_PLUGINS_SUBDIR}")

    #Debug
    set(OSGEARTH_DEBUG_TOOL_PATH "${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}")
    set(OSGEARTH_DEBUG_TOOL_PLUGIN_PATH "${OSGEARTH_DEBUG_TOOL_PATH}/${OSG_PLUGINS_SUBDIR}")

    file(MAKE_DIRECTORY "${OSGEARTH_DEBUG_TOOL_PLUGIN_PATH}")

    file(GLOB OSGDB_DEBUG_PLUGINS "${CURRENT_PACKAGES_DIR}/debug/bin/${OSG_PLUGINS_SUBDIR}/osgdb*.dll")

    file(COPY ${OSGDB_DEBUG_PLUGINS} DESTINATION "${OSGEARTH_DEBUG_TOOL_PLUGIN_PATH}")

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/${OSG_PLUGINS_SUBDIR}")
endif()

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES osgearth_3pv osgearth_atlas osgearth_boundarygen osgearth_clamp
        osgearth_conv osgearth_imgui osgearth_tfs osgearth_toc osgearth_version osgearth_viewer osgearth_createtile
		osgearth_mvtindex
        AUTO_CLEAN
    )
endif()



file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
