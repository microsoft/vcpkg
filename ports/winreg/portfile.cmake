# WinReg - Header-only library
vcpkg_fail_port_install(ON_TARGET "linux" "osx")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF 2594342b7fe6065430bc377961c37d30614cb4ff #v4.1.2
    SHA512 924cdb77518c3f0843e95cd7e7d4626d4c0c466444cd79fdfa6943975154a54f4eb0d4bd45b8d37d73c650467b1d2728543176688f356c5100d98810e95c9fe8
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY "${SOURCE_PATH}/WinReg/WinReg.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)