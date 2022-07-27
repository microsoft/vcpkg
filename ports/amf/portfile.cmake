vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO GPUOpen-LibrariesAndSDKs/AMF
        REF 5359f7dba51107da19b7650e5d8a40a0f04ea6d9 # 1.4.21
        SHA512 fa0ddafb4c8e490316f002fd7e006e78b3972f3b472ced3ec155ea7214ff4d030759c9b9b67412b43bd33767ed51d105f7663fe82c0a7246f186cd1f6aab5120
        HEAD_REF master
)

# Install the AMF headers to the default vcpkg location
file(INSTALL "${SOURCE_PATH}/amf/public/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/AMF")
configure_file("${SOURCE_PATH}/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)