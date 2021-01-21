set(OSG_VER 3.6.5)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openscenegraph/OpenSceneGraph
    REF OpenSceneGraph-${OSG_VER}
    SHA512 7002fa30a3bcf6551d2e1050b4ca75a3736013fd190e4f50953717406864da1952deb09f530bc8c5ddf6e4b90204baec7dbc283f497829846d46d561f66feb4b
    HEAD_REF master
    PATCHES
        collada.patch
        static.patch
        fix-sdl.patch
        fix-example-application.patch
        disable-present3d-staticview-in-linux.patch #Due to some link error we cannot solve yet, disable them in linux.
        fix-curl.patch
        remove-prefix.patch # Remove this patch when cmake fix Findosg_functions.cmake
        fix-liblas.patch
        fix-nvtt.patch
        #use-boost-asio.patch
        fix-dependency-coin.patch
        osgdb_zip_nozip.patch # This is fix symbol clashes with other libs when built in static-lib mode
        disable-install-pdb.patch
        crosscompile.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(OSG_DYNAMIC OFF)
else()
    set(OSG_DYNAMIC ON)
endif()

file(REMOVE ${SOURCE_PATH}/CMakeModules/FindSDL2.cmake)

set(OSG_USE_UTF8_FILENAME ON)
if (NOT VCPKG_TARGET_IS_WINDOWS)
    message("Build osg requires gcc with version higher than 4.7.")
    # Enable OSG_USE_UTF8_FILENAME will call some windows-only functions.
    set(OSG_USE_UTF8_FILENAME OFF)
endif()

set(OPTIONS)

# Due to nvtt CRT linkage error, we can only enable static builds here
set(ENABLE_NVTT ON)
if (VCPKG_TARGET_IS_WINDOWS AND OSG_DYNAMIC)
    set(ENABLE_NVTT OFF)
endif()
list(APPEND OPTIONS -DENABLE_NVTT=${ENABLE_NVTT})

if (VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS -DOSG_TEXT_USE_FONTCONFIG=OFF)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tools BUILD_OSG_APPLICATIONS
    examples BUILD_OSG_EXAMPLES
    plugins BUILD_OSG_PLUGINS
    packages BUILD_OSG_PACKAGES
    docs BUILD_DOCUMENTATION
    docs BUILD_REF_DOCS_SEARCHENGINE
    docs BUILD_REF_DOCS_TAGFILE
    fontconfig OSG_TEXT_USE_FONTCONFIG
    nvtt ENABLE_NVTT
)

set(DISABLE_PACKAGES)
if(NOT "collada" IN_LIST FEATURES)
    list(APPEND DISABLE_PACKAGES COLLADA)
endif()
if(NOT "tools" IN_LIST FEATURES)
    list(APPEND DISABLE_PACKAGES EXPAT Iconv)
endif()
if(NOT "plugins" IN_LIST FEATURES)
    list(APPEND DISABLE_PACKAGES Boost coin SDL Jasper GDAL TIFF)
endif()
if(NOT "examples" IN_LIST FEATURES)
    list(APPEND DISABLE_PACKAGES SDL2)
endif()
if(NOT "freetype" IN_LIST FEATURES)
    list(APPEND DISABLE_PACKAGES Freetype)
endif()
if(NOT "curl" IN_LIST FEATURES)
    list(APPEND DISABLE_PACKAGES CURL)
endif()
if(NOT "sdl1" IN_LIST FEATURES)
    list(APPEND DISABLE_PACKAGES SDL)
endif()
if(NOT "jpeg" IN_LIST FEATURES)
    list(APPEND DISABLE_PACKAGES JPEG)
endif()
if(NOT "png" IN_LIST FEATURES)
    list(APPEND DISABLE_PACKAGES PNG)
endif()
if(NOT "nvtt" IN_LIST FEATURES)
    list(APPEND DISABLE_PACKAGES NVTT)
endif()
if(NOT "fontconfig" IN_LIST FEATURES)
    list(APPEND DISABLE_PACKAGES Fontconfig)
endif()

# pkg-config is required by FindFontconfig
vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    REQUIRE_ALL_PACKAGES
    DISABLE_PACKAGES wxWidgets liblas EGL FLTK GLIB Asio GtkGl DirectShow Poppler-glib GStreamer DCMTK FFmpeg ${DISABLE_PACKAGES}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DOSG_USE_UTF8_FILENAME=${OSG_USE_UTF8_FILENAME}
        -DDYNAMIC_OPENSCENEGRAPH=${OSG_DYNAMIC}
        -DDYNAMIC_OPENTHREADS=${OSG_DYNAMIC}
        -DBUILD_DASHBOARD_REPORTS=OFF
        -DCMAKE_CXX_STANDARD=11
        -DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}
         ${OPTIONS}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# handle osg tools and plugins
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

set(OSG_TOOL_PATH ${CURRENT_PACKAGES_DIR}/tools/${PORT})

file(GLOB OSG_TOOLS ${CURRENT_PACKAGES_DIR}/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX})
if (OSG_TOOLS)
    file(MAKE_DIRECTORY ${OSG_TOOL_PATH})
    file(COPY ${OSG_TOOLS} DESTINATION ${OSG_TOOL_PATH})
    file(REMOVE_RECURSE ${OSG_TOOLS})
    file(GLOB OSG_TOOLS_DBG ${CURRENT_PACKAGES_DIR}/debug/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    file(REMOVE_RECURSE ${OSG_TOOLS_DBG})
endif()
file(GLOB OSG_TOOLS ${CURRENT_PACKAGES_DIR}/share/OpenSceneGraph/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX})
if (OSG_TOOLS)
    file(COPY ${OSG_TOOLS} DESTINATION ${OSG_TOOL_PATH})
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/OpenSceneGraph)
endif()

file(GLOB OSG_PLUGINS_DBG
    ${CURRENT_PACKAGES_DIR}/debug/bin/osgPlugins-${OSG_VER}/*
    ${CURRENT_PACKAGES_DIR}/debug/lib/osgPlugins-${OSG_VER}/*
)
if (OSG_PLUGINS_DBG)
    file(COPY ${OSG_PLUGINS_DBG} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/osgPlugins-${OSG_VER})
endif()

file(GLOB OSG_PLUGINS_REL
    ${CURRENT_PACKAGES_DIR}/bin/osgPlugins-${OSG_VER}/*
    ${CURRENT_PACKAGES_DIR}/lib/osgPlugins-${OSG_VER}/*
)
if (OSG_PLUGINS_REL)
    if (NOT EXISTS ${OSG_TOOL_PATH})
        file(MAKE_DIRECTORY ${OSG_TOOL_PATH})
    endif()
    file(COPY ${OSG_PLUGINS_REL} DESTINATION ${OSG_TOOL_PATH}/osgPlugins-${OSG_VER})
endif()
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/bin/osgPlugins-${OSG_VER}/
    ${CURRENT_PACKAGES_DIR}/lib/osgPlugins-${OSG_VER}/
    ${CURRENT_PACKAGES_DIR}/debug/bin/osgPlugins-${OSG_VER}/
    ${CURRENT_PACKAGES_DIR}/debug/lib/osgPlugins-${OSG_VER}/
)

#Cleanup
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(GLOB_RECURSE HEADERS ${CURRENT_PACKAGES_DIR}/include/*)
    foreach(HEADER IN LISTS HEADERS)
        vcpkg_replace_string("${HEADER}" "__declspec(dllimport)" "")
    endforeach()
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
