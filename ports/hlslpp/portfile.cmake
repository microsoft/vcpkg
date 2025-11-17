vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO redorav/hlslpp
    REF "${VERSION}"
    SHA512 5946a4d5b50a337fc13ec1ea30b1e11962fa28fa9c199163c18e25d938bd07bbf2853cde3611006c11ad2107d6b158a52638b2b29ad0f71329d756c22c2563f8
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
