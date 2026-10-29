set(VCPKG_BUILD_TYPE "release") # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO d-bahr/CRCpp
    REF "release-${VERSION}"
    SHA512 0b338288b5ca3f92d334d9288f4589e1e9ec91613df7d21f52fbc739ce7d74df4558bcd4a7817151c65a9d0d3075f99aead5b26798496bc0f8971f3a4ccfe0e7
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_DOC=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/crcpp)
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
