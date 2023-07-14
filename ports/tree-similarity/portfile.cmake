vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DatabaseGroup/tree-similarity
    REF 0.1.1
    SHA512 5367f4b694d686456c4ffaaf21c7372fb7012811f3b2ded00c6bc1d18d27ecb7a6a28b3c9bd7cb91cb42c5426321b0b12a2e14ab2c838aa8fc859128b372dded
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")