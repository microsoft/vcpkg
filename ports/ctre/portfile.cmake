include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hanickadot/compile-time-regular-expressions
    REF v2.2
    SHA512 f6f18e3e5bc654ff94cd540a3b665615151678541575dfc8d4113c317fba5ea83f57694dc330c174110e6263c9b64a128f2a9234cc626a952e7518c423fda703
    HEAD_REF master
)

# Install header files
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ctre RENAME copyright)
