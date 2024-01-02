vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aklomp/base64
    REF "v${VERSION}"
    SHA512 d63c6b36c99abcdfadf3730096c3a7cd36593526dd3dae815035ce196d3354ece7da1d92ecec800a81e1ab5e1d878b24f0b1de62b7aca516170d06a07c1b42a2
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(
	PACKAGE_NAME base64
	CONFIG_PATH "lib/cmake/base64"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
