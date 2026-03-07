vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nevergiveupcpp/obfuscxx
    REF v${VERSION}
	SHA512 78f12676dce516847650fd06a4f5e745cb02c0877285ec135890c295978726741ba658e4bf543779384b6fa88bd1003b4be3f8290f69dd5cb554da715e6e4972
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/obfuscxx)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
