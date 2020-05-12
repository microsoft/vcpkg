include(vcpkg_common_functions)

set(LUAFILESYSTEM_VERSION 1.7.0.2)
set(LUAFILESYSTEM_REVISION v1_7_0_2)
set(LUAFILESYSTEM_HASH a1d4d077776e57cd878dbcd21656da141ea3686c587b5420a2b039aeaf086b7e7d05d531ee1cc2bbd7d06660d1315b09593e52143f6711f033ce8eecdc550511)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO keplerproject/luafilesystem
    REF ${LUAFILESYSTEM_REVISION}
    SHA512 ${LUAFILESYSTEM_HASH}
    HEAD_REF master
    PATCHES
        lfs-def-fix.patch
)

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
