# WinReg - Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF ba6b74972038778d0bf5ffa6de705ec6e2768735 #v6.1.0
    SHA512 1b7ac1ef4322c2e1c80be840d4117424263c4ad02050926f1ebdd3fbb4978a02d12f485ccb0aff46ca4acc4188f48f7522ac4d6d663517d7bad71147224accc7
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY "${SOURCE_PATH}/WinReg/WinReg.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
