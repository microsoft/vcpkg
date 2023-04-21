set(LUAFILESYSTEM_VERSION 1.8.0)
set(LUAFILESYSTEM_REVISION v1_8_0)
set(LUAFILESYSTEM_HASH 79d964f13ae43716281dc8521d2f128b22f2261234c443e242b857cfdf621e208bdf4512f8ba710baa113e9b3b71e2544609de65e2c483f569c243a5cf058247)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO keplerproject/luafilesystem
    REF ${LUAFILESYSTEM_REVISION}
    SHA512 ${LUAFILESYSTEM_HASH}
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
