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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DOSG_USE_UTF8_FILENAME=${OSG_USE_UTF8_FILENAME}
        -DDYNAMIC_OPENSCENEGRAPH=${OSG_DYNAMIC}
        -DDYNAMIC_OPENTHREADS=${OSG_DYNAMIC}
        -DBUILD_OSG_PLUGINS=ON # it should always be ON due to osgerath need this
        -DBUILD_OSG_EXAMPLES=ON
        -DBUILD_OSG_APPLICATIONS=ON
        -DCMAKE_CXX_STANDARD=11
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# handle osg tools and plugins
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

set(OSG_TOOL_PATH ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(MAKE_DIRECTORY ${OSG_TOOL_PATH})

file(GLOB OSG_TOOLS ${CURRENT_PACKAGES_DIR}/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX})
file(COPY ${OSG_TOOLS} DESTINATION ${OSG_TOOL_PATH})
file(REMOVE_RECURSE ${OSG_TOOLS})
file(GLOB OSG_TOOLS_DBG ${CURRENT_PACKAGES_DIR}/debug/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX})
file(REMOVE_RECURSE ${OSG_TOOLS_DBG})

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(GLOB OSG_PLUGINS_DBG ${CURRENT_PACKAGES_DIR}/debug/bin/osgPlugins-${OSG_VER}/*${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX})
    file(COPY ${OSG_PLUGINS_DBG} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/osgPlugins-${OSG_VER})
    file(GLOB OSG_PLUGINS_REL ${CURRENT_PACKAGES_DIR}/bin/osgPlugins-${OSG_VER}/*${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX})
    file(COPY ${OSG_PLUGINS_REL} DESTINATION ${OSG_TOOL_PATH}/osgPlugins-${OSG_VER})
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/osgPlugins-${OSG_VER}/ ${CURRENT_PACKAGES_DIR}/debug/bin/osgPlugins-${OSG_VER}/)
endif()

file(GLOB OSG_PLUGINS_DBG ${CURRENT_PACKAGES_DIR}/debug/lib/osgPlugins-${OSG_VER}/*${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
file(COPY ${OSG_PLUGINS_DBG} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/osgPlugins-${OSG_VER})
file(GLOB OSG_PLUGINS_REL ${CURRENT_PACKAGES_DIR}/lib/osgPlugins-${OSG_VER}/*${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
file(COPY ${OSG_PLUGINS_REL} DESTINATION ${OSG_TOOL_PATH}/osgPlugins-${OSG_VER})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/osgPlugins-${OSG_VER}/ ${CURRENT_PACKAGES_DIR}/debug/lib/osgPlugins-${OSG_VER}/)

#Cleanup
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/osgPlugins-${OSG_VER}/)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)