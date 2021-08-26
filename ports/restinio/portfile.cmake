vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF 0052518f5692f8f051031e06d933b726191be97e # v.0.6.13
    SHA512 e7474aa1cef4145fe2f02c52cf80fdaf6724da45a4f3d0f1f56fc188ac50ff29a3ac72ea0e4402dc7ad378d0b2acfcea30cf8a57d218c3f5eb55d3f0d83dad29
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/vcpkg
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/restinio)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
