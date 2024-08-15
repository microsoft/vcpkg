vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO redorav/hlslpp
    REF "${VERSION}"
    SHA512 79b1464eb6441ec720b9952e80d7fbdb67852f7770fbe6ec2c67736627e62292f9d23dfcc9b1d548b6c33b75a7b2e911fa757fe087d7360bc7e72867d7f2c7a8
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
