vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/display-library
    REF "${VERSION}"
    SHA512 fa11a74bbfc06a7c16e61d41151ead0fc9b872f98f0c7894daba787ddc105886f9cf2d627e23ce3d6c71ef48e7ca8093993b8a46acf3bda4423c5a73a3373109
    HEAD_REF master
)

# Install the ADL headers to the default vcpkg location
file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" [[As of 2023-07-25, according to
https://github.com/GPUOpen-LibrariesAndSDKs/display-library/blob/master/Public-Documents/README.md#end-user-license-agreement
this software is bound by the "SOFTWARE DEVELOPMENT KIT LICENSE AGREEMENT" PDF located at
https://github.com/GPUOpen-LibrariesAndSDKs/display-library/blob/master/Public-Documents/ADL%20SDK%20EULA.pdf
]])
