vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fktn-k/fkYAML
    REF "v${VERSION}"
    SHA512 2c4a514c9441281ae1b6f2580fc16fc0bedffbc9c253a136e94796d8e6ef0e8970cdbdeca2966a8adf87e69e5a2ef6a4dae7065cb4516d5a1cf5fbc3d549b4b6
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
