# WinReg - Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF "v${VERSION}"
    SHA512 174d5ff3c08825990663159e91b9150f5a792591a4ee9e7f08facde124e212456df8b52c3fb50239363a2a2b43986678fde3880ca81e19c4c51e0f2ebddfef8c
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY "${SOURCE_PATH}/WinReg/WinReg.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
