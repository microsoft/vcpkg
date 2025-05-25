vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ramajd/tinyproto
    REF 7fcc42152b4b30c72495c018d5d29b229f37d22a
    SHA512 86831b9c94ee57dcc561bfef46c1ae2b4bdad95de656be4f5b28acf59fe0ad05c6636b74dcd41dbc95677bee96711968111676c1664fb27dfacc9a5d7bdbefb4
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
	PACKAGE_NAME "tinyproto"
	CONFIG_PATH lib/cmake/tinyproto
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

