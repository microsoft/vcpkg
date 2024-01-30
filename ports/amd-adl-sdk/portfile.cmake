vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/display-library
    REF "${VERSION}"
    SHA512 805bc1a7f221b33955d79943833d04838b459f316c2a9ad5fa1831588b07c0bbe5975aca07c90117c10c6ff22ee12a69d5a26a75e7191eb6c40c1dccccd192af
    HEAD_REF master
)

# Install the ADL headers to the default vcpkg location
file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" [[As of 2023-07-25, according to
https://github.com/GPUOpen-LibrariesAndSDKs/display-library/blob/master/Public-Documents/README.md#end-user-license-agreement
this software is bound by the "SOFTWARE DEVELOPMENT KIT LICENSE AGREEMENT" PDF located at
https://github.com/GPUOpen-LibrariesAndSDKs/display-library/blob/master/Public-Documents/ADL%20SDK%20EULA.pdf
]])
