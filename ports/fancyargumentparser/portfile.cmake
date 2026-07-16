vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simfeo/FancyArgumentParser
    REF "v1.0.1"
    SHA512 c1805a6ed2c41addd346427ca8b22d6aaf575e3467cc25ef32467bde970b927787930cd1337b450cc469a6ffedc49481ebff9c7b37c2487fb21871a56bad4144
    HEAD_REF main
)

file(GLOB HEADERS "${SOURCE_PATH}/*.h" "${SOURCE_PATH}/*.hpp")
file(INSTALL ${HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
