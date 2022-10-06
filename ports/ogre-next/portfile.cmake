# This portfile is based (shamelessly copied and adapted a bit) on 'ogre' portfile.
if (EXISTS "${CURRENT_INSTALLED_DIR}/Media/HLMS/Blendfunctions_piece_fs.glslt")
    message(FATAL_ERROR "FATAL ERROR: ogre-next and ogre are incompatible.")
endif()

if(NOT VCPKG_TARGET_IS_WINDOWS)
    message("${PORT} currently requires the following library from the system package manager:\n    Xaw\n\nIt can be installed on Ubuntu systems via apt-get install libxaw7-dev")
endif()

if(VCPKG_TARGET_IS_ANDROID OR VCPKG_TARGET_IS_IOS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OGRECave/ogre-next
    REF e4c5f0f6d36c07af594e3ef143d017bda1581442 #v2.3.1
    SHA512 263a50b64defa7345a109a068cc17c347a696f83f64abc071256bb46571ed6b2ef94ee3480d90938cdb7f745d36a4c4890d82677d357c62c9a2956eae8d4ac15
    HEAD_REF master
    PATCHES
        toolchain_fixes.patch
        fix-dependencies.patch
        fix-cmake-feature-summary.patch # ogre-next/cmake conflict hit by SDL2 config
        #fix-sources.patch
)

file(REMOVE
    "${SOURCE_PATH}/CMake/Packages/FindFreeImage.cmake"
    "${SOURCE_PATH}/CMake/Packages/FindFreetype.cmake"
    "${SOURCE_PATH}/CMake/Packages/FindOpenEXR.cmake"
    "${SOURCE_PATH}/CMake/Packages/FindSDL2.cmake"
    "${SOURCE_PATH}/CMake/Packages/FindZLIB.cmake"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" OGRE_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOGRE_CMAKE_DIR=share/ogre-next
        -DOGRE_COPY_DEPENDENCIES=OFF
        -DOGRE_BUILD_LIBS_AS_FRAMEWORKS=OFF
        -DOGRE_BUILD_MSVC_MP=ON
        -DOGRE_BUILD_MSVC_ZM=ON
        -DOGRE_BUILD_RENDERSYSTEM_D3D11=ON
        -DOGRE_BUILD_RENDERSYSTEM_GL=ON
        -DOGRE_BUILD_RENDERSYSTEM_GL3PLUS=ON
        -DOGRE_BUILD_RENDERSYSTEM_GLES=OFF
        -DOGRE_BUILD_RENDERSYSTEM_GLES2=OFF
        -DOGRE_BUILD_SAMPLES2=OFF
        -DOGRE_BUILD_TESTS=OFF
        -DOGRE_BUILD_TOOLS=OFF
        -DOGRE_CONFIG_THREAD_PROVIDER=boost
        -DOGRE_INSTALL_DEPENDENCIES=OFF
        -DOGRE_INSTALL_DOCS=OFF
        -DOGRE_INSTALL_PDB=OFF
        -DOGRE_INSTALL_SAMPLES=OFF
        -DOGRE_INSTALL_TOOLS=OFF
        -DOGRE_INSTALL_VSPROPS=OFF
        -DOGRE_STATIC=${OGRE_STATIC}
        -DOpenVR_FOUND=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_CppUnit=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_POCO=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_RenderDoc=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_TBB=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_TinyXML=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_Boost=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_OpenVR=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_Rapidjson=ON
    MAYBE_UNUSED_VARIABLES
        OGRE_BUILD_MSVC_MP
        OGRE_BUILD_MSVC_ZM
        OGRE_COPY_DEPENDENCIES
        OGRE_INSTALL_DEPENDENCIES
        OGRE_INSTALL_VSPROPS
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
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
