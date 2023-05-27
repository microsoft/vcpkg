vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/cpp-async
    REF "v${VERSION}"
    SHA512 c3a6700c86d6bec2680c9d0edfe3ed02e83f8ecec134163243a7bfa4e12d4867a47d64eadd377de9b2a69401b8b512e0ee274275895a8f301c266db24b6e0a4b
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/include/async" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
