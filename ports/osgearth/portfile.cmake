vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gwaldron/osgearth
    REF 15d5340f174212d6f93ae55c0d9af606c3d361c0 #version 3.2
    SHA512 f922e8bbb041a498e948587f03e8dc8a07b92e641f38d50a8eafb8b3ce1e0c92bb1ee01360d57e794429912734b60cf05ba143445a442bc95af39e3dd9fc3670
    HEAD_REF master
    PATCHES
        osgearth-library-static.patch
        link-libraries.patch
        use-unofficial-osg-config.patch
        find-package.patch
        remove-tool-debug-suffix.patch
        fix-gcc11-compilation.patch
        blend2d-fix.patch
)

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
