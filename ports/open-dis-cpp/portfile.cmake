vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-dis/open-dis-cpp
    REF "v${VERSION}"
    SHA512 fa62188f773ad044644a58caf1e25bef417dfdea47c9da8a2ea7f997154b4f3976019e32e73cc533696a3d4e45ec4a8402b6df140878dfa2ff078740d61b4b0f
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME OpenDIS CONFIG_PATH lib/cmake/OpenDIS)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
