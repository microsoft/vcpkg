# WinReg - Header-only library
vcpkg_fail_port_install(ON_TARGET "linux" "osx")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF c1c2a9ce26295cd3f0ca69e7383319813d46574f #v2.4.0
    SHA512 99d52bb90784c5918816f2f843b75001a817cab25470a5a8a09bd8e6189a1631c098c5da9935abb94cf21461e9b58f431619d943efaa0750f216fcf1ba96c427 
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY ${SOURCE_PATH}/WinReg/WinReg.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)