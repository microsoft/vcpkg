# WinReg - Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF 86d7ae5c5034aa88b40914fc0d209d8ceb214afe #v6.0.0
    SHA512 ca2daa61e89029641e189fe2a0177282900e30b8907702abd8010cc6c66cfe4cfaf15888c5860d7aec262209939fc7658da450e308be0f73b5b0423f4bb5bdf2
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY "${SOURCE_PATH}/WinReg/WinReg.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
