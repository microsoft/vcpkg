vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fredrik-johansson/arb
    REF eeef7bdd349366be4d1691da05e49dcf9c01a394 # 2.17.0
    SHA512 d4c53c0343bec32e0b6c0d3a41e92663b13f9648a08c28c56a3098dd77d71248718b414dbb70c116bd7e07648646bdb663c1b9560e41d971d5c12d2d0466e9a0
    HEAD_REF master
)

file(REMOVE ${SOURCE_PATH}/CMakeLists.txt)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Remove duplicate headers
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
