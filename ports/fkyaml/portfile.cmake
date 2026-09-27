vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fktn-k/fkYAML
    REF "v${VERSION}"
    SHA512 d1b2be36432df4cd8351f973263b62c33f221f2d7873250821d02f2d1a52cbc4340904c925aa058d2d1afe7122b85b2531581eb1b9366d88ef646e081e961446
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
