vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gwaldron/osgearth
    REF 6b5fb806a9190f7425c32db65d3ea905a55a9c16 #version 3.3
    SHA512 fe79ce6c73341f83d4aee8cb4da5341dead56a92f998212f7898079b79725f46b2209d64e68fe3b4d99d3c5c25775a8efd1bf3c3b3a049d4f609d3e30172d3bf
    HEAD_REF master
    PATCHES
        link-libraries.patch
        find-package.patch
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

file(REMOVE
    "${SOURCE_PATH}/CMakeModule/FindGEOS.cmake"
    "${SOURCE_PATH}/CMakeModule/FindLibZip.cmake"
    "${SOURCE_PATH}/CMakeModule/FindOSG.cmake"
    "${SOURCE_PATH}/CMakeModule/FindSqlite3.cmake"
    "${SOURCE_PATH}/CMakeModule/FindWEBP.cmake"
    "${SOURCE_PATH}/src/osgEarth/tinyxml.h" # https://github.com/gwaldron/osgearth/issues/1002
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools       OSGEARTH_BUILD_TOOLS
        blend2d     CMAKE_REQUIRE_FIND_PACKAGE_BLEND2D
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
)

vcpkg_cmake_install()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/osgEarth/Export" "defined( OSGEARTH_LIBRARY_STATIC )" "1")
endif()

# Merge osgearth plugins into [/debug]/plugins/osgPlugins-${OSG_VER},
# as a staging area for later deployment.
set(osg_plugin_pattern "${VCPKG_TARGET_SHARED_LIBRARY_PREFIX}osgdb*${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(GLOB osg_plugins_subdir RELATIVE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/bin/osgPlugins-*")
    list(LENGTH osg_plugins_subdir osg_plugins_subdir_LENGTH)
    if(NOT osg_plugins_subdir_LENGTH EQUAL 1)
        message(FATAL_ERROR "Could not determine osg plugins directory.")
    endif()
    file(GLOB osgearth_plugins "${CURRENT_PACKAGES_DIR}/bin/${osg_plugins_subdir}/${osg_plugin_pattern}")
    file(INSTALL ${osgearth_plugins} DESTINATION "${CURRENT_PACKAGES_DIR}/plugins/${osg_plugins_subdir}")
    if(NOT VCPKG_BUILD_TYPE)
        file(GLOB osgearth_plugins "${CURRENT_PACKAGES_DIR}/debug/bin/${osg_plugins_subdir}/${osg_plugin_pattern}")
        file(INSTALL ${osgearth_plugins} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/plugins/${osg_plugins_subdir}")
    endif()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/${osg_plugins_subdir}" "${CURRENT_PACKAGES_DIR}/debug/bin/${osg_plugins_subdir}")
endif()

if("tools" IN_LIST FEATURES)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        file(GLOB osg_plugins "${CURRENT_PACKAGES_DIR}/plugins/${osg_plugins_subdir}/${osg_plugin_pattern}")
        file(INSTALL ${osg_plugins} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${osg_plugins_subdir}")
        if(NOT VCPKG_BUILD_TYPE)
            file(GLOB osg_plugins "${CURRENT_PACKAGES_DIR}/debug/plugins/${osg_plugins_subdir}/${osg_plugin_pattern}")
            file(INSTALL ${osg_plugins} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/${osg_plugins_subdir}")
        endif()
    endif()
    vcpkg_copy_tools(TOOL_NAMES osgearth_3pv osgearth_atlas osgearth_boundarygen osgearth_clamp
        osgearth_conv osgearth_imgui osgearth_overlayviewer osgearth_tfs osgearth_toc osgearth_version osgearth_viewer
        AUTO_CLEAN
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
