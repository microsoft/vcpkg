vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux-sqlite
    REF "${VERSION}"
    SHA512 ccfeb141530efcf8233bd3579ba6eb17e7decc1d4fa92706f0810824303078e7f379a9c81a777189860e53c866b9c338b51b2f5884958782d02f7d79d7fb575c
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
