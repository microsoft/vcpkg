vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/AMF
    REF "v${VERSION}"
    SHA512 8a2aa3a358a7c0cfac47f545b8a375de86652d6590795161ad592e49219f54f5ec8dd06d5d48ea9e091fac09e83dbac2044d7ed551898f907cc1b30eea66b7ab
    HEAD_REF master
)

# Install the AMF headers to the default vcpkg location
file(INSTALL "${SOURCE_PATH}/amf/public/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/AMF")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
