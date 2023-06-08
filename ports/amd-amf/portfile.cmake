vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO GPUOpen-LibrariesAndSDKs/AMF
        REF "v${VERSION}"
        SHA512 43d7d3c05cb385cc5b0b76562dae3f8d5fb0123300291019ddce1032eec55a664290bd9b0552073d3a5cc7036886a015d9edb1f17e2f0f8ffd07acf57360ec18
        HEAD_REF master
)

# Install the AMF headers to the default vcpkg location
file(INSTALL "${SOURCE_PATH}/amf/public/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/AMF")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
