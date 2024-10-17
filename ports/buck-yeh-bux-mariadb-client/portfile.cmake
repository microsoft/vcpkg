vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux-mariadb-client
    REF "${VERSION}"
    SHA512 89ae1d7c49ed9f1bd600a4da91aa4ff0853cdb8a3e3724bf0902aecdcd8706f6ee1d5355926e1cf2a6225063b109a055efa28a40475e31d22f9c57a38582483a
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
