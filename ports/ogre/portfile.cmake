include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OGRECave/ogre
    REF c14f8847f743f4dc1b3abc947b1725c87d8b10ce
    SHA512 a2fd7ffd653c1578bc860b58cf4c899f27cc967f75e2254dc3e372044f118d5951e42b35bfc711aa8996e1885f372d3cfa5a768b8674e0b3d844811990eb87fc
    HEAD_REF master
    PATCHES
        toolchain_fixes.patch
)

file(REMOVE "${SOURCE_PATH}/CMake/Packages/FindOpenEXR.cmake")

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
        -DOGRE_CONFIG_THREAD_PROVIDER=std
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
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(GLOB REL_CFGS ${CURRENT_PACKAGES_DIR}/bin/*.cfg)
if(REL_CFGS)
  file(COPY ${REL_CFGS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
  file(REMOVE ${REL_CFGS})
endif()

file(GLOB DBG_CFGS ${CURRENT_PACKAGES_DIR}/debug/bin/*.cfg)
if(DBG_CFGS)
  file(COPY ${DBG_CFGS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
  file(REMOVE ${DBG_CFGS})
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

if(NOT VCPKG_CMAKE_SYSTEM_NAME)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "Release")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib/manual-link)
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            file(RENAME ${CURRENT_PACKAGES_DIR}/lib/OgreMain.lib ${CURRENT_PACKAGES_DIR}/lib/manual-link/OgreMain.lib)
        else()
            file(RENAME ${CURRENT_PACKAGES_DIR}/lib/OgreMainStatic.lib ${CURRENT_PACKAGES_DIR}/lib/manual-link/OgreMainStatic.lib)
        endif()
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "Debug")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/OgreMain_d.lib ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/OgreMain_d.lib)
        else()
            file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/OgreMainStatic_d.lib ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/OgreMainStatic_d.lib)
        endif()
    endif()

    file(GLOB SHARE_FILES ${CURRENT_PACKAGES_DIR}/share/ogre/*.cmake)
    foreach(SHARE_FILE ${SHARE_FILES})
        file(READ "${SHARE_FILE}" _contents)
        string(REPLACE "lib/OgreMain" "lib/manual-link/OgreMain" _contents "${_contents}")
        file(WRITE "${SHARE_FILE}" "${_contents}")
    endforeach()
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ogre RENAME copyright)

vcpkg_copy_pdbs()
