if(NOT VCPKG_TARGET_IS_IOS AND NOT VCPKG_TARGET_IS_OSX AND NOT VCPKG_TARGET_IS_WINDOWS)
    message("${PORT} currently requires the following library from the system package manager:\n    Xaw\n\nIt can be installed on Ubuntu systems via apt-get install libxaw7-dev")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OGRECave/ogre-next
    REF v${VERSION}
    SHA512 2ef8f16517c96cc7ddb31986857e4d0002e33c2eeff845b4af0b8e5848c3e92289dc3b10ededbe66fb63ef6234cbee88ed513466182bd4e70d710d0507f98418
    HEAD_REF master
    PATCHES
        toolchain_fixes.patch
        fix-dependencies.patch
)
file(REMOVE
    "${SOURCE_PATH}/CMake/Packages/FindFreeImage.cmake"
    "${SOURCE_PATH}/CMake/Packages/FindFreetype.cmake"
    "${SOURCE_PATH}/CMake/Packages/FindRapidjson.cmake"
    "${SOURCE_PATH}/CMake/Packages/FindVulkan.cmake"
    "${SOURCE_PATH}/CMake/Packages/FindZLIB.cmake"
    "${SOURCE_PATH}/CMake/Packages/FindZZip.cmake"
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        d3d11               OGRE_BUILD_RENDERSYSTEM_DirectX11
        d3d11               CMAKE_REQUIRE_FIND_PACKAGE_DirectX11
        gl3plus             OGRE_BUILD_RENDERSYSTEM_GL3PLUS
        gl3plus             CMAKE_REQUIRE_FIND_PACKAGE_OpenGL
        metal               OGRE_BUILD_RENDERSYSTEM_METAL
        planar-reflections  OGRE_BUILD_COMPONENT_PLANAR_REFLECTIONS
        vulkan              OGRE_BUILD_RENDERSYSTEM_VULKAN
        vulkan              CMAKE_REQUIRE_FIND_PACKAGE_Vulkan
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" OGRE_STATIC)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCMAKE_CXX_STANDARD=11
        -DCMAKE_DISABLE_FIND_PACKAGE_AMDAGS=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_CppUnit=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_GLSLOptimizer=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_HLSL2GLSL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenVR=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_POCO=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Remotery=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_RenderDoc=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_SDL2=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Softimage=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_TBB=ON
        -DCMAKE_POLICY_DEFAULT_CMP0072=NEW # Prefer GLVND
        -DOGRE_ARCHIVE_OUTPUT=lib
        -DOGRE_LIBRARY_OUTPUT=lib
        -DOGRE_BUILD_LIBS_AS_FRAMEWORKS=OFF
        -DOGRE_BUILD_MSVC_MP=ON
        -DOGRE_BUILD_MSVC_ZM=ON
        -DOGRE_BUILD_RENDERSYSTEM_GLES=OFF
        -DOGRE_BUILD_RENDERSYSTEM_GLES2=OFF
        -DOGRE_BUILD_SAMPLES2=OFF
        -DOGRE_BUILD_TESTS=OFF
        -DOGRE_BUILD_TOOLS=OFF
        -DOGRE_COPY_DEPENDENCIES=OFF
        -DOGRE_INSTALL_DEPENDENCIES=OFF
        -DOGRE_INSTALL_DOCS=OFF
        -DOGRE_INSTALL_PDB=OFF
        -DOGRE_INSTALL_SAMPLES=OFF
        -DOGRE_INSTALL_TOOLS=OFF
        -DOGRE_INSTALL_VSPROPS=OFF
        -DOGRE_STATIC=${OGRE_STATIC}
        -DOGRE_USE_NEW_PROJECT_NAME=ON
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_AMDAGS
        CMAKE_REQUIRE_FIND_PACKAGE_DirectX11
        OGRE_BUILD_MSVC_MP
        OGRE_BUILD_MSVC_ZM
        OGRE_BUILD_RENDERSYSTEM_DirectX11
        OGRE_COPY_DEPENDENCIES
        OGRE_INSTALL_DEPENDENCIES
        OGRE_INSTALL_VSPROPS
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_MINGW)
    vcpkg_fixup_pkgconfig()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
