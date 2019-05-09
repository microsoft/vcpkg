include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO openscenegraph/OpenSceneGraph
	REF OpenSceneGraph-3.6.2
	SHA512 6949dd4dea9dcffe4228086b72eafdb253bf1403b3b7a70a4727848c3cde23ad0270f41b1c3e2bdbfd410ec067ecce2052a5d26c61b032b6d46ce84b8c931bfb
	HEAD_REF master
    PATCHES
        collada.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(OSG_DYNAMIC OFF)
else()
    set(OSG_DYNAMIC ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DOSG_USE_UTF8_FILENAME=ON
)

vcpkg_install_cmake()

# handle osg tools and plugins
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

set(OSG_TOOL_PATH ${CURRENT_PACKAGES_DIR}/tools/osg)
file(MAKE_DIRECTORY ${OSG_TOOL_PATH})

file(GLOB OSG_TOOLS ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(COPY ${OSG_TOOLS} DESTINATION ${OSG_TOOL_PATH})
file(REMOVE_RECURSE ${OSG_TOOLS})
file(GLOB OSG_TOOLS_DBG ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(REMOVE_RECURSE ${OSG_TOOLS_DBG})

file(GLOB OSG_PLUGINS_DBG ${CURRENT_PACKAGES_DIR}/debug/bin/osgPlugins-3.6.2/*.dll)
file(COPY ${OSG_PLUGINS_DBG} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/osg/osgPlugins-3.6.2)
file(GLOB OSG_PLUGINS_REL ${CURRENT_PACKAGES_DIR}/bin/osgPlugins-3.6.2/*.dll)
file(COPY ${OSG_PLUGINS_REL} DESTINATION ${OSG_TOOL_PATH}/osgPlugins-3.6.2)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/osgPlugins-3.6.2/)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/osgPlugins-3.6.2/)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/osg)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/osg/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/osg/copyright)

#Cleanup
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()