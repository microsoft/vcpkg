if(NOT VCPKG_TARGET_IS_WINDOWS)
    message("${PORT} currently requires the following library from the system package manager:\n    Xaw\n\nIt can be installed on Ubuntu systems via apt-get install libxaw7-dev")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OGRECave/ogre-next
    REF v${VERSION}
    SHA512 fbc1969244db07d013118fbce12b319e83cdae93a822cb2d90bbd12108ac3ce48d1f5437b4375b3daf5640b9ec6f1764daeef742161a101f77c3e25ccaf4b154
    HEAD_REF master
    PATCHES
        toolchain_fixes.patch
        avoid-name-clashes.patch
        fix-error-c2039.patch
        fix-dependencies.patch
        fix-pc-file.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(OGRE_STATIC ON)
else()
    set(OGRE_STATIC OFF)
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        planar-reflections  OGRE_BUILD_COMPONENT_PLANAR_REFLECTIONS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DOGRE_COPY_DEPENDENCIES=OFF
        -DOGRE_BUILD_SAMPLES2=OFF
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
        -DOGRE_USE_NEW_PROJECT_NAME=ON
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

#Remove OgreNextMain*.lib from lib/ folder, because autolink would complain, since it defines a main symbol
#manual-link subfolder is here to the rescue!
if(VCPKG_TARGET_IS_WINDOWS)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "Release")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/manual-link")
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            file(RENAME "${CURRENT_PACKAGES_DIR}/lib/release/OgreNextMain.lib" "${CURRENT_PACKAGES_DIR}/lib/manual-link/OgreNextMain.lib")
        else()
            file(RENAME "${CURRENT_PACKAGES_DIR}/lib/release/OgreNextMainStatic.lib" "${CURRENT_PACKAGES_DIR}/lib/manual-link/OgreNextMainStatic.lib")
        endif()
        file(GLOB LIBS "${CURRENT_PACKAGES_DIR}/lib/release/*")
        file(GLOB DLLS "${CURRENT_PACKAGES_DIR}/bin/release/*")
        file(COPY ${LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        file(COPY ${DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/release/" "${CURRENT_PACKAGES_DIR}/bin/release/")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "Debug")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link")
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/debug/OgreNextMain_d.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/OgreNextMain_d.lib")
        else()
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/debug/OgreNextMainStatic_d.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/OgreNextMainStatic_d.lib")
        endif()
        file(GLOB LIBS "${CURRENT_PACKAGES_DIR}/debug/lib/debug/*")
        file(GLOB DLLS "${CURRENT_PACKAGES_DIR}/debug/bin/debug/*")
        file(COPY ${LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        file(COPY ${DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/debug/" "${CURRENT_PACKAGES_DIR}/debug/bin/debug/")
    endif()

    file(GLOB SHARE_FILES "${CURRENT_PACKAGES_DIR}/share/ogre-next/*.cmake")
    foreach(SHARE_FILE ${SHARE_FILES})
        file(READ "${SHARE_FILE}" _contents)
        string(REPLACE "lib/OgreNextMain" "lib/manual-link/OgreNextMain" _contents "${_contents}")
        file(WRITE "${SHARE_FILE}" "${_contents}")
    endforeach()
endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()
