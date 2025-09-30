set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Sedeniono/tiny-optional
    REF "v${VERSION}"
    SHA512 0143df1f9412f9273fcad012925a0e60a74fffa5f843831ee05fe287871c1122c82f6023b61c3e25a62c904014e4fa7cda2b60d1a8a146d7e57f9a3790c42cf3
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
