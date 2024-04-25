# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boost-ext/sml
    REF v${VERSION}
    SHA512 7612f301ed3e4edd4171214d85c6b746af19079622aef80c0965536782e4f50635332e7435966b072e1cb415c3a680260211740313d52d1927ab5af78ecdd30e
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/include/boost/sml.hpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/boost"
)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
