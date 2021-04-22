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
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(URHO3D_LIB_TYPE "STATIC")
else()
    set(URHO3D_LIB_TYPE "SHARED")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DURHO3D_LIB_TYPE=${URHO3D_LIB_TYPE}
        -DURHO3D_C++11=ON
        -DURHO3D_PCH=OFF
)

vcpkg_cmake_install()
if(EXISTS ${CURRENT_PACKAGES_DIR}/share/Urho3D/CMake/Modules)
    vcpkg_cmake_config_fixup(CONFIG_PATH share/Urho3D/CMake/Modules)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/share/CMake/Modules)
    vcpkg_cmake_config_fixup(CONFIG_PATH share/CMake/Modules)
endif()
vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/tools/${PORT})

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

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
