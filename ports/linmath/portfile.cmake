vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO datenwolf/linmath.h
    REF refs/heads/master
    SHA512 d32276efb6c0065bfb79dee3a3f624369c64e2ce4e5265e371be4c21e779a6dbf2a2e7ecfad1530cb70ad0d3ac8982faca330622df6d9ed13ce548e7e91f8de7
    HEAD_REF master
)

# This is a header only library
file(INSTALL "${SOURCE_PATH}/linmath.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/linmath.h")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENCE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
