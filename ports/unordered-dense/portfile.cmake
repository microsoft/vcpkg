vcpkg_minimum_required(VERSION 2023-04-07)

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO martinus/unordered_dense
	REF v${VERSION}
	SHA512 105eb88deeb89c9424973d2b5425a6e176f3f66a45f11cf6ed520cce177918cd5345e840d10561f6f790b6cc11b7b6e1357bd2fc4d199254a360de88ce553fe0
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
