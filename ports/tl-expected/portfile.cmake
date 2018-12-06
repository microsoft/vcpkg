include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TartanLlama/expected
    REF v0.3
    SHA512 a228399f7103020ed814f1c755b82cf831b3d8c6aaa23dbc3aedc226b3cbd39c22075952dda3af84c8cf6f74ab1131c6997a2431ee62314bd82ccafdc9ab23a3
    HEAD_REF master
)

# Install header file
file(INSTALL ${SOURCE_PATH}/tl DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/tl-expected RENAME copyright)
