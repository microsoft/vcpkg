vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux
    REF "v${VERSION}"
    SHA512 e5dcdba0ee07d3cf63edb1e5808436d9b2de4d1e393a6e447cca82f68d1b67dc94350d55926aa90d00d6f9a032cc76446d83b206dbb906be10de9f1c15a71359
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
