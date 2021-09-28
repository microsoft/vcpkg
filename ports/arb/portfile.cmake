vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fredrik-johansson/arb
    REF bd68cc0219c5b4bf4a3466b5b6c190203d7dc7b0 # 2.21.0
    SHA512 5e09ece4855906206c0f5aff9f56d13e1b2432863921af235682b9c45b35e03b1a7db308315bd329e9ed93be36d5e5aac914b1276b9412a551f5f2a189884404
    HEAD_REF master
)

file(REMOVE "${SOURCE_PATH}/CMakeLists.txt")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Remove duplicate headers
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)