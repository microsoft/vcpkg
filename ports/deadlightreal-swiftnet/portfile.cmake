vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO deadlightreal/SwiftNet
    REF "${VERSION}"
    SHA512 5248ddd2486d5892952c72a3c93fc7dec0320df1cdc9ae13cddcb7e57aa709c5bdbd5fa791d59e2b54c749a58b9f4ab6a9b912bd31193aa510eca0762b60ce4d
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src"
)

vcpkg_cmake_install()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
