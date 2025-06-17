set(OSG_VER 3.6.5)

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO openscenegraph/OpenSceneGraph
	REF OpenSceneGraph-${OSG_VER}
	SHA512 7002fa30a3bcf6551d2e1050b4ca75a3736013fd190e4f50953717406864da1952deb09f530bc8c5ddf6e4b90204baec7dbc283f497829846d46d561f66feb4b
	HEAD_REF master
    PATCHES
        link-libraries.patch
        collada.patch
        fix-sdl.patch
        fix-nvtt-squish.patch
        plugin-pdb-install.patch
        osgdb_zip_nozip.patch # This is fix symbol clashes with other libs when built in static-lib mode
        openexr3.patch
        unofficial-export.patch
        fix-min-max-macro.patch
        fix-error-c3861.patch
        android.diff
)

file(REMOVE
    "${SOURCE_PATH}/CMakeModules/FindFontconfig.cmake"
    "${SOURCE_PATH}/CMakeModules/FindFreetype.cmake"
    "${SOURCE_PATH}/CMakeModules/Findilmbase.cmake"
    "${SOURCE_PATH}/CMakeModules/FindOpenEXR.cmake"
    "${SOURCE_PATH}/CMakeModules/FindSDL2.cmake"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" OSG_DYNAMIC)

set(OPTIONS "")
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS -DOSG_USE_UTF8_FILENAME=ON)
endif()
# Skip try_run checks
if(VCPKG_TARGET_IS_MINGW)
    list(APPEND OPTIONS -D_OPENTHREADS_ATOMIC_USE_WIN32_INTERLOCKED=0 -D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS=1)
elseif(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS -D_OPENTHREADS_ATOMIC_USE_WIN32_INTERLOCKED=1 -D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS=0)
elseif(VCPKG_TARGET_IS_IOS)
    # handled by osg
elseif(VCPKG_CROSSCOMPILING)
    message(WARNING "Atomics detection may fail for cross builds. You can set osg cmake variables in a custom triplet.")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools       BUILD_OSG_APPLICATIONS
        examples    BUILD_OSG_EXAMPLES
        plugins     BUILD_OSG_PLUGINS_BY_DEFAULT
        plugins     CMAKE_REQUIRE_FIND_PACKAGE_CURL
        plugins     CMAKE_REQUIRE_FIND_PACKAGE_Jasper
        plugins     CMAKE_REQUIRE_FIND_PACKAGE_GDAL
        plugins     CMAKE_REQUIRE_FIND_PACKAGE_GTA
        packages    BUILD_OSG_PACKAGES
        docs        BUILD_DOCUMENTATION
        docs        BUILD_REF_DOCS_SEARCHENGINE
        docs        BUILD_REF_DOCS_TAGFILE
        fontconfig  OSG_TEXT_USE_FONTCONFIG
        freetype    BUILD_OSG_PLUGIN_FREETYPE
        freetype    CMAKE_REQUIRE_FIND_PACKAGE_Freetype
        collada     BUILD_OSG_PLUGIN_DAE
        collada     CMAKE_REQUIRE_FIND_PACKAGE_COLLADA
        nvtt        BUILD_OSG_PLUGIN_NVTT
        nvtt        CMAKE_REQUIRE_FIND_PACKAGE_NVTT
        openexr     BUILD_OSG_PLUGIN_EXR
        openexr     CMAKE_REQUIRE_FIND_PACKAGE_OpenEXR
        sdl1        BUILD_OSG_PLUGIN_SDL
        sdl1        VCPKG_LOCK_FIND_PACKAGE_SDL
)

# The package osg can be configured to use different OpenGL profiles via a custom triplet file:
# Possible values are GLCORE, GL2, GL3, GLES1, GLES2, GLES3, and GLES2+GLES3
if(NOT DEFINED osg_OPENGL_PROFILE)
    set(osg_OPENGL_PROFILE "GL2")
    if(VCPKG_TARGET_IS_ANDROID)
        set(osg_OPENGL_PROFILE "GLES2")
    endif()
endif()

# Plugin control variables are used only if prerequisites are satisfied.
set(plugin_vars "")
file(STRINGS "${SOURCE_PATH}/src/osgPlugins/CMakeLists.txt" plugin_lines REGEX "ADD_PLUGIN_DIRECTORY")
foreach(line IN LISTS plugin_lines)
    if(NOT line MATCHES "ADD_PLUGIN_DIRECTORY\\(([^)]*)" OR NOT EXISTS "${SOURCE_PATH}/src/osgPlugins/${CMAKE_MATCH_1}/CMakeLists.txt")
        continue()
    endif()
    string(TOUPPER "${CMAKE_MATCH_1}" plugin_upper)
    list(APPEND plugin_vars "BUILD_OSG_PLUGIN_${plugin_upper}")
endforeach()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_DASHBOARD_REPORTS=OFF
        -DCMAKE_CXX_STANDARD=11
        -DCMAKE_POLICY_DEFAULT_CMP0057=NEW
        -DDYNAMIC_OPENSCENEGRAPH=${OSG_DYNAMIC}
        -DDYNAMIC_OPENTHREADS=${OSG_DYNAMIC}
        -DOPENGL_PROFILE=${osg_OPENGL_PROFILE}
        -DOSG_MSVC_VERSIONED_DLL=OFF
        -DOSG_DETERMINE_WIN_VERSION=OFF
        -DPKG_CONFIG_USE_CMAKE_PREFIX_PATH=ON
        -DUSE_3RDPARTY_BIN=OFF
        # Plugins
        -DBUILD_OSG_PLUGIN_DICOM=OFF
        -DBUILD_OSG_PLUGIN_DIRECTSHOW=OFF
        -DBUILD_OSG_PLUGIN_FBX=OFF
        -DBUILD_OSG_PLUGIN_INVENTOR=OFF
        -DBUILD_OSG_PLUGIN_LAS=OFF
        -DBUILD_OSG_PLUGIN_LUA=OFF
        -DBUILD_OSG_PLUGIN_OPENCASCADE=OFF
        -DBUILD_OSG_PLUGIN_QTKIT=OFF
        -DBUILD_OSG_PLUGIN_RESTHTTPDEVICE=OFF
        -DBUILD_OSG_PLUGIN_SVG=OFF
        -DBUILD_OSG_PLUGIN_VNC=OFF
        -DBUILD_OSG_PLUGIN_ZEROCONFDEVICE=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_FFmpeg=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_DCMTK=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_GStreamer=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_GLIB=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Inventor=ON
        ${OPTIONS}
    OPTIONS_DEBUG
        -DBUILD_OSG_APPLICATIONS=OFF
        -DBUILD_OSG_EXAMPLES=OFF
        -DBUILD_DOCUMENTATION=OFF
    MAYBE_UNUSED_VARIABLES
        BUILD_REF_DOCS_SEARCHENGINE
        BUILD_REF_DOCS_TAGFILE
        OSG_DETERMINE_WIN_VERSION
        USE_3RDPARTY_BIN
        ${plugin_vars}
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-osg-config.cmake" "${CURRENT_PACKAGES_DIR}/share/unofficial-osg/unofficial-osg-config.cmake" @ONLY)
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-osg)

# Add debug folder prefix for plugin targets. vcpkg_cmake_config_fixup only handles this for targets in bin/ and lib/.
set(osg_plugins_debug_targets "${CURRENT_PACKAGES_DIR}/share/unofficial-osg/osg-plugins-debug.cmake")
if(EXISTS "${osg_plugins_debug_targets}")
    file(READ "${osg_plugins_debug_targets}" contents)
    string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${_IMPORT_PREFIX}" contents "${contents}")
    string(REPLACE "\${_IMPORT_PREFIX}/plugins" "\${_IMPORT_PREFIX}/debug/plugins" contents "${contents}")
    file(WRITE "${osg_plugins_debug_targets}" "${contents}")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(APPEND "${CURRENT_PACKAGES_DIR}/include/osg/Config" "#ifndef OSG_LIBRARY_STATIC\n#define OSG_LIBRARY_STATIC 1\n#endif\n")
endif()

set(osg_plugins_subdir "osgPlugins-${OSG_VER}")
vcpkg_list(SET tools)
if("examples" IN_LIST FEATURES AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND tools osg2cpp osgshaderpipeline)
endif()
if("tools" IN_LIST FEATURES)
    list(APPEND tools osgversion present3D)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        list(APPEND tools osgviewer osgarchive osgconv osgfilecache)
    endif()
endif()
if(tools)
    set(osg_plugin_pattern "${VCPKG_TARGET_SHARED_LIBRARY_PREFIX}osgdb*${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}")
    file(GLOB osg_plugins "${CURRENT_PACKAGES_DIR}/plugins/${osg_plugins_subdir}/${osg_plugin_pattern}")
    if(NOT osg_plugins STREQUAL "")
        file(INSTALL ${osg_plugins} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${osg_plugins_subdir}")
    endif()
    vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/openscenegraph.pc" "\\\n" " ")
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/openscenegraph.pc" "\\\n" " ")
endif()
vcpkg_fixup_pkgconfig()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
