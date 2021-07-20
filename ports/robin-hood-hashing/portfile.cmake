vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO martinus/robin-hood-hashing
	REF 3.11.2
	SHA512 5d55f054e29ae34d410eb0103f9f0aa1faf47e313b9f089c73b9c26fd9bedf132f6bb13b4bcd2664309c32fe7e859e346d0a6e7ab7f46b294f9b8db207577795
	HEAD_REF master
)

vcpkg_cmake_configure(
	SOURCE_PATH ${SOURCE_PATH}
	OPTIONS
		-DRH_STANDALONE_PROJECT=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
	PACKAGE_NAME robin_hood
	CONFIG_PATH lib/cmake/robin_hood
)

file(REMOVE_RECURSE
	${CURRENT_PACKAGES_DIR}/debug
	${CURRENT_PACKAGES_DIR}/lib
)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
