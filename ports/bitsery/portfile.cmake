include(vcpkg_common_functions)

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO fraillt/bitsery
	REF v4.6.0
	SHA512 519aec8730f4b6f8d26aff17d984101990ade02888664eb2c40bc1085e4dcffbbe83b08216149da234c8195d1940ec06744f16312f60e362f7005b205aa829a6
	HEAD_REF master
	PATCHES fix-install-paths.patch
)

vcpkg_configure_cmake(
	SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
)

vcpkg_install_cmake()

# Delete redundant and empty directories
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Install license
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/bitsery RENAME copyright)
