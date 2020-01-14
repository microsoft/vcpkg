include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hanickadot/compile-time-regular-expressions
    REF v2.6.4
    SHA512 421122787e3220c5c8935e0d80f06b3d9ba953fface3dc7f4a6e1aadf9fa75468394eb0d2b679f263c17f2b849fd191eff9b532c781278d75a9c54a109dd3ecb
    HEAD_REF master
)

# Install header files
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ctre RENAME copyright)
