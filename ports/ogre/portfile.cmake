include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/sinbad-ogre-dd30349ea667)
vcpkg_download_distfile(ARCHIVE
    URLS "https://bitbucket.org/sinbad/ogre/get/v1-9-0.zip"
    FILENAME "ogre-v1-9-0.zip"
    SHA512 de7315a2450ecf0d9073e6a8f0c54737e041016f7ad820556d10701c7d23eefab9d3473476a8e95447c30ab21518b8e4cfb0271db72494ea67a3dea284c9a3d3
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/0001-use-vcpkg-freeimage.patch"
            "${CMAKE_CURRENT_LIST_DIR}/0002-ogre-cmake-dir-as-option.patch"
            "${CMAKE_CURRENT_LIST_DIR}/0003-use-flat-installation.patch"
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(OGRE_STATIC ON)
else()
    set(OGRE_STATIC OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DOGRE_USE_BOOST:BOOL=OFF 
            -DOGRE_BUILD_RENDERSYSTEM_D3D9:BOOL=OFF
            -DOGRE_INSTALL_DEPENDENCIES:BOOL=OFF
            -DOGRE_COPY_DEPENDENCIES:BOOL=OFF
            -DOGRE_BUILD_TOOLS:BOOL=OFF
            -DOGRE_CMAKE_DIR:STRING=share/ogre
            -DOGRE_STATIC:BOOL=${OGRE_STATIC}
            -DOGRE_INSTALL_SAMPLES:BOOL=OFF
            -DOGRE_INSTALL_TOOLS:BOOL=OFF
            # We disable this option because it is broken and we rely on vcpkg_copy_pdbs
            -DOGRE_INSTALL_PDB:BOOL=OFF
            -DOGRE_BUILD_DOCS:BOOL=OFF
            -DOGRE_INSTALL_DOCS:BOOL=OFF
            -DOGRE_INSTALL_SAMPLES_SOURCE:BOOL=OFF
            -DOGRE_NO_INSTALLATION_SUFFIXES_ON_WIN32:BOOL=ON
)

vcpkg_install_cmake()

# Add a OGREConfig.cmake to simplify the process of finding vcpkg OGRE
file(COPY ${CMAKE_CURRENT_LIST_DIR}/OGREConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/ogre)

# Remove debug includes
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Remove debug CMake files 
# Note that at the moment OGRE do not export imported targets, 
# so we do not need to copy the debug imported targets in the 
# release CMake path
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/ogre)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ogre/COPYING ${CURRENT_PACKAGES_DIR}/share/ogre/copyright)

vcpkg_copy_pdbs()