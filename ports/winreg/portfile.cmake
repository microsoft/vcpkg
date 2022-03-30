vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF d2cae6b398d3e5a4ac3f2b5215de9084609d7cff #v5.0.1
    SHA512 52f9a4cb57a59590349a20120b113e9926eea40a4aff05d7ffeaca73236add74685c160e37d37303684bc47f70b96998b816d2f3b9ea18777ec678dad02b7b7b
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY "${SOURCE_PATH}/WinReg/WinReg.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
