# WinReg - Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF "v${VERSION}"
    SHA512 a242be16e7acf435ccd83f2becdcf8d07a63daae3801f92a7bfab8c13cd120a7eb83e30150c9eb8d0ef2fad56ea070e1a3a47da372ab600c7b6f586b30ce41fc
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY "${SOURCE_PATH}/WinReg/WinReg.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
