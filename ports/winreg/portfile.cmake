vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF 4ac74bfec290ec4376100372f59dbc2554e54692 #v5.1.0
    SHA512 3d25725c9fc781ffdfa1bbd3ed143a8381d40a1613d4786861e13b180098a5ce92ff193cf25d7490be0096c2eafcace45e6a2f94fbfaa28964d12b80b55d0637
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY "${SOURCE_PATH}/WinReg/WinReg.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
