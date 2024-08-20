vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/AMF
    REF "v${VERSION}"
    SHA512 e0c4f583996ff2d1d61c53b8ce7ef2eadb32d2a13930e59146b935840e31d032c5cec48baced70b0007fa5f33e30537d03ddf71140ff51213085aba20e16f5ca
    HEAD_REF master
)

# Install the AMF headers to the default vcpkg location
file(INSTALL "${SOURCE_PATH}/amf/public/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/AMF")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
