vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO redorav/hlslpp
    REF "${VERSION}"
    SHA512 d70cd2a6788ffd462b088ad9ad4c9fd0aba0d971054a896626d05409afd5865f44f630e0b84329f0923b1ee2e608200a222e0207529faf22931c8260766b0c6d
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}/include/")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/include" "${CURRENT_PACKAGES_DIR}/include/hlslpp")

# Copy and rename License -> copyright.
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Copy the cmake config file, which is used to setup the imported target.
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/${PORT}-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Copy and show the usage.
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
