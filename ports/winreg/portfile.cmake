vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF bcdce7361be8409887adac6f6b5cb0a436a489aa #v5.0.0
    SHA512 8a112cc505ba9ec4431e80ee77b6a08389ea8ed92c2d75be191e2494818913ad01d6b4cc0ccf213dd2dd3455594434ba3876fa385e71bdbb758797672c844d8d
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY "${SOURCE_PATH}/WinReg/WinReg.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
