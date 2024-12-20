vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux-sqlite
    REF "${VERSION}"
    SHA512 e15ba3220ae1c293a3a0d3fea848e53108e9338c7c781f33cde2c7850bc99bb35c6f1eb28aaad6f29e182ea5516797d6c81fbee27c2c814c62c274f013d8d17a
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
