# WinReg - Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF "v${VERSION}"
    SHA512 2c1f43a57d42628fbf3e5b5e268fd9248cbeaef47500e1a580a44634b9fbc38622d0adb89f454abba602c50d334323512458c6d860b9818c39a65a3fb7d1e48b
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY "${SOURCE_PATH}/WinReg/WinReg.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
