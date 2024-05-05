vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/ordered-map
    REF "v${VERSION}"
    SHA512 1ae4f8876b13aaf5a9b08f8075299255a51e64fac8ca1c46813294e374b8c9334a7bd1b22618719fab2a8dced42be91e96d8b15595ce3dd8a6d726dadba52ce9
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright
)
