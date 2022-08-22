# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boost-ext/sml
    REF v1.1.5
    SHA512 6babee6da2db93912afa2eb932591674a73f43609b7c2b0523e84ba682c09f6d4f67d1c7f6ea48f73f1f09de8df2eaf2ae30b3399c1602189ea08d42689758d7
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/include/boost/sml.hpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/boost"
)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
