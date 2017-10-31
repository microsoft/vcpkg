include(vcpkg_common_functions)

set(OGRE_VERSION 1.10.8)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/ogre-${OGRE_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/OGRECave/ogre/archive/v1.10.8.zip"
    FILENAME "ogre-1.10.8.zip"
    SHA512 c7d962fe7fb8c46a4e15bb6e2bb68c67f0cc2a0d04a8f53e03fb9572c76df3679dcd117137c6624f2f56a8eda108723817dbaa616ecb7dc4cfd6a644a6bc4356
)
vcpkg_extract_source_archive(${ARCHIVE})

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(OGRE_STATIC ON)
else()
    set(OGRE_STATIC OFF)
endif()

# Configure features

if("d3d9" IN_LIST FEATURES)
    set(WITH_D3D9 ON)
else()
    set(WITH_D3D9 OFF)
endif()

if("java" IN_LIST FEATURES)
    set(WITH_JAVA ON)
else()
    set(WITH_JAVA OFF)
endif()

if("python" IN_LIST FEATURES)
    set(WITH_PYTHON ON)
else()
    set(WITH_PYTHON OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DOGRE_BUILD_DEPENDENCIES=OFF
        -DOGRE_BUILD_SAMPLES=OFF
        -DOGRE_BUILD_TESTS=OFF
        -DOGRE_BUILD_TOOLS=OFF
        -DOGRE_BUILD_MSVC_MP=ON
        -DOGRE_BUILD_MSVC_ZM=ON
        -DOGRE_INSTALL_DEPENDENCIES=OFF
        -DOGRE_INSTALL_DOCS=OFF
        -DOGRE_INSTALL_PDB=OFF
        -DOGRE_INSTALL_SAMPLES=OFF
        -DOGRE_INSTALL_TOOLS=OFF
        -DOGRE_INSTALL_CMAKE=ON
        -DOGRE_INSTALL_VSPROPS=OFF
        -DOGRE_STATIC=${OGRE_STATIC}
        -DOGRE_UNITY_BUILD=OFF
        -DOGRE_USE_STD11=ON
        -DOGRE_NODE_STORAGE_LEGACY=OFF
        -DOGRE_BUILD_RENDERSYSTEM_D3D11=ON
        -DOGRE_BUILD_RENDERSYSTEM_GL=ON
        -DOGRE_BUILD_RENDERSYSTEM_GL3PLUS=ON
        -DOGRE_BUILD_RENDERSYSTEM_GLES=OFF
        -DOGRE_BUILD_RENDERSYSTEM_GLES2=OFF
# Optional stuff
        -DOGRE_BUILD_COMPONENT_JAVA=${WITH_JAVA}
        -DOGRE_BUILD_COMPONENT_PYTHON=${WITH_PYTHON}
        -DOGRE_BUILD_RENDERSYSTEM_D3D9=${WITH_D3D9}
)

vcpkg_install_cmake()

# Remove unwanted files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/CMake)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/ogre RENAME copyright)

# Move installed CMake scripts to share folder
file(RENAME ${CURRENT_PACKAGES_DIR}/CMake ${CURRENT_PACKAGES_DIR}/share/ogre/CMake)

vcpkg_copy_pdbs()
