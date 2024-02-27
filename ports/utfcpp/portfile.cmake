set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemtrif/utfcpp
    REF "v${VERSION}"
    SHA512 e02c10c7e9c8c6ee8b8d45bb7521997106be1bf6778d964d4c66a4f025b6ce46df43be12dc74b03639be9f99db8aa4d8c22a65880a057aeb0e76a90bb87c760c
    HEAD_REF master
    PATCHES fix-include-path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME utf8cpp CONFIG_PATH share/utf8cpp/cmake)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
