vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO GPUOpen-LibrariesAndSDKs/AMF
        REF v1.4.26
        SHA512 2c931ef7d38ade88a96041e0012605a5d25ec484bb2134f58310cf1a2c7212a869797cef99e2e751c8a6b3c473ba1f8762d4a5d41466d38cb5e31bf664a25f55
        HEAD_REF master
)

# Install the AMF headers to the default vcpkg location
file(INSTALL "${SOURCE_PATH}/amf/public/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/AMF")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
