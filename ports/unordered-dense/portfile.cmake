vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO martinus/unordered_dense
	REF v${VERSION}
	SHA512 82724dd3651f520a240b131fa7cac209d844b9f3a54ea36c8cbb125cb42fdbf5f38d96935f2999e5bf04c447b2b9fde4ebc740decfd7d3d4b7d45177d4f26b58
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
