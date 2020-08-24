vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO urho3d/Urho3D
    REF 1.7.1
    SHA512 a82b85bc763d823bfa953eeb8aa5e388df5b0bf0c1dfe8fd317c74443367b771ad5b8de09ca64adf610dadbf5444c2d51df8215d0765a6076489b5cae47a2cf0
    HEAD_REF master
    PATCHES
        asm_files.patch
        ik_memory_backtrace.patch
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
        -DURHO3D_LUA=OFF
        -DURHO3D_NAVIGATION=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/Urho3D/CMake/Modules)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/Urho3D/LuaScript/pkgs)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
