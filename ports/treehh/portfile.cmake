vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kpeeters/tree.hh
    REF 8dc57bc2bb7cd2fd1d6e777c6b5b58db0c3852ef
    SHA512 a40481952802fdfab05159822b012a576ea956135a44f88d93844cb578c49ed5fb6fb7330bce699d7fa6ba1da65d12b284b6e9e6b103eadfd76cbc96d6839db5
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/src/tree.hh" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}/")
file(INSTALL "${CURRENT_PORT_DIR}/copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
