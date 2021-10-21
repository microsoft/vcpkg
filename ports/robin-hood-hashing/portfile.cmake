vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO martinus/robin-hood-hashing
	REF 3.11.3
	SHA512 0a4bc04a7b474b80dc156492a12d29046a566272c7b5f2fbcbd27c68ec62fa5db753afe5eac521cd4bd6d6e5ce1b1dfd590ae0b64003a70e102c83a89045b1e6
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
