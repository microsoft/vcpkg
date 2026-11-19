# WinReg - Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF "v${VERSION}"
    SHA512 46b1b04cbcd39e25e4c704f9059ecf1c13f54de48cacc5639c3634ee37e3cf1b91abf1586b6d3115163f46b0ce82f115c7e708b9cee164d707a0f4df8e67226f
    HEAD_REF master
)

# Copy the library headers
file(COPY "${SOURCE_PATH}/Include/WinReg" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
