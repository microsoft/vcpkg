vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO morcules/SwiftNet
    REF "${VERSION}"
    SHA512 d4eec1ffe8f70488b7a8dd4297ecdafac75b618e62eac3b6dd8a9634157d322da5b3aa6631ce74536887e83af97548c6ab014aa95536ea179aeef278c2c39e8d
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src"
)

vcpkg_cmake_install()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
