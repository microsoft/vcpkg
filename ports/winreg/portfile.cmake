# WinReg - Header-only library
vcpkg_fail_port_install(ON_TARGET "linux" "osx")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF 1dfd91d80ec89d36236e41dd75f2c5ddb31093a1 #v2.2.3
    SHA512 5d43cd15f958411407ae636234c8e1c3d43d5dbd074b93d578245d75405fb2ec7a9d4924d7eb9141fc9ce42391846d22a2e3945e53bdf43fbd78ccbce397c03e 
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY ${SOURCE_PATH}/WinReg/WinReg.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)