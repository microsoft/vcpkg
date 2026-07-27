vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simfeo/FancyArgumentParser
    REF "v1.0.2"
    SHA512 03419a87a0c0b7ed6aedf724eb498bbfd5a6f59c0151e56d2e56a1551dcd9d91e0142d6bf8fcb39dca740cda4d72d6719d3b24fbf35dc52eb38bca7590d10f75
    HEAD_REF main
)

file(GLOB HEADERS "${SOURCE_PATH}/*.h" "${SOURCE_PATH}/*.hpp")
file(INSTALL ${HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
