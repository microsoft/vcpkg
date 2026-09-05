vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO zeroc-ice/mcpp
	REF "v${VERSION}"
	SHA512 06a2ccf461c09aec6916e623a1ae59da7db1509a0ba5ceedcfeec2d32a71986bd8ce249cbf99232eaa8f347ee035dd5da5868e7d96ab7ae6270ebdac1b06b498
	HEAD_REF master
	PATCHES
		installation.diff
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
