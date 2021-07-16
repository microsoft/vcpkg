vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO urho3d/Urho3D
    REF fff115a0c0cd50b8a34dfa20b4c5f33eb4f765c8
    SHA512 4bddcd1d4165b74134a499616710c382d0463db24382aaa3111b8b38e82818053144d4ecb0ba7156589da1e18d85c0f20e0d847237291685ea80957f0bf7f8be
    HEAD_REF master
    PATCHES
        asm_files.patch
        macosx.patch
        shared_libs.patch
        externalproject.patch
        add_options.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(URHO3D_LIB_TYPE "STATIC")
else()
    set(URHO3D_LIB_TYPE "SHARED")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools       URHO3D_BUILD_TOOLS
        examples    URHO3D_BUILD_SAMPLES
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DURHO3D_LIB_TYPE=${URHO3D_LIB_TYPE}
        -DURHO3D_C++11=ON
        -DURHO3D_PCH=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

if(EXISTS ${CURRENT_PACKAGES_DIR}/share/Urho3D/CMake/Modules)
    vcpkg_cmake_config_fixup(CONFIG_PATH share/Urho3D/CMake/Modules)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/share/CMake/Modules)
    vcpkg_cmake_config_fixup(CONFIG_PATH share/CMake/Modules)
endif()

# Handle tools
if ("tools" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_ANDROID)
    vcpkg_copy_tools(TOOL_NAMES AssetImporter OgreImporter PackageTool RampGenerator ScriptCompiler SpritePacker
        SEARCH_DIR ${CURRENT_PACKAGES_DIR}/bin/tool
        AUTO_CLEAN
    )
    
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/tool ${CURRENT_PACKAGES_DIR}/debug/bin/tool)
    
    vcpkg_copy_tools(TOOL_NAMES luajit Urho3DPlayer AUTO_CLEAN)
    
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/Urho3DPlayer_d${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/jit ${CURRENT_PACKAGES_DIR}/tools/${PORT}/jit)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/jit)
endif()

# Handle examples
if ("examples" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_ANDROID)
    file(GLOB URHO3D_BINARIES ${CURRENT_PACKAGES_DIR}/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    foreach(URHO3D_BINARY ${URHO3D_BINARIES})
        get_filename_component(BINARY_NAME ${URHO3D_BINARY} NAME_WE)
        if (BINARY_NAME MATCHES "[0-9][0-9]\_.+")
            list(APPEND URHO3D_TOOLS ${BINARY_NAME})
        endif()
    endforeach()
    vcpkg_copy_tools(TOOL_NAMES ${URHO3D_TOOLS} AUTO_CLEAN)
    
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        foreach(URHO3D_TOOL IN_LIST ${URHO3D_TOOLS})
            file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/${URHO3D_TOOL}_d${VCPKG_TARGET_EXECUTABLE_SUFFIX})
        endforeach()
    endif()
endif()

list(APPEND SDL_RELATED_HEADERS
    "${CURRENT_PACKAGES_DIR}/include/Urho3D/Input/InputConstants.h"
    "${CURRENT_PACKAGES_DIR}/include/Urho3D/Input/NamedPipe.h"
    "${CURRENT_PACKAGES_DIR}/include/Urho3D/Input/RWOpsWrapper.h"
)
foreach (SDL_RELATED_HEADER IN_LIST ${SDL_RELATED_HEADERS})
    vcpkg_replace_string("${SDL_RELATED_HEADER}"
        "#include <SDL\/"
        "#include <Urho3D\/ThirdParty\/SDL\/"
    )
endforeach()

if(EXISTS ${CURRENT_PACKAGES_DIR}/share/Urho3D/Resources)
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/Urho3D/Resources/Autoload ${CURRENT_PACKAGES_DIR}/tools/${PORT}/Autoload)
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/Urho3D/Resources/CoreData ${CURRENT_PACKAGES_DIR}/tools/${PORT}/CoreData)
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/Urho3D/Resources/Data ${CURRENT_PACKAGES_DIR}/tools/${PORT}/Data)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/Urho3D/Resources)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/share/Resources)
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/Resources/Autoload ${CURRENT_PACKAGES_DIR}/tools/${PORT}/Autoload)
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/Resources/CoreData ${CURRENT_PACKAGES_DIR}/tools/${PORT}/CoreData)
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/Resources/Data ${CURRENT_PACKAGES_DIR}/tools/${PORT}/Data)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/Resources)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/Urho3D/LuaScript/pkgs)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/Urho3D/ThirdParty/LuaJIT/jit)

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/docs ${CURRENT_PACKAGES_DIR}/share/${PORT}/docs)
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/scripts ${CURRENT_PACKAGES_DIR}/share/${PORT}/scripts)
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/rakefile ${CURRENT_PACKAGES_DIR}/share/${PORT}/rakefile)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
