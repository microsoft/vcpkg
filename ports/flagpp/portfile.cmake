vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Curve/flagpp
    REF "v${VERSION}"
    SHA512 5a1f5775f9da8be1590b8916fc082e5e2d537e90018776a7a21ade74bfc700db095049a4e41104a26cefa2e0defca89355e059d7f75752e54746b5b2e1827b34
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
