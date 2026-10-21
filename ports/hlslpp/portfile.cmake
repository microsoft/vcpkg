vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO redorav/hlslpp
    REF "${VERSION}"
    SHA512 448b8d78f8249061fb17a2aa3f9851f512ece84b08b2a75d255adcdc05339ccfd19d300788216256b5ec93296f5b1e474f94b3a49d673f38e684a6f9601d833e
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
