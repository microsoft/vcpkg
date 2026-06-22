vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO d-bahr/CRCpp
    REF "release-${VERSION}"
    SHA512 0e1338eb1f0f2a05d119ffae6071be06c24c39f20dcc846ea2c6248367ce600797af23b1f31dcd0f9e389efadc769bcc7129d8b741c30782571500c731c75451
    HEAD_REF master
)

# header-only
set(VCPKG_BUILD_TYPE "release")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TEST=OFF
        -DBUILD_DOC=OFF
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
