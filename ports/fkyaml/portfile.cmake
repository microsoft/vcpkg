vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fktn-k/fkYAML
    REF "v${VERSION}"
    SHA512 20a7e2a236f77e27a676348585cbf6c36d8c46f1ad0964b879eb61925e3d6545d6dda46379b897712890faa2b8d5e837b7f9cc312448a3d762f0017c618cbcd1
    HEAD_REF develop
    PATCHES
        fix-natvis-path.patch
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
