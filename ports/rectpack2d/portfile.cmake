vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TeamHypersomnia/rectpack2D
    REF 7dde22ed7a707b952b9f8fb263bf3c94f4cef898
    SHA512 e5d000598ea4b1e23320d26f7ff3c8fa86422dfb819b72655f1ce9752d3b62d0699b8a8212b1fb4d73826e4a54a92e11a096434f18d6d1549144d439fc78c454
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/src/rectpack2D" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-rectpack2d-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-rectpack2d")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
