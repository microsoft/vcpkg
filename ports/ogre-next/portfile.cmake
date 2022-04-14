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
    REF 10b56694f33fd6ead1c501eb90379bcac671d841 #v2.3.0
    SHA512 b2f1c55655582b2844b7c10cce965cc5268829a0702b09abcfe04fba8db00ad032f605d683c88811f77f9b7b4fb8a1095079f1a1c96bbe9fd022621f4ff4cf81 
    HEAD_REF master
    PATCHES
        toolchain_fixes.patch
        fix_find_package_sdl2.patch
)

file(REMOVE "${SOURCE_PATH}/CMake/Packages/FindOpenEXR.cmake")

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(OGRE_STATIC ON)
else()
    set(OGRE_STATIC OFF)
endif()


vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        d3d9    OGRE_BUILD_RENDERSYSTEM_D3D9
        java    OGRE_BUILD_COMPONENT_JAVA
        python  OGRE_BUILD_COMPONENT_PYTHON
        csharp  OGRE_BUILD_COMPONENT_CSHARP
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DOGRE_BUILD_DEPENDENCIES=OFF
        -DOGRE_COPY_DEPENDENCIES=OFF
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
        -DOGRE_INSTALL_VSPROPS=OFF
        -DOGRE_STATIC=${OGRE_STATIC}
        -DOGRE_CONFIG_THREAD_PROVIDER=std
        -DOGRE_BUILD_RENDERSYSTEM_D3D11=ON
        -DOGRE_BUILD_RENDERSYSTEM_GL=ON
        -DOGRE_BUILD_RENDERSYSTEM_GL3PLUS=ON
        -DOGRE_BUILD_RENDERSYSTEM_GLES=OFF
        -DOGRE_BUILD_RENDERSYSTEM_GLES2=OFF
        -DOGRE_CMAKE_DIR=share/ogre-next
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()



file(GLOB REL_CFGS "${CURRENT_PACKAGES_DIR}/bin/*.cfg")
if(REL_CFGS)
  file(COPY ${REL_CFGS} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
  file(REMOVE ${REL_CFGS})
endif()

file(GLOB DBG_CFGS "${CURRENT_PACKAGES_DIR}/debug/bin/*.cfg")
if(DBG_CFGS)
  file(COPY ${DBG_CFGS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
  file(REMOVE ${DBG_CFGS})
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

#Remove OgreMain*.lib from lib/ folder, because autolink would complain, since it defines a main symbol
#manual-link subfolder is here to the rescue!
if(VCPKG_TARGET_IS_WINDOWS)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "Release")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/manual-link")
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            file(RENAME "${CURRENT_PACKAGES_DIR}/lib/release/OgreMain.lib" "${CURRENT_PACKAGES_DIR}/lib/manual-link/OgreMain.lib")
        else()
            file(RENAME "${CURRENT_PACKAGES_DIR}/lib/release/OgreMainStatic.lib" "${CURRENT_PACKAGES_DIR}/lib/manual-link/OgreMainStatic.lib")
        endif()
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "Debug")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link")
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/debug/OgreMain_d.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/OgreMain_d.lib")
        else()
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/debug/OgreMainStatic_d.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/OgreMainStatic_d.lib")
        endif()
    endif()

    file(GLOB SHARE_FILES "${CURRENT_PACKAGES_DIR}/share/ogre-next/*.cmake")
    foreach(SHARE_FILE ${SHARE_FILES})
        file(READ "${SHARE_FILE}" _contents)
        string(REPLACE "lib/OgreMain" "lib/manual-link/OgreMain" _contents "${_contents}")
        file(WRITE "${SHARE_FILE}" "${_contents}")
    endforeach()
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
