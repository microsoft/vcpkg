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

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
