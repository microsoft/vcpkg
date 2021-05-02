vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO martinus/robin-hood-hashing
	REF 3.11.1
	SHA512 5bc4aee93d3cc3b4f50e017698ef22f36201a48c3b5b7baddaf0171fadc36f144a49c79849e7e7083d121be995ad97b64906c007771b0adced7e4b150192fe03
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
