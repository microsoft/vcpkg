vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO deadlightreal/SwiftNet
    REF 1.0.0
    SHA512 a153f130844999e4a06a58e2812b2a76b425204879cec5b5765bf8983c1679f3381cc1c314830cd68e995d05111023f49d893d9c201d34e496457a69b27abb48
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/src
)

vcpkg_cmake_install()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
