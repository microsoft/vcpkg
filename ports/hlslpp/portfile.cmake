vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO redorav/hlslpp
    REF "${VERSION}"
    SHA512 e57dec0285c299cfd7e88d246523ba70eb246e968ad023a481faf5540972b7053288487f1486fa8ebef5cb6d4ec448ff99afbf5c10447b66b5f2ca5d2ad7829e
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
