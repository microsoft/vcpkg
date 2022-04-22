vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux-mariadb-client
    REF bb078afd7e7287f9c3220b889e8206d5a841b185 # v1.0.1
    SHA512 96cc0a40809f13d4a49e849306eed96dc2bc00998612344801df7d664f8a0a9cfa646b70927747d1decbca48cf5ff9502796b7738b106e9b68a4564abd981ce9
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
