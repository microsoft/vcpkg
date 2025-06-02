vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/AMF
    REF "v${VERSION}"
    SHA512 e19f8f98448412812ea1a4bf677ea501bebfc37871160e1cd0d0d2bf91af22f2115406949b594f405dab153952dcc3cbdc666ef2e6be1b768b803cdde7e23a7b
    HEAD_REF master
)

# Install the AMF headers to the default vcpkg location
file(INSTALL "${SOURCE_PATH}/amf/public/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/AMF")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
