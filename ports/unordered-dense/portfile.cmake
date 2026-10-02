vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO martinus/unordered_dense
	REF "v${VERSION}"
	SHA512 2e67c83e13eb3e85176d391a3994d352f33f2abf2bd7dd4df4ba306bd475730025d1f4065c1acc37f1ca8d62fb7d45aeea1a22ef9e6589a38e3ec5de08aabd56
	HEAD_REF main
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
