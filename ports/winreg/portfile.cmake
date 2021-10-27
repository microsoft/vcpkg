# WinReg - Header-only library
vcpkg_fail_port_install(ON_TARGET "linux" "osx")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF 6b61514683a185d207f1952723a3be405ef0c4bd #v4.1.1
    SHA512 e85eec1496d52988063567f4e9ceceda55e167ebefb6ea2ff90b8dc7670573ca4084d64dea952f5f439282b078d7b5d6f4aad9e2d3cda8424c745d81d3cad7ae
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY "${SOURCE_PATH}/WinReg/WinReg.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)