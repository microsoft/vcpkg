vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/AMF
    REF "v${VERSION}"
    SHA512 589fccabaadb27e48e9adb1d3594db2adadee343c966f8db99ff29a92ec78ae6b0c42f13113a4fc66da0044ee660cfa1caf6867c508af044935646c09f5af50e
    HEAD_REF master
)

# Install the AMF headers to the default vcpkg location
file(INSTALL "${SOURCE_PATH}/amf/public/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/AMF")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
