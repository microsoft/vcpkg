vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO morcules/SwiftNet
    REF "${VERSION}"
    SHA512 46a9b18a2479ccb94814af85e403d00aee3befe9c15c85be75862c23b4bac4a9e9cbc5bbf7b54906ee2f9a2ec0fa1db1e60259dd968b6c102e5ea2f65ff2cc14
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src"
)

vcpkg_cmake_install()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
