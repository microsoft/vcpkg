# This portfile is based (shamelessly copied and adapted a bit) on 'ogre' portfile.

if (EXISTS "${CURRENT_INSTALLED_DIR}/Media/HLMS/Blendfunctions_piece_fs.glslt")
    message(FATAL_ERROR "FATAL ERROR: ogre-next and ogre are incompatible.")
endif()

if(NOT VCPKG_TARGET_IS_WINDOWS)
    message("${PORT} currently requires the following library from the system package manager:\n    Xaw\n\nIt can be installed on Ubuntu systems via apt-get install libxaw7-dev")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OGRECave/ogre-next
    REF 8083067c1835147de5d82015347d95c710e36bc0
    SHA512 2660f739def7076b42009ba932a27532f2a20e7be8ec2674aff29116c7dcd7f2d75564d8ce07bef3dba13ece5293d604573ad4f8734f6086c1750127f52834cd
    HEAD_REF master
    PATCHES
        toolchain_fixes.patch
        rename_config_cmake.patch
        fix_find_package_sdl2.patch
)

file(REMOVE "${SOURCE_PATH}/CMake/Packages/FindOpenEXR.cmake")

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(OGRE_STATIC ON)
else()
    set(OGRE_STATIC OFF)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    d3d9    OGRE_BUILD_RENDERSYSTEM_D3D9
    java    OGRE_BUILD_COMPONENT_JAVA
    python  OGRE_BUILD_COMPONENT_PYTHON
    csharp  OGRE_BUILD_COMPONENT_CSHARP
)

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
        ${FEATURE_OPTIONS}
# vcpkg specific stuff
        -DOGRE_CMAKE_DIR=share/ogre-next
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

#Remove OgreMain*.lib from lib/ folder, because autolink would complain, since it defines a main symbol
#manual-link subfolder is here to the rescue!
if(VCPKG_TARGET_IS_WINDOWS)
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

    file(GLOB SHARE_FILES ${CURRENT_PACKAGES_DIR}/share/ogre-next/*.cmake)
    foreach(SHARE_FILE ${SHARE_FILES})
        file(READ "${SHARE_FILE}" _contents)
        string(REPLACE "lib/OgreMain" "lib/manual-link/OgreMain" _contents "${_contents}")
        file(WRITE "${SHARE_FILE}" "${_contents}")
    endforeach()
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
