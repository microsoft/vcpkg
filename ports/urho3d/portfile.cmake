vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO urho3d/Urho3D
    REF f909775ca7d61e6291342b33921a22d837ac6b18
    SHA512 c20d2d9ad7f003e1d7cb923badb9695578271a62c45b2b37a26a0db7337304c95cf5d08ebf984f963c3e178968888beef158e32f7eebb6a96dda4dbac25f3998
    HEAD_REF master
    PATCHES
        asm_files.patch
        macosx.patch
        shared_libs.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(URHO3D_LIB_TYPE "STATIC")
else()
    set(URHO3D_LIB_TYPE "SHARED")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DURHO3D_LIB_TYPE=${URHO3D_LIB_TYPE}
        -DURHO3D_C++11=ON
        -DURHO3D_PCH=OFF
)

vcpkg_install_cmake()
if(EXISTS ${CURRENT_PACKAGES_DIR}/share/Urho3D/CMake/Modules)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/Urho3D/CMake/Modules)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/share/CMake/Modules)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/CMake/Modules)
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
