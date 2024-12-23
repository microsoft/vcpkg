vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux-sqlite
    REF "${VERSION}"
    SHA512 42e0edf14955daa029e66ae387c2752d4cc55bc202a0f2a4c453d679e98fffa179ad0f43d9162ec077d14dd969059494a063ccc684723eb9e8c174cf8abb9486
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
