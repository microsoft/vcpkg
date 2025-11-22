vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO deadlightreal/SwiftNet
    REF "${VERSION}"
    SHA512 ef088d34b396a4391860fdfb49a488a41560e7f89b66ee3ef386f17846e805c5810b1f620827a96bc2765842efa09b4a2b8fd0b5c4e01f1caa28337b68066e52
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src"
)

vcpkg_cmake_install()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
