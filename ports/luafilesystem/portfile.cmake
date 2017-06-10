include(vcpkg_common_functions)

set(LUAFILESYSTEM_VERSION 1.6.3)
set(LUAFILESYSTEM_REVISION v_1_6_3)
set(LUAFILESYSTEM_HASH abfa1b3ac22ed80189560a1a025a7ea21a954defe14e5b539e08f266d180962a691262efc7eb2ddacc2d4aae14d6e356b1a276165b5bed46a13e4d6c61ab99f1)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/luafilesystem-${LUAFILESYSTEM_VERSION})
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO keplerproject/luafilesystem
    REF ${LUAFILESYSTEM_REVISION}
    SHA512 ${LUAFILESYSTEM_HASH}
    HEAD_REF master)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/lfs-def-fix.patch)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/luafilesystem)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/luafilesystem/LICENSE ${CURRENT_PACKAGES_DIR}/share/luafilesystem/copyright)

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
