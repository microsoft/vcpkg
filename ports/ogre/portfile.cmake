if (EXISTS "${CURRENT_INSTALLED_DIR}/Media/HLMS/Blendfunctions_piece_fs.glslt")
    message(FATAL_ERROR "FATAL ERROR: ogre-next and ogre are incompatible.")
endif()

if(NOT VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_OSX)
    message("${PORT} currently requires the following library from the system package manager:\n    Xaw\n\nIt can be installed on Ubuntu systems via apt-get install libxaw7-dev")
endif()

if(VCPKG_TARGET_IS_ANDROID OR VCPKG_TARGET_IS_IOS OR VCPKG_TARGET_IS_EMSCRIPTEN)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OGRECave/ogre
    REF v13.4.4
    SHA512 59e0929f5022b2d289030d42c651ce4f44a215be7aae262b1b6919e1d00225d226cce6bfa2e78525ae902290615c87eabe7b8dfe27b7087dd56081460bd35e1f
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
        cfg-rel-paths.patch
        swig-python-polyfill.patch
        pkgconfig.patch
)

file(REMOVE "${SOURCE_PATH}/CMake/Packages/FindOpenEXR.cmake")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" OGRE_STATIC)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" OGRE_CONFIG_STATIC_LINK_CRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    assimp   OGRE_BUILD_PLUGIN_ASSIMP
    assimp   CMAKE_REQUIRE_FIND_PACKAGE_assimp
    bullet   OGRE_BUILD_COMPONENT_BULLET
    bullet   CMAKE_REQUIRE_FIND_PACKAGE_Bullet
    d3d9     OGRE_BUILD_RENDERSYSTEM_D3D9
    freeimage OGRE_BUILD_PLUGIN_FREEIMAGE
    freeimage CMAKE_REQUIRE_FIND_PACKAGE_FreeImage
    java     OGRE_BUILD_COMPONENT_JAVA
    java     CMAKE_REQUIRE_FIND_PACKAGE_SWIG
    openexr  OGRE_BUILD_PLUGIN_EXRCODEC
    openexr  CMAKE_REQUIRE_FIND_PACKAGE_OpenEXR
    python   OGRE_BUILD_COMPONENT_PYTHON
    python   CMAKE_REQUIRE_FIND_PACKAGE_Python3
    python   CMAKE_REQUIRE_FIND_PACKAGE_SWIG
    csharp   OGRE_BUILD_COMPONENT_CSHARP
    csharp   CMAKE_REQUIRE_FIND_PACKAGE_SWIG
    overlay  OGRE_BUILD_COMPONENT_OVERLAY
    overlay  CMAKE_REQUIRE_FIND_PACKAGE_FREETYPE
    zip      OGRE_CONFIG_ENABLE_ZIP
    strict   OGRE_RESOURCEMANAGER_STRICT
    tools    OGRE_BUILD_TOOLS
    tools    OGRE_INSTALL_TOOLS
)

if(CMAKE_REQUIRE_FIND_PACKAGE_SWIG)
    vcpkg_find_acquire_program(SWIG)
    vcpkg_list(APPEND FEATURE_OPTIONS "-DSWIG_EXECUTABLE=${SWIG}")
endif()

# OGRE_RESOURCEMANAGER_STRICT need to be 0 for OFF and 1 for ON, because it is used 'as is' in sources
string(REPLACE "OGRE_RESOURCEMANAGER_STRICT=ON" "OGRE_RESOURCEMANAGER_STRICT=1" FEATURE_OPTIONS "${FEATURE_OPTIONS}")
string(REPLACE "OGRE_RESOURCEMANAGER_STRICT=OFF" "OGRE_RESOURCEMANAGER_STRICT=0" FEATURE_OPTIONS "${FEATURE_OPTIONS}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DOGRE_CFG_INSTALL_PATH=etc/${PORT}
        -DOGRE_CMAKE_DIR=share/${PORT}
        -DOGRE_MEDIA_PATH=share/${PORT}/Media
        -DOGRE_PLUGINS_PATH=plugins/${PORT}
        -DOGRE_BUILD_DEPENDENCIES=OFF
        -DOGRE_BUILD_LIBS_AS_FRAMEWORKS=OFF
        -DOGRE_BUILD_SAMPLES=OFF
        -DOGRE_BUILD_TESTS=OFF
        -DOGRE_BUILD_MSVC_MP=ON
        -DOGRE_BUILD_MSVC_ZM=ON
        -DOGRE_COPY_DEPENDENCIES=OFF
        -DOGRE_ENABLE_PRECOMPILED_HEADERS=OFF
        -DOGRE_INSTALL_DEPENDENCIES=OFF
        -DOGRE_INSTALL_DOCS=OFF
        -DOGRE_INSTALL_PDB=OFF
        -DOGRE_INSTALL_SAMPLES=OFF
        -DOGRE_INSTALL_VSPROPS=OFF
        -DOGRE_STATIC=${OGRE_STATIC}
        -DOGRE_CONFIG_STATIC_LINK_CRT=${OGRE_CONFIG_STATIC_LINK_CRT}
        -DOGRE_CONFIG_THREAD_PROVIDER=std
        -DOGRE_BUILD_RENDERSYSTEM_D3D11=ON
        -DOGRE_BUILD_RENDERSYSTEM_GL=ON
        -DOGRE_BUILD_RENDERSYSTEM_GL3PLUS=ON
        -DOGRE_BUILD_RENDERSYSTEM_GLES=OFF
        -DOGRE_BUILD_RENDERSYSTEM_GLES2=OFF
        -DCMAKE_REQUIRE_FIND_PACKAGE_ZLIB=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_QT=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt5=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6=ON
    OPTIONS_DEBUG
        -DOGRE_BUILD_TOOLS=OFF
        -DOGRE_INSTALL_TOOLS=OFF
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_Qt5
        CMAKE_DISABLE_FIND_PACKAGE_Qt6
        CMAKE_REQUIRE_FIND_PACKAGE_OpenEXR
        OGRE_COPY_DEPENDENCIES
        OGRE_BUILD_MSVC_MP
        OGRE_BUILD_MSVC_ZM
        OGRE_BUILD_RENDERSYSTEM_GLES
        OGRE_INSTALL_DEPENDENCIES
        OGRE_INSTALL_VSPROPS
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()


if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/etc/${PORT}/resources.cfg" "=../../share" "=../../../share")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/etc/${PORT}/resources.cfg" "[Tests]\nFileSystem=${CURRENT_PACKAGES_DIR}/debug/Tests/Media" "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/OgreTargets-debug.cmake" "${_IMPORT_PREFIX}/plugins" "${_IMPORT_PREFIX}/debug/plugins")
endif()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/etc/${PORT}/resources.cfg" "[Tests]\nFileSystem=${CURRENT_PACKAGES_DIR}/Tests/Media" "")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/etc/ogre/samples.cfg"
    "${CURRENT_PACKAGES_DIR}/debug/etc/ogre/samples.cfg"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

set(tools OgreMeshUpgrader OgreXMLConverter VRMLConverter)
if(OGRE_BUILD_PLUGIN_ASSIMP)
    list(APPEND tools OgreAssimpConverter)
endif()
if(OGRE_BUILD_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)
endif()

#Remove OgreMain*.lib from lib/ folder, because autolink would complain, since it defines a main symbol
#manual-link subfolder is here to the rescue!
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/manual-link")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/OgreMain.lib" "${CURRENT_PACKAGES_DIR}/lib/manual-link/OgreMain.lib")
    else()
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/OgreMainStatic.lib" "${CURRENT_PACKAGES_DIR}/lib/manual-link/OgreMainStatic.lib")
    endif()
    if(NOT VCPKG_BUILD_TYPE)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link")
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/OgreMain_d.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/OgreMain_d.lib")
        else()
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/OgreMainStatic_d.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/OgreMainStatic_d.lib")
        endif()
    endif()

    file(GLOB SHARE_FILES "${CURRENT_PACKAGES_DIR}/share/ogre/*.cmake")
    foreach(SHARE_FILE ${SHARE_FILES})
        file(READ "${SHARE_FILE}" _contents)
        string(REPLACE "lib/OgreMain" "lib/manual-link/OgreMain" _contents "${_contents}")
        file(WRITE "${SHARE_FILE}" "${_contents}")
    endforeach()
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
