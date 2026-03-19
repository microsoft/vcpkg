vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hanjingo/high-jump
    REF v${VERSION}
    SHA512 65081057674916833611dfbb11ba261477f1aebfd7291ed93b1722f8a36e327ad7d82db0b26f6776b73d5ceb862ca167954653adcc4e2374bf0f607eb0724c21
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_LIB=OFF
        -DBUILD_EXAMPLE=OFF
        -DBUILD_TEST=OFF
        -DBUILD_BENCH=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
