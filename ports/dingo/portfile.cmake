set(VCPKG_BUILD_TYPE release) # header-only
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO romanpauk/dingo
    REF "v${VERSION}"
    HEAD_REF master
    SHA512 9fb6cf64b1a9ee99404d69d9756530c9ffc591116579469ad39b5fa458a127628899bcac4e99a9bedaf7cae6c19c1a0e5816043868e9daf6d60858a1c2e17c0b
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

