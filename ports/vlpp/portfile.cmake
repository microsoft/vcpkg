vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vczh-libraries/Release
    REF 5dfe25c4f4997da2d7a23bdc80c2438e72d9813a # 0.11.0.0
    SHA512 5d585e561246385b074c625a3644b79defa22328dab0ab14112c846cb917f384abb617a5f400971ca29e4ee5ac391b88b17ee65d594caf9ebf279806db669a4a
    HEAD_REF master
    PATCHES fix-arm.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DSKIP_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-vlpp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Tools
file(INSTALL "${SOURCE_PATH}/Tools/CppMerge.exe" DESTINATION "${CURRENT_PACKAGES_DIR}/tools")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
