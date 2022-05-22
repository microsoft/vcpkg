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
    REF 15d5340f174212d6f93ae55c0d9af606c3d361c0 #version 3.2
    SHA512 f922e8bbb041a498e948587f03e8dc8a07b92e641f38d50a8eafb8b3ce1e0c92bb1ee01360d57e794429912734b60cf05ba143445a442bc95af39e3dd9fc3670
    HEAD_REF master
    PATCHES
        StaticOSG.patch # Fix port compilation in static-md module
        make-all-find-packages-required.patch
        fix-dependency-osg.patch
        remove-tool-debug-suffix.patch
        fix-imgui.patch
        fix-gcc11-compilation.patch
        blend2d-fix.patch
)

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
        osgearth_conv osgearth_imgui osgearth_overlayviewer osgearth_tfs osgearth_toc osgearth_version osgearth_viewer
        AUTO_CLEAN
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
