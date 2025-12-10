vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO deadlightreal/SwiftNet
    REF "${VERSION}"
    SHA512 af2e1e9691a9579dd9443b4ec2b7ad28955d2f56035d92f359e186b2565c3ee5d7eb71e3d97d1e9d9e0bf4bf9abdb48a58e360324dca6a7d68ecd0878f3bb798
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src"
)

vcpkg_cmake_install()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
