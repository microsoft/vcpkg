# Only dynamic build need dlls
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(GLOB OSG_PLUGINS_SUBDIR ${CURRENT_INSTALLED_DIR}/tools/osg/osgPlugins-*)
    list(LENGTH OSG_PLUGINS_SUBDIR OSG_PLUGINS_SUBDIR_LENGTH)
    if(NOT OSG_PLUGINS_SUBDIR_LENGTH EQUAL 1)
        message(FATAL_ERROR "Could not determine osg version")
    endif()
    string(REPLACE "${CURRENT_INSTALLED_DIR}/tools/osg/" "" OSG_PLUGINS_SUBDIR "${OSG_PLUGINS_SUBDIR}")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gwaldron/osgearth
    REF 342fcadf4c8892ba84841cb5b4162bdc51519e3c #version 3.1
    SHA512 03378a918306846d2144e545785c783b01e33fa2dd5c77d16d390a275217b6ce7a3a743c35ae99a497b272a7516b055442c0a891bd312cce727a5538b40364f5
    HEAD_REF master
    PATCHES 
        StaticOSG.patch # Fix port compilation in static-md module
        deprecated_cpp_fix.patch # Fix port headers to not use classes deprecated in c++17. Gives errors when using the installed port headers
        make-all-find-packages-required.patch
        fix-dependencies.patch
        fix-dependency-osg.patch
        remove-tool-debug-suffix.patch
)

# Upstream bug, see https://github.com/gwaldron/osgearth/issues/1002
file(REMOVE ${SOURCE_PATH}/src/osgEarth/tinyxml.h)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tools OSGEARTH_BUILD_TOOLS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
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

vcpkg_install_cmake()

if (WIN32 AND (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic))
    #Release
    set(OSGEARTH_TOOL_PATH ${CURRENT_PACKAGES_DIR}/tools/${PORT})
    set(OSGEARTH_TOOL_PLUGIN_PATH ${OSGEARTH_TOOL_PATH}/${OSG_PLUGINS_SUBDIR})

    file(MAKE_DIRECTORY ${OSGEARTH_TOOL_PLUGIN_PATH})
    file(GLOB OSGDB_PLUGINS ${CURRENT_PACKAGES_DIR}/bin/${OSG_PLUGINS_SUBDIR}/osgdb*.dll)

    file(COPY ${OSGDB_PLUGINS} DESTINATION ${OSGEARTH_TOOL_PLUGIN_PATH})
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/${OSG_PLUGINS_SUBDIR})

    #Debug
    set(OSGEARTH_DEBUG_TOOL_PATH ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT})
    set(OSGEARTH_DEBUG_TOOL_PLUGIN_PATH ${OSGEARTH_DEBUG_TOOL_PATH}/${OSG_PLUGINS_SUBDIR})

    file(MAKE_DIRECTORY ${OSGEARTH_DEBUG_TOOL_PLUGIN_PATH})

    file(GLOB OSGDB_DEBUG_PLUGINS ${CURRENT_PACKAGES_DIR}/debug/bin/${OSG_PLUGINS_SUBDIR}/osgdb*.dll)

    file(COPY ${OSGDB_DEBUG_PLUGINS} DESTINATION ${OSGEARTH_DEBUG_TOOL_PLUGIN_PATH})

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/${OSG_PLUGINS_SUBDIR})
endif()

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES osgearth_3pv osgearth_atlas osgearth_boundarygen osgearth_clamp
        osgearth_conv osgearth_overlayviewer osgearth_tfs osgearth_toc osgearth_version osgearth_viewer
        AUTO_CLEAN
    )
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
