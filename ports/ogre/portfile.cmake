include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OGRECave/ogre
    REF v1.10.11
    SHA512 2dfedd6f0a0de1a8c687c001439138b233200ca11e5c9940debf43d8a0380ca6472e0b5f4d599f0e22ca2049d0a5d34066ef41b6bc4912130694fa5d851fc900
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/001-cmake-install-dir.patch"
)

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
        -DOGRE_CONFIG_THREAD_PROVIDER=std
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
# vcpkg specific stuff
        -DOGRE_CMAKE_DIR=share/ogre
)

vcpkg_install_cmake()

# Remove unwanted files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH share/ogre)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(GLOB REL_CFGS ${CURRENT_PACKAGES_DIR}/bin/*.cfg)
file(COPY ${REL_CFGS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(GLOB DBG_CFGS ${CURRENT_PACKAGES_DIR}/debug/bin/*.cfg)
file(COPY ${DBG_CFGS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(REMOVE ${REL_CFGS} ${DBG_CFGS})

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link ${CURRENT_PACKAGES_DIR}/lib/manual-link)

file(GLOB MAIN_REL ${CURRENT_PACKAGES_DIR}/lib/OgreMain.lib ${CURRENT_PACKAGES_DIR}/lib/OgreMainStatic.lib)
file(COPY ${MAIN_REL} DESTINATION ${CURRENT_PACKAGES_DIR}/lib/manual-link)
file(GLOB MAIN_DBG ${CURRENT_PACKAGES_DIR}/debug/lib/OgreMain_d.lib ${CURRENT_PACKAGES_DIR}/debug/lib/OgreMainStatic_d.lib)
file(COPY ${MAIN_DBG} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
file(REMOVE ${MAIN_REL} ${MAIN_DBG})

# Ogre installs custom cmake config files which don't follow the normal pattern.
# This normally makes them completely incompatible with multi-config generators, but with some effort it can be done.
file(READ "${CURRENT_PACKAGES_DIR}/share/ogre/OGREConfig.cmake" _contents)
string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${PACKAGE_PREFIX_DIR}" _contents "${_contents}")
string(REPLACE "SDL2main.lib" "SDL2main$<$<CONFIG:Debug>:d>.lib" _contents "${_contents}")
string(REPLACE "SDL2.lib" "SDL2$<$<CONFIG:Debug>:d>.lib" _contents "${_contents}")
string(REPLACE "\${PACKAGE_PREFIX_DIR}/lib" "\${PACKAGE_PREFIX_DIR}$<$<CONFIG:Debug>:/debug>/lib" _contents "${_contents}")
string(REPLACE "{OGRE_PREFIX_DIR}/lib" "{OGRE_PREFIX_DIR}$<$<CONFIG:Debug>:/debug>/lib" _contents "${_contents}")

string(REPLACE "\"Ogre\${COMPONENT}\"" "\"Ogre\${COMPONENT}$<$<CONFIG:Debug>:_d>\"" _contents "${_contents}")
string(REPLACE "\"Ogre\${COMPONENT}Static\"" "\"Ogre\${COMPONENT}Static$<$<CONFIG:Debug>:_d>\"" _contents "${_contents}")

string(REPLACE "\"\${TYPE}_\${COMPONENT}\"" "\"\${TYPE}_\${COMPONENT}$<$<CONFIG:Debug>:_d>\"" _contents "${_contents}")
string(REPLACE "\"\${TYPE}_\${COMPONENT}Static\"" "\"\${TYPE}_\${COMPONENT}Static$<$<CONFIG:Debug>:_d>\"" _contents "${_contents}")

string(REPLACE "\"OgreMain\"" "\"\${PACKAGE_PREFIX_DIR}/lib/manual-link/OgreMain$<$<CONFIG:Debug>:_d>.lib\"" _contents "${_contents}")
string(REPLACE "\"OgreMainStatic\"" "\"\${PACKAGE_PREFIX_DIR}/lib/manual-link/OgreMainStatic$<$<CONFIG:Debug>:_d>.lib\"" _contents "${_contents}")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/ogre/OGREConfig.cmake" "${_contents}")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ogre RENAME copyright)

vcpkg_copy_pdbs()
