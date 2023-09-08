vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO zeroc-ice/mcpp
	REF 1c4b0f26614bff331eb8a9f2b514309af6f31fd0 # 2.7.2.14 + 6 commits
	SHA512 233300f128e9d1406fe104da2579298f2f02b44fa33a59887ea673cf6400ec58ea2d3d72b0d07e452ed603fbc7f19a21f9b80eb99ae7c7819159ddcf9f2c5abc
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
