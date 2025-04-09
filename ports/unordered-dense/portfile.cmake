vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO martinus/unordered_dense
	REF "v${VERSION}"
	SHA512 f9c819e28e1c1a387acfee09277d6af5e366597a0d39acf1c687acf0608a941ba966af8aaebdb8fba0126c7360269c4a51754ef4cab17c35c01a30215f953368
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
