# WinReg - Header-only library
vcpkg_fail_port_install(ON_TARGET "linux" "osx")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF 023ad61dc77c83407e7ae061f177a3ba3d3941e6 #v4.1.0
    SHA512 e62bf4a7926c720ad2c9a56b71b19ff48f566d56ddd5c858c25cec3fc6d8fd829267d3d1789b4841140b95d4e7ed0718af55317f6b4f76c1094bd1c69dda24f1
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY ${SOURCE_PATH}/WinReg/WinReg.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)