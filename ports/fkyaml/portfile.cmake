vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fktn-k/fkYAML
    REF "v${VERSION}"
    SHA512 f4dfb55e954a5a13bc4d04e0ec87f8bdea95a20260197ecf74fe017d09ed73fd2c606236b9998bca9f4b41b517a6957f37588d2ec5892204857e585fd7f533d7
    HEAD_REF develop
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFK_YAML_INSTALL=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/fkYAML)
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
