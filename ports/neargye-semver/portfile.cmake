# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Neargye/semver
    REF v0.2.2
    SHA512 f299e6d74f0232f40e20959ed3d7138d5faff924f60748827849e21951d76d34070bac2479a35f3ea6e801ec5e23ebf8391adedc70d778c4aa5e4c89b20c332c
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/semver.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/neargye)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
