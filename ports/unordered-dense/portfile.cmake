vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO martinus/unordered_dense
	REF v${VERSION}
	SHA512 098a4a3d50e9a53af363ff517983d3bd69bd33e9587623427e11e9ae0abf8e47cda5efdecdbaff50273df669a404c3cb0b1b51121c1ecc5e653e8a1f81a21265
	HEAD_REF master
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
	PACKAGE_NAME unordered_dense
	CONFIG_PATH lib/cmake/unordered_dense
)

file(REMOVE_RECURSE
	"${CURRENT_PACKAGES_DIR}/debug"
	"${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
