set(OSG_VER 3.6.4)

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO openscenegraph/OpenSceneGraph
	REF OpenSceneGraph-${OSG_VER}
	SHA512 7cb34fc279ba62a7d7177d3f065f845c28255688bd29026ffb305346e1bb2e515a22144df233e8a7246ed392044ee3e8b74e51bf655282d33ab27dcaf12f4b19
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
if(NOT "collada" IN_LIST FEATURES)
    list(APPEND OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_COLLADA=ON)
endif()
list(APPEND OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_FFmpeg=ON)
list(APPEND OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_DCMTK=ON)
list(APPEND OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_GStreamer=ON)
list(APPEND OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_GLIB=ON)
list(APPEND OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_SDL=ON)
list(APPEND OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_LIBLAS=ON)

# Due to nvtt CRT linkage error, we can only enable static builds here
set(ENABLE_NVTT ON)
if (VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL dymanic)
    set(ENABLE_NVTT OFF)
endif()
list(APPEND OPTIONS -DENABLE_NVTT=${ENABLE_NVTT})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tools BUILD_OSG_APPLICATIONS
    examples BUILD_OSG_EXAMPLES
    plugins BUILD_OSG_PLUGINS
    packages BUILD_OSG_PACKAGES
    docs BUILD_DOCUMENTATION
    docs BUILD_REF_DOCS_SEARCHENGINE
    docs BUILD_REF_DOCS_TAGFILE
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS}
        -DOSG_USE_UTF8_FILENAME=${OSG_USE_UTF8_FILENAME}
        -DDYNAMIC_OPENSCENEGRAPH=${OSG_DYNAMIC}
        -DDYNAMIC_OPENTHREADS=${OSG_DYNAMIC}
        -DBUILD_DASHBOARD_REPORTS=OFF
        -DCMAKE_CXX_STANDARD=11
         ${OPTIONS}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# handle osg tools and plugins
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

set(OSG_TOOL_PATH ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(MAKE_DIRECTORY ${OSG_TOOL_PATH})

file(GLOB OSG_TOOLS ${CURRENT_PACKAGES_DIR}/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX})
if (OSG_TOOLS)
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


if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(GLOB OSG_PLUGINS_DBG ${CURRENT_PACKAGES_DIR}/debug/bin/osgPlugins-${OSG_VER}/*)
    if (OSG_PLUGINS_DBG)
        file(COPY ${OSG_PLUGINS_DBG} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/osgPlugins-${OSG_VER})
    endif()
    file(GLOB OSG_PLUGINS_REL ${CURRENT_PACKAGES_DIR}/bin/osgPlugins-${OSG_VER}/*)
    if (OSG_PLUGINS_REL)
        file(COPY ${OSG_PLUGINS_REL} DESTINATION ${OSG_TOOL_PATH}/osgPlugins-${OSG_VER})
    endif()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/osgPlugins-${OSG_VER}/ ${CURRENT_PACKAGES_DIR}/debug/bin/osgPlugins-${OSG_VER}/)
endif()

file(GLOB OSG_PLUGINS_DBG ${CURRENT_PACKAGES_DIR}/debug/bin/osgPlugins-${OSG_VER}/*)
if (OSG_PLUGINS_DBG)
    file(COPY ${OSG_PLUGINS_DBG} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/osgPlugins-${OSG_VER})
endif()

file(GLOB OSG_PLUGINS_REL ${CURRENT_PACKAGES_DIR}/bin/osgPlugins-${OSG_VER}/*)
if (OSG_PLUGINS_REL)
    file(COPY ${OSG_PLUGINS_REL} DESTINATION ${OSG_TOOL_PATH}/osgPlugins-${OSG_VER})
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/osgPlugins-${OSG_VER}/ ${CURRENT_PACKAGES_DIR}/debug/bin/osgPlugins-${OSG_VER}/)

#Cleanup
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/osgPlugins-${OSG_VER}/)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)