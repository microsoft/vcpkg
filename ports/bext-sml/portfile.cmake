# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boost-ext/sml
    REF v1.1.4
    SHA512 0ded162e5d9d7cc9d8769fd9131d7a5cfc98187c8e9d98393eda9e0804c282e510707de38fe7229d2fe16aea70c9a8e300f14e992fff3ddedd0fa1b6a66ab1ba
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/include/boost/sml.hpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/boost"
)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
