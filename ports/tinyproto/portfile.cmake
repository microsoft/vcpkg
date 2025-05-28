vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lexus2k/tinyproto
    REF dc7a6c2186fdb38f0a263d26e81e204437b7ee66
    SHA512 13dc128567357b08cdee15ab710649f9eaaf58b466afba429ac0059aeaa4c908445dd20e9576ddfd471712aa7556805b7d415c2e7c6d8e8a00d7c076d0d270c2
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

