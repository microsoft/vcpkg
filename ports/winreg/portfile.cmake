vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF aaa7434663f1f8017284812501812ac3c74612c0 #v5.1.1
    SHA512 1c35513bb387a30452c9fcb1fb9cd32be68a8fa625cff1301490d6e89430e3b6f08e54f41ae0261540900923d2f39f3b2ed32bf54869d643aa5020ff1ca6c1c7
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY "${SOURCE_PATH}/WinReg/WinReg.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
