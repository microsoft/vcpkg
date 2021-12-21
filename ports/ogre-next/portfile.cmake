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
    REF 0e0c47ed70091e7bdead5fb1ca01e1cae5857ef4 #v2.2.5
    SHA512 25b9903b0c30e7c1baa01bfc126c9fc8397ab74d40c21695c88d886df5db503c3239490143b7ff64ec6c8c3da89b90b5d3846bbe49219ca8778c2a6f234dbffc 
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


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
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
vcpkg_cmake_config_fixup()

file(GLOB REL_CFGS "${CURRENT_PACKAGES_DIR}/bin/*.cfg")
if(REL_CFGS)
  file(COPY "${REL_CFGS}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
  file(REMOVE "${REL_CFGS}")
endif()

file(GLOB DBG_CFGS "${CURRENT_PACKAGES_DIR}/debug/bin/*.cfg")
if(DBG_CFGS)
  file(COPY "${DBG_CFGS}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
  file(REMOVE "${DBG_CFGS}")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()
