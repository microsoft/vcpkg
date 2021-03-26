# WinReg - Header-only library
vcpkg_fail_port_install(ON_TARGET "linux" "osx")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF 9b7ad93b366ffa1f6938c6685d1cfc50d9d0100b #v4.0.0
    SHA512 dd68f92579ee6e0f7628023d4e2f52c79bf2a0e5624b2158078f827c7df6d207244ffd1f8347ad65475b276185314349aedc4f9ae4b5e3405ee5088efaf72734
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY ${SOURCE_PATH}/WinReg/WinReg.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)