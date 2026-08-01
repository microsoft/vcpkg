vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simfeo/FancyArgumentParser
    REF "v1.0.3"
    SHA512 72152ba4a78a55344f68ed9adf7ae187e2f695bda50e8b9014ac3f0e83a61b43340fd244bc1fd1b34249e2721f03f0a563a5e23d062951c908debfc348dcdeec
    HEAD_REF main
)

file(GLOB HEADERS "${SOURCE_PATH}/*.h" "${SOURCE_PATH}/*.hpp")
file(INSTALL ${HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
