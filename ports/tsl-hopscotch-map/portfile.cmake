vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/hopscotch-map
    REF "v${VERSION}"
    SHA512 e2f215d93c84606e8dc71c3403f60a589bd7f78922b5b90afcd0c9d7cbea7ff2e9c6fdb17a6444d4f4b8c9b42a47066995640cd093d8a32a4dabc8c03262e7d5
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
